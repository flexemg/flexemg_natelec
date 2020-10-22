// ***************************************************************************/
//Actel Corporation Proprietary and Confidential
//Copyright 2009 Actel Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT v.4 top level RTL module
//              Various RTL Modules
//
//Revision Information:
//Date         Description
//05Nov2009    Initial Release
//
//SVN Revision Information:
//SVN $Revision: $
//SVN $Data: $
//
//Resolved SARs
//SAR     Date    Who         Description
//
//Notes:
//

`timescale 1 ns/100 ps

module adc_fft_if_COREFFT_0_COREFFT_INPLC (CLK, NGRST,
    DATAI_IM,
    DATAI_RE,
    DATAI_VALID,
    READ_OUTP,
    DATAO_IM,
    DATAO_RE,
    DATAO_VALID,
    BUF_READY,
    OUTP_READY,
    SCALE_EXP,
    PONG  );
  parameter INVERSE = 0;
  parameter SCALE   = 0;  //0-conditional 1-unconditional scaling
  parameter POINTS  = 256;
  parameter WIDTH   = 18;
  parameter MEMBUF  = 0;
  parameter URAM_MAXDEPTH = 0;
  parameter SCALE_EXP_ON = 0;
  parameter FPGA_FAMILY = 12;

  localparam LOGPTS       = ceil_log2(POINTS);
  localparam LOGLOGPTS    = ceil_log2(LOGPTS);
  localparam FLOGLOGPTS   = floor_log2(LOGPTS)+1;
  localparam DWIDTH       = 2*WIDTH;
  localparam TWIDTH       = WIDTH;
  localparam TDWIDTH      = 2*TWIDTH;
  localparam HALFPTS      = POINTS/2;
  localparam MPIPE        = (WIDTH>18)? 9 : 3;
  localparam RW_DLY       = MPIPE + 7;  // delay btw in-place RAM read and write

  input CLK, NGRST, DATAI_VALID, READ_OUTP;
  input[WIDTH-1:0] DATAI_IM, DATAI_RE;
  output BUF_READY, PONG, DATAO_VALID, OUTP_READY;
  output[WIDTH-1:0] DATAO_IM, DATAO_RE;
  output[FLOGLOGPTS-1:0] SCALE_EXP;

  wire[LOGPTS-2:0] ldA_w, rA_w, wA_w, tA_w, twid_wA_w, outBuf_wA_w;
  wire[LOGPTS-1:0] outBuf_rA_w;
  wire wEn_even_w, wEn_odd_w, preSwCross_w, twid_wEn_w, inBuf_wEn_w;
  wire outBuf_wEn_w, inBufValid_w, wLastStage_w, startFFTrd_w, startLoad_w;

  reg [WIDTH-1:0] datai_im_r, datai_re_r;
  reg [LOGPTS-2:0] rA_r /*synthesis syn_repicate = 1 */ ;
  reg [LOGPTS-2:0] tA_r, outBuf_wA_r;
  reg [LOGPTS-1:0] outBuf_rA_r;
  reg  buf_ready_r, preSwCross_r, outBuf_wEn_r, inBufValid_r;
  reg  outp_ready_r, datao_valid_r, datai_valid_r;

  wire postSwCross_w;
  wire ldRiskOV_w, bflyRiskOV_w;
  wire[DWIDTH-1:0] readP_w, readQ_w;
  wire[DWIDTH-1:0] bflyInP_w, bflyInQ_w, bflyOutP_w, bflyOutQ_w;
  wire[TDWIDTH-1:0] T_w, twidData_w;
  wire[DWIDTH-1:0] outEven_w, outOdd_w;
  wire preSwValid_w, bflyValid_w;
  wire upScale_w;
  wire clkEn = 1'b1;
  wire [DWIDTH-1:0] outPQ;
  wire slowClk, ctrl_outp;
  wire fftRd_done_tick;

  wire datao_valid_w, outp_ready_w;

  fft_inpl_slowClock slowClock_0 (.clk(CLK), .ifiNreset(NGRST), .slowClk(slowClk));   

  fft_inpl_sm_top #( .PTS(POINTS), .HALFPTS(HALFPTS), .LOGPTS(LOGPTS),
            .LOGLOGPTS(LOGLOGPTS), .RW_DLY(RW_DLY),
            .MEMBUF(MEMBUF) ) sm_0
     (.clk(CLK), .clkEn(clkEn),
      .slowClk(slowClk),
      .nGrst(NGRST),
      .ifiD_valid(DATAI_VALID), .ifiRead_y(READ_OUTP),
      .ldA(ldA_w), .rA(rA_w), .wA(wA_w), .tA(tA_w), .twid_wA(twid_wA_w),
      .outBuf_wA(outBuf_wA_w), .outBuf_rA(outBuf_rA_w),
      .wEn_even(wEn_even_w), .wEn_odd(wEn_odd_w),
      .preSwCross(preSwCross_w),
      .twid_wEn(twid_wEn_w),
      .inBuf_wEn(inBuf_wEn_w), .outBuf_wEn(outBuf_wEn_w), .smPong(PONG),
      .inBuf_rdValid(inBufValid_w),
      .wLastStage(wLastStage_w),
      .smStartFFT(startFFTrd_w), .smStartLoad(startLoad_w),
      .fftRd_done_tick(fftRd_done_tick),
      .ifoLoad(BUF_READY), .ifoY_valid(datao_valid_w), .ifoY_rdy(outp_ready_w) );

  adc_fft_if_COREFFT_0_inPlace #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH), //multi
              .MEMBUF(MEMBUF), .FPGA_FAMILY(FPGA_FAMILY) ) inBuf_0
     (.clk(CLK),
      .rA(rA_r),
      .wA_load(ldA_w),
      .wA_bfly(wA_w),
      .ldData({datai_im_r, datai_re_r}),
      .wP_bfly(outEven_w), .wQ_bfly(outOdd_w),
      .wEn_bfly(inBuf_wEn_w),
      .wEn_even(wEn_even_w), .wEn_odd(wEn_odd_w),
      .ping(~PONG),
      .pong(PONG),
      .load(buf_ready_r),
      .outP(readP_w), .outQ(readQ_w));

  fft_inpl_switch #(.DWIDTH(DWIDTH)) preBflySw_0 (.clk(CLK),
      .inP(readP_w), .inQ(readQ_w),
      .sel(preSwCross_r), .outP(bflyInP_w), .outQ(bflyInQ_w),
      .validIn(inBufValid_r), .validOut(preSwValid_w));

  fft_inpl_bfly2 #(.WIDTH(WIDTH), .TWIDTH(TWIDTH), .DWIDTH(DWIDTH),
          .TDWIDTH(TDWIDTH), .MPIPE(MPIPE), .FPGA_FAMILY(FPGA_FAMILY) )
    bfly_0(.clk(CLK), .upScale(upScale_w),
      .inP(bflyInP_w), .inQ(bflyInQ_w), .T(T_w),
      .outP(bflyOutP_w), .outQ(bflyOutQ_w),
      .validIn(preSwValid_w), .validOut(bflyValid_w),
      .swCrossIn(preSwCross_r), .swCrossOut(postSwCross_w)  );

  adc_fft_if_COREFFT_0_twiddle #(.TDWIDTH(TDWIDTH), .LOGPTS(LOGPTS))
                 lut_0 (.A(twid_wA_w), .T(twidData_w));

  adc_fft_if_COREFFT_0_twidLUT #(.LOGPTS(LOGPTS), .TDWIDTH(TDWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH), .FPGA_FAMILY(FPGA_FAMILY))  //multi
                  twidLUT_1 (
    .clk(CLK),
    .slowClk(slowClk),
    .wA(twid_wA_w), .wEn(twid_wEn_w), .rA(tA_r),
    .D(twidData_w),
    .Q(T_w) );

  fft_inpl_switch #(.DWIDTH(DWIDTH)) postBflySw_0 (.clk(CLK),
      .inP(bflyOutP_w), .inQ(bflyOutQ_w),
      .sel(postSwCross_w), .outP(outEven_w), .outQ(outOdd_w),
//29/04/13      .validIn(bflyValid_w), 
      .validIn(1'b0),     //29/04/13 
      .validOut());

  generate
    if(MEMBUF)
      adc_fft_if_COREFFT_0_outBuff #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),   //multi
                .FPGA_FAMILY(FPGA_FAMILY)) outBuff_0 (.clk(CLK),
        .rA(outBuf_rA_r), .wA(outBuf_wA_r), .inP(outEven_w), .inQ(outOdd_w),
        .wEn(outBuf_wEn_r), .outD({DATAO_IM, DATAO_RE}) );

    else begin  // In min config read out the In-place RAM
      fft_inpl_kitDelay_bit_reg # (.DELAY(3)) ctrl_dly_0  (
          .nGrst(NGRST),
          .rst(1'b0),
          .clk(CLK), .clkEn(clkEn),
          .inp(outBuf_rA_w[LOGPTS-1]),
          .outp(ctrl_outp) );
      assign outPQ =  ctrl_outp ? readQ_w : readP_w;
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), .DELAY(1) ) pipe_out_0
        ( .nGrst(NGRST),
          .rst(1'b0),
          .clk(CLK), .clkEn(clkEn),
          .inp(outPQ[DWIDTH-1:WIDTH]), .outp(DATAO_IM)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), .DELAY(1) ) pipe_out_1
        ( .nGrst(NGRST),
          .rst(1'b0),
          .clk(CLK), .clkEn(clkEn),
          .inp(outPQ[WIDTH-1:0]), .outp(DATAO_RE)  );
    end
  endgenerate

  // Autoscaling
  // monitor if input data .im and .re have MSB == sign
  assign ldRiskOV_w= ~( (datai_im_r[WIDTH-1] == datai_im_r[WIDTH-2]) &
                        (datai_re_r[WIDTH-1] == datai_re_r[WIDTH-2] )  );

//  assign ldRiskOV_w= ~( (datai_im_r[WIDTH-1] == datai_im_r[WIDTH-2]) &
//                        (datai_re_r[WIDTH-1] == datai_re_r[WIDTH-2] ) &  
//                        (datai_im_r[WIDTH-1] == datai_im_r[WIDTH-3]) &
//                        (datai_re_r[WIDTH-1] == datai_re_r[WIDTH-3] )  );

  // Make sure a sign bit and two consecutive bits are the same, that is
  // data =< 1/4 of the range
//  assign bflyRiskOV_w = ~( (bflyOutP_w[DWIDTH-1] == bflyOutP_w[DWIDTH-2]) &
//                          (bflyOutP_w[WIDTH-1]  == bflyOutP_w[WIDTH-2] ) &
//                          (bflyOutQ_w[DWIDTH-1] == bflyOutQ_w[DWIDTH-2]) &
//                          (bflyOutQ_w[WIDTH-1]  == bflyOutQ_w[WIDTH-2] )  );

  assign bflyRiskOV_w = ~( (bflyOutP_w[DWIDTH-1] == bflyOutP_w[DWIDTH-2]) &   //04/29/13
                          (bflyOutP_w[WIDTH-1]  == bflyOutP_w[WIDTH-2] ) &    //04/29/13
                          (bflyOutQ_w[DWIDTH-1] == bflyOutQ_w[DWIDTH-2]) &    //04/29/13
                          (bflyOutQ_w[WIDTH-1]  == bflyOutQ_w[WIDTH-2] ) &    //04/29/13
                          (bflyOutP_w[DWIDTH-1] == bflyOutP_w[DWIDTH-3]) &    //04/29/13
                          (bflyOutP_w[WIDTH-1]  == bflyOutP_w[WIDTH-3] ) &    //04/29/13
                          (bflyOutQ_w[DWIDTH-1] == bflyOutQ_w[DWIDTH-3]) &    //04/29/13
                          (bflyOutQ_w[WIDTH-1]  == bflyOutQ_w[WIDTH-3] )   ); //04/29/13

  fft_inpl_autoScale #(.SCALE_MODE(SCALE),
              .MEMBUF(MEMBUF),
              .SCALE_EXP_ON(SCALE_EXP_ON),  // 1-build scaling exponent
              .LOGLOGPTS(FLOGLOGPTS) ) autoScale_0
   (.clk(CLK),
    .ldRiskOV(ldRiskOV_w), .bflyRiskOV(bflyRiskOV_w),
    .startLoad(startLoad_w), .startFFT(startFFTrd_w),
    .bflyOutValid(bflyValid_w), .wLastStage(wLastStage_w),
    .fftRd_done_tick(fftRd_done_tick),
    .datai_valid(datai_valid_r),
    .scale_exp(SCALE_EXP),
    .upScale(upScale_w));

  assign OUTP_READY = outp_ready_r;
  assign DATAO_VALID = datao_valid_r;

  always @ (posedge CLK) begin
      rA_r          <= rA_w ;
      tA_r          <= tA_w ;
      outBuf_wA_r   <= outBuf_wA_w ;
      outBuf_rA_r   <= outBuf_rA_w ;
      preSwCross_r  <= preSwCross_w;
      outBuf_wEn_r  <= outBuf_wEn_w;
      inBufValid_r  <= inBufValid_w;
      datai_im_r    <= DATAI_IM;
      datai_re_r    <= DATAI_RE;
      buf_ready_r   <= BUF_READY;
      outp_ready_r  <= outp_ready_w;
      datao_valid_r <= datao_valid_w;
      datai_valid_r <= DATAI_VALID;
  end


  // -----------------------------
  function [31:0] ceil_log2;
      input integer x;
      integer tmp, res;
    begin
      tmp = 1;
      res = 0;
      while (tmp < x) begin
        tmp = tmp * 2;
        res = res + 1;
      end
      ceil_log2 = res;
    end
  endfunction

  function [31:0] floor_log2;
      input integer x;
      integer tmp, res;
    begin
      tmp = 1;
      res = 0;
      while (2*tmp <= x) begin
        tmp = tmp * 2;
        res = res + 1;
      end
      floor_log2 = res;
    end
  endfunction
endmodule

