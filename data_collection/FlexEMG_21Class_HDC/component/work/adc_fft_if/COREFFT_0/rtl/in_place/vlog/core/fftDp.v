// ***************************************************************************/
//Actel Corporation Proprietary and Confidential
//Copyright 2009 Actel Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT
//              Datapath modules, RAM's
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

`timescale 1 ns/100 ps

//                    ######     #    #     #
//                    #     #   # #   ##   ##  ####
//                    #     #  #   #  # # # # #
//                    ######  #     # #  #  #  ####
//                    #   #   ####### #     #      #
//                    #    #  #     # #     # #    #
//                    #     # #     # #     #  ####
// a RAM is HALFPTS deep

module adc_fft_if_COREFFT_0_wrapRam(rClk, wClk, D, Q, wA, rA, wEn);
  parameter LOGPTS = 8;
  parameter DWIDTH = 32;
  parameter FPGA_FAMILY = 12;
  parameter URAM_MAXDEPTH = 0;

  localparam RAM_DEPTH = 1 << (LOGPTS-1);
  localparam SMARTGEN = 1;
//11/25/2014    localparam SMARTGEN = 0;

  input rClk, wClk, wEn;
  input[DWIDTH-1:0] D;
  input[LOGPTS-2:0] rA, wA;
  output[DWIDTH-1:0] Q;

  wire [LOGPTS-2:0] one = {(LOGPTS-1){1'b1}};

  generate
    if(SMARTGEN==0) begin: dbg_model
      fft_inpl_RAM_two_port # (.BITWIDTH(DWIDTH),
                  .RAM_LOGDEPTH(LOGPTS-1),
                  .RAM_PIPE(1)  ) bhvRAM_0  (
        .nGrst(1'b1),
        .RCLOCK(rClk),
        .WCLOCK(wClk),
        .WRB   (wEn),
        .RDB   (1'b1),
        .DI    (D),
        .RADDR (rA),
        .WADDR (wA),
        .DO    (Q)   );
    end
  endgenerate

  generate  // RTAX-D has one block RAM type only
    if( (SMARTGEN==1) && (FPGA_FAMILY==12) ) begin: rtax_ram
      adc_fft_if_COREFFT_0_ram_smGen smGen_RAM_0  (
        .RCLOCK(rClk),
        .WCLOCK(wClk),
        .WRB   (wEn),
        .RDB   (1'b1),
        .DI    (D),
        .RADDR (rA),
        .WADDR (wA),
        .DO    (Q)   );
    end
  endgenerate

  generate  // G4.  Use uRAM if appropriate
    if( (SMARTGEN==1) && (RAM_DEPTH <= URAM_MAXDEPTH) && (
        (FPGA_FAMILY==19)||(FPGA_FAMILY==24)||(FPGA_FAMILY==25) ) )     //rt
      begin: SmFu4_uram
        adc_fft_if_COREFFT_0_uram_smGen smGen_RAM_0  (
          .rD         (Q),
          .wD         (D),
          .rAddr      (rA),
          .wAddr      (wA),
          .wClk       (wClk),
          .wEn        (wEn),
          .A_CLK      (rClk),               //actgen
          //unused ports
          .B_DOUT(),
          .B_ADDR     (one),
          .rBlk       (1'b1),
          .B_BLK      (1'b0),
          .wBlk       (1'b1)  );
    end
  endgenerate

  generate  // G4.  Use Large SRAM otherwise
    if( (SMARTGEN==1) && (RAM_DEPTH > URAM_MAXDEPTH) && (
        (FPGA_FAMILY==19)||(FPGA_FAMILY==24)||(FPGA_FAMILY==25) ) )     //rt
      begin: SmFu4_sram
      adc_fft_if_COREFFT_0_ram_smGen smGen_RAM_0  (
        .RCLOCK(rClk),
        .WCLOCK(wClk),
        .WRB   (wEn),
        .RDB   (1'b1),
        .DI    (D),
        .RADDR (rA),
        .WADDR (wA),
        .DO    (Q)   );
      end
   endgenerate

  generate  // G5.  Use uRAM if appropriate
    if( (SMARTGEN==1) && (RAM_DEPTH<=URAM_MAXDEPTH) && (FPGA_FAMILY==26) )
      begin: PolarFire_uram
        adc_fft_if_COREFFT_0_uram_g5 uram_0  (
          .rD         (Q),
          .wD         (D),
          .rAddr      (rA),
          .wAddr      (wA),
          .wClk       (wClk),
          .rClk       (rClk),
          .wEn        (wEn)  );
    end
  endgenerate

  generate  // G5.  Use Large SRAM otherwise
    if( (SMARTGEN==1) && (RAM_DEPTH>URAM_MAXDEPTH) && (FPGA_FAMILY==26) )
      begin: PolarFire_sram
      adc_fft_if_COREFFT_0_lsram_g5 lsram_0  (
        .RCLOCK(rClk),
        .WCLOCK(wClk),
        .WRB   (wEn),
        .DI    (D),
        .RADDR (rA),
        .WADDR (wA),
        .DO    (Q),
        .DO_nGrst(1'b1),
        .DO_en(1'b1),
        .DO_rst(1'b0)   );
      end
   endgenerate





endmodule


// In-place memory.  It stores pairs of complex words in even/odd sub-buffers
// so that bfly can read two cmplx words a clock (depth of the memory = PTS/2.
// The memory accepts fresh data in Load mode (write-only), and serves
// butterfly (read/write) in processing mode
module adc_fft_if_COREFFT_0_inBuffer (clk,
  // Processing mode
  rA,     //
  outP,   //  Read group.  Used by the bfly only
  outQ,   //
  wA_bfly,  //
  wP_bfly,  //  Write group: addr & data from bfly
  wQ_bfly,  //
  wEn_bfly, //
  // Load mode
  wA_load,        //
  ldData,         //  Load write group
  wEn_even,       //
  wEn_odd,        //
  // Control either Load (0) or Processing (1)
  bflyMode  );
  parameter LOGPTS = 8;
  parameter DWIDTH = 32;
  parameter MEMBUF = 1;
  parameter URAM_MAXDEPTH = 0;
  parameter FPGA_FAMILY = 12;

  input clk;
  input[LOGPTS-2:0] rA;
  output[DWIDTH-1:0] outP, outQ;      // output data to FFT engine

  input[LOGPTS-2:0] wA_bfly;
  input[DWIDTH-1:0] wP_bfly, wQ_bfly; // input data coming from FFT engine
  input wEn_bfly;                     // wEn to store FFT engine data

  input[LOGPTS-2:0] wA_load;  // write Addr for loading new data
  input[DWIDTH-1:0] ldData;   // new data to load
  input wEn_even, wEn_odd;    // wEn to store new data in even/odd sub-buffers

  input bflyMode;

  wire[LOGPTS-2:0] wA_w;
  wire[DWIDTH-1:0] wP_w, wQ_w;
  wire wEn_P, wEn_Q;

  reg bflyMode_r;
  reg wEn_P_r, wEn_Q_r;
  reg [LOGPTS-2:0] wA_r;

  // if(bflyMode==0) LOAD, else RUN BFLY
  assign wEn_P = bflyMode ? wEn_bfly : wEn_even;
  assign wEn_Q = bflyMode ? wEn_bfly : wEn_odd;
  assign wA_w  = bflyMode ? wA_bfly : wA_load;

  generate
    if(MEMBUF) begin
      // if(bflyMode==0) LOAD, else RUN BFLY
      assign wP_w  = bflyMode_r ? wP_bfly : ldData;
      assign wQ_w  = bflyMode_r ? wQ_bfly : ldData;

      // instantiate two mem blocks HALFPTS deep each
      adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) memP  (.rClk(clk), .wClk(clk),
        .D(wP_w),.Q(outP),.wA(wA_r),.rA(rA),.wEn(wEn_P_r));
      adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) memQ  (.rClk(clk), .wClk(clk),
        .D(wQ_w),.Q(outQ),.wA(wA_r),.rA(rA),.wEn(wEn_Q_r));

      always @ (posedge clk) begin
          bflyMode_r    <= bflyMode;
          wEn_P_r       <= wEn_P;
          wEn_Q_r       <= wEn_Q;
          wA_r          <= wA_w;
      end
    end
    else  begin
      assign wP_w  = bflyMode ? wP_bfly : ldData;
      assign wQ_w  = bflyMode ? wQ_bfly : ldData;

      // instantiate two mem blocks HALFPTS deep each
      adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) memP  (.rClk(clk), .wClk(clk),
        .D(wP_w),.Q(outP),.wA(wA_w),.rA(rA),.wEn(wEn_P));
      adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) memQ  (.rClk(clk), .wClk(clk),
        .D(wQ_w),.Q(outQ),.wA(wA_w),.rA(rA),.wEn(wEn_Q));
    end
  endgenerate
endmodule


module adc_fft_if_COREFFT_0_inPlace (clk, rA, wA_load, wA_bfly, ldData, wP_bfly, wQ_bfly,
  wEn_bfly, wEn_even, wEn_odd, ping, pong, load, outP, outQ);
  parameter LOGPTS = 8;
  parameter DWIDTH = 32;
  parameter MEMBUF = 1;     //if(MEMBUF==0) strip to a single in-place RAM
  parameter URAM_MAXDEPTH = 0;
  parameter FPGA_FAMILY = 12;

  input clk;
  input ping, pong, load;
  input[LOGPTS-2:0] rA;
  input[LOGPTS-2:0] wA_load;
  input[LOGPTS-2:0] wA_bfly;
  input[DWIDTH-1:0] ldData;
  input[DWIDTH-1:0] wP_bfly, wQ_bfly;
  input wEn_bfly, wEn_even, wEn_odd;
  output[(DWIDTH-1):0] outP, outQ;

  reg [LOGPTS-2:0] wA_bfly_r;
  reg [LOGPTS-2:0] wA_load_r /*synthesis syn_repicate = 1 */ ;

  reg wEn_bfly_r, wEn_odd_r, wEn_even_r;

  wire[DWIDTH-1:0] pi_outP, pi_outQ, po_outP, po_outQ;

  generate
    if(MEMBUF)  begin
      adc_fft_if_COREFFT_0_inBuffer #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .MEMBUF(MEMBUF), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                  .FPGA_FAMILY(FPGA_FAMILY) ) piBuf
        (.clk(clk),
        .rA(rA), .wA_bfly(wA_bfly), .wA_load(wA_load),
        .ldData(ldData), .wP_bfly(wP_bfly), .wQ_bfly(wQ_bfly),
        .wEn_bfly(wEn_bfly), .wEn_even(wEn_even), .wEn_odd(wEn_odd),
        .bflyMode(ping),
        .outP(pi_outP), .outQ(pi_outQ));

      adc_fft_if_COREFFT_0_inBuffer #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .MEMBUF(MEMBUF), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                  .FPGA_FAMILY(FPGA_FAMILY) ) poBuf
        (.clk(clk),
        .rA(rA), .wA_bfly(wA_bfly), .wA_load(wA_load),
        .ldData(ldData), .wP_bfly(wP_bfly), .wQ_bfly(wQ_bfly),
        .wEn_bfly(wEn_bfly), .wEn_even(wEn_even), .wEn_odd(wEn_odd),
        .bflyMode(pong),
        .outP(po_outP), .outQ(po_outQ));

      assign outP = pong ? po_outP : pi_outP;
      assign outQ = pong ? po_outQ : pi_outQ;
    end

    else  begin    // no buffer, In-place RAM only
      always @ (posedge clk) begin
        wA_bfly_r     <= wA_bfly;
        wA_load_r     <= wA_load;
        wEn_bfly_r    <= wEn_bfly;
        wEn_odd_r     <= wEn_odd;
        wEn_even_r    <= wEn_even;
      end

      adc_fft_if_COREFFT_0_inBuffer #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .MEMBUF(MEMBUF), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                  .FPGA_FAMILY(FPGA_FAMILY) ) minimal_0
        (.clk(clk),
        .rA(rA),
        .wA_bfly(wA_bfly_r),
        .wA_load(wA_load_r),
        .ldData(ldData),
        .wP_bfly(wP_bfly),
        .wQ_bfly(wQ_bfly),
        .wEn_bfly(wEn_bfly_r),
        .wEn_even(wEn_even_r),
        .wEn_odd(wEn_odd_r),
        .bflyMode(~load),
        .outP(outP),
        .outQ(outQ)      );
      end
    endgenerate
  endmodule



/******************************  outBuffer  ***********************************/
module adc_fft_if_COREFFT_0_outBuff (clk, wEn, inP, inQ, wA, rA, outD );
  parameter LOGPTS = 8;
  parameter DWIDTH = 32;
  parameter URAM_MAXDEPTH = 0;
  parameter FPGA_FAMILY = 12;

  input clk, wEn;
  input [DWIDTH-1:0] inP, inQ;
  input [LOGPTS-2:0] wA;
  input [LOGPTS-1:0] rA;
  output[DWIDTH-1:0] outD;
  reg[DWIDTH-1:0] outD;

  reg wEn_r;
  reg [DWIDTH-1:0] inP_r, inQ_r;
  reg [LOGPTS-2:0] wA_r /*synthesis syn_repicate = 1 */ ;
  reg rAmsb_r1, rAmsb_r2;
  wire[DWIDTH-1:0] P_w, Q_w, outPQ;

  adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) outBuf_0
    (.D(inP_r), .Q(P_w), .wA(wA_r), .rA(rA[LOGPTS-2:0]),
     .wEn(wEn_r), .rClk(clk), .wClk(clk));
  adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(DWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) outBuf_1
    (.D(inQ_r), .Q(Q_w), .wA(wA_r), .rA(rA[LOGPTS-2:0]),
     .wEn(wEn_r), .rClk(clk), .wClk(clk));

  assign outPQ =  rAmsb_r2 ? Q_w : P_w;

  always @ (posedge clk) begin
    inP_r <= inP;      inQ_r <= inQ;        //pipes
    wEn_r <= wEn;      wA_r  <= wA;
    rAmsb_r2 <= rAmsb_r1;    rAmsb_r1  <= rA[LOGPTS-1];
    outD <= outPQ;
  end
endmodule

/************************* T W I D D L E   L U T *******************************
RAM-block based twiddle LUT                                                   */
module adc_fft_if_COREFFT_0_twidLUT (clk, slowClk, wA, wEn, rA, D, Q);
  parameter LOGPTS = 8;
  parameter TDWIDTH = 32;
  parameter URAM_MAXDEPTH = 0;
  parameter FPGA_FAMILY = 12;

  input clk, slowClk, wEn;
  input [TDWIDTH-1:0] D;
  output[TDWIDTH-1:0] Q;
  input [LOGPTS-2:0] rA, wA;

  reg[LOGPTS-2:0] rA_r;

  adc_fft_if_COREFFT_0_wrapRam #(.LOGPTS(LOGPTS), .DWIDTH(TDWIDTH), .URAM_MAXDEPTH(URAM_MAXDEPTH),
                .FPGA_FAMILY(FPGA_FAMILY)) twidLUT_0
    (.D(D), .Q(Q), .wA(wA), .rA(rA_r), .wEn(wEn), .rClk(clk), .wClk(slowClk));
  always @ (posedge clk)
      rA_r <= rA;
endmodule

