// ***************************************************************************/
//Actel Corporation Proprietary and Confidential
//Copyright 2009 Actel Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT
//              User testbench
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

// ---------------------------- 8 to 32 bits version ----------------------
module testbench;
  `include "coreparameters.v"
  localparam LOGPTS       = ceil_log2(POINTS);
  localparam LOGLOGPTS    = ceil_log2(LOGPTS);
  localparam DWIDTH       = 2*WIDTH;
  localparam TWIDTH       = WIDTH;
  localparam TDWIDTH      = 2*TWIDTH;
  localparam HALFPTS      = POINTS/2;

  integer cycleCnt; // counter of FFT cycles.  Use up to 4 cycles for the test
  integer inVectIndex, outVectIndex;
  wire ifoY_rdy_fall_edge, ifoY_rdy_fall_edge_tick;
  reg[31:0] test_time;
  reg read_outp_r;
  wire clk, ifiNreset;
  wire reset;  // reset internal for this file, fft_tb only
  // Storage for the in/out test vectors
  reg[DWIDTH-1:0] testPattern1 [0:POINTS-1];
  reg[DWIDTH-1:0] testPattern2 [0:POINTS-1];
  reg[DWIDTH-1:0] testResGold1 [0:POINTS-1];
  reg[DWIDTH-1:0] testResGold2 [0:POINTS-1];
  wire [DWIDTH-1:0] test_res_gold1 = testResGold1[outVectIndex];
  wire [DWIDTH-1:0] test_res_gold2 = testResGold2[outVectIndex];
  wire [DWIDTH-1:0] test_res_gold, test_res_gold_buf, test_res_gold_nobuf;
  wire [WIDTH-1:0] test_res_gold_im, test_res_gold_re;

  wire [DWIDTH-1:0] testPatSequence;
  wire ifiD_valid_w, ifoY_rdy;
  reg[1:0] inStrobeCnt; // simulates inData strobe

  wire [DWIDTH-1:0] fftOut_w;
  wire ifoLoad, ifoPong;
  reg failValue, failCount;
  reg  failure;     // if any of the runs fails
  reg testOn  = 1'b0;
  // assign 1-bit ID to the input data.  The FFT result should be
  // assigned the same ID to make it easier for a user to figure out which
  // FFT result corresponds to which input data array
  reg ping_tick;
  assign reset = ~ifiNreset;

  // -------- Fill in the in/out test vector arrays ---------
  `include "fft_tb_inc32.v"

  initial begin
    ping_tick = 0;
    cycleCnt = 0;
  end

  always @ (negedge ifoY_rdy or posedge reset)    // count FFT cycles
    if (reset) cycleCnt = 0;
    else begin
      cycleCnt <= cycleCnt+1;
    end

  always @ (posedge reset or posedge clk)
    if(reset==1) test_time <= 'b0;
    else begin
      test_time <= test_time+1;
      if( (test_time[0]!=1) && (cycleCnt==0) ) read_outp_r <= 0;
      else                                     read_outp_r <= 1;
    end

  adc_fft_if_COREFFT_0_COREFFT # (
    .FPGA_FAMILY  (FPGA_FAMILY  ),
    .URAM_MAXDEPTH(URAM_MAXDEPTH),
    .CFG_ARCH     (1),              // Inplace
    .INVERSE      (INVERSE      ),
    .SCALE        (SCALE        ),
    .POINTS       (POINTS       ),
    .WIDTH        (WIDTH        ),
    .MEMBUF       (MEMBUF       ),
    .SCALE_EXP_ON (1),

    .DATA_BITS    (10),
    .TWID_BITS    (10),
    .FFT_SIZE     (32),
    .SCALE_ON     (1),
    .ORDER        (1),
    .SCALE_SCH    (255)     )  uut_0 (
      .DATAI_IM   (testPatSequence[DWIDTH-1:WIDTH]),
    	.DATAI_RE   (testPatSequence[WIDTH-1:0]),
    	.DATAI_VALID(ifiD_valid_w),
    	.DATAO_IM   (fftOut_w[DWIDTH-1:WIDTH]),
    	.DATAO_RE   (fftOut_w[WIDTH-1:0]),
      .CLK        (clk),
    	.NGRST      (ifiNreset),
      .OUTP_READY (ifoY_rdy),
    	.BUF_READY  (ifoLoad),
    	.READ_OUTP  (read_outp_r),
    	.PONG       (ifoPong),
    	.SCALE_EXP  (),
      .DATAO_VALID(ifoY_valid),
    	.RST        (1'b0),
      .START      (1'b0),
    	.CLKEN      (1'b0),
      .RFS        (),     // req for START
      .INVERSE_STRM(1'b0),
      .OVFLOW_FLAG(),
      .REFRESH    (1'b0)      );

  // Hardcoded input data valid signal
  assign ifiD_valid_w = (|inStrobeCnt) & ifoLoad & testOn;   // reduction OR

  generate
    if(MEMBUF==1)
      assign testPatSequence =
        (!ifoPong)? testPattern2[inVectIndex] : testPattern1[inVectIndex];
    else
      assign testPatSequence =
        (cycleCnt[0])? testPattern2[inVectIndex] : testPattern1[inVectIndex];
  endgenerate

  always @ (posedge clk)  begin
    if(reset|(!ifoLoad))  inStrobeCnt <= 2'b01;
    else                  inStrobeCnt <= inStrobeCnt+1;
  end
  // Hardcoded data valid signal ends

  always @ (posedge clk) begin
    testOn <= 1;
    if((cycleCnt>3) && ifoY_rdy_fall_edge_tick) begin
      if(failure==1'b1)
          $display ("!!!! One or more of the FFT tests FAILED !!!!");
      $stop;  //run test for 4 cycles
    end
    // Input test vector counter writes the vectors to the testPatSequence reg
    if(reset|(!ifoLoad)) inVectIndex <= 0;
    else
      if(ifiD_valid_w) begin
        ping_tick <= #1 !ifoPong;

        if(inVectIndex > POINTS-2)  inVectIndex <= 0;
        else                        inVectIndex <= inVectIndex + 1;
      end
  end

  // select proper golden pattern
  assign test_res_gold_buf   = ping_tick   ? test_res_gold2 : test_res_gold1;
  assign test_res_gold_nobuf = cycleCnt[0] ? test_res_gold2 : test_res_gold1;
  assign test_res_gold = MEMBUF ? test_res_gold_buf : test_res_gold_nobuf;
  assign test_res_gold_im = test_res_gold[DWIDTH-1:WIDTH];
  assign test_res_gold_re = test_res_gold[WIDTH-1:0];
  // end select proper golden pattern

  // Initialize failure
  always @ (negedge ifiNreset)
    failure = 1'b0;

  // read the FFT results
  always @ (posedge clk) begin
    if( reset | (ifoY_rdy_fall_edge_tick) | (!testOn) )   begin
      outVectIndex <= 0;
      failValue <= 1'b0;
      failCount <= 1'b0;
    end
    else begin
      if(ifoY_valid) begin
        if (fftOut_w!==test_res_gold)
          failValue <= 1'b1;

        outVectIndex = outVectIndex+1;
      end // if(ifoY_valid)

      if(ifoY_rdy_fall_edge) begin
        if(outVectIndex<POINTS)
          failCount = 1'b1;
        $display ("*************************");
        if(failValue | failCount) begin
          $display ("!!!! FFT test FAILED !!!!");
          failure = 1'b1;
        end
        else $display ("*    FFT test passed    *");
        $display ("*************************");
      end
    end // reset else
  end  // always @ (posedge clk)

  bhvEdge # (.REDGE(0)) fall_edge_0
    ( .nGrst(ifiNreset), .rst(1'b0), .clk(clk),
      .inp(ifoY_rdy),
      .outp(ifoY_rdy_fall_edge) );

  bhvEdge # (.REDGE(0)) fall_edge_1
    ( .nGrst(ifiNreset), .rst(1'b0), .clk(clk),
      .inp(ifoY_rdy_fall_edge),
      .outp(ifoY_rdy_fall_edge_tick) );

  //---------------------------------------------------------------------------
  bhvClockGen # (.CLKPERIOD (10),
                 .NGRSTLASTS (24)  ) clock_0 (
                    .clk(clk),
                    .nGrst (ifiNreset) );

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
endmodule
