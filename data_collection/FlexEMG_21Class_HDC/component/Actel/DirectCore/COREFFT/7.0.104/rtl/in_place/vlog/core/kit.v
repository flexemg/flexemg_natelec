// ***************************************************************************/
//Actel Corporation Proprietary and Confidential
//Copyright 2009 Actel Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT RTL Component Library
//              Various Standard RTL Modules
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

// ----------- Simple one-DFF Edge Detector ------------
module fft_inpl_kitEdge (nGrst, rst, clk, inp, outp);
  parameter FRONT_EDGE = 1;   // 0 - rear edge

  input  nGrst, clk, rst;
  input inp;
  output outp;

  reg inp_tick;
  wire rise_edge, fall_edge;

  assign rise_edge = inp & ~inp_tick;
  assign fall_edge = ~inp & inp_tick;
  assign    outp      = FRONT_EDGE ? rise_edge : fall_edge;

  always @(posedge clk or negedge nGrst) begin
    if(!nGrst)    inp_tick <= 1'b0;
    else
      if (rst)    inp_tick <= 1'b0;
      else        inp_tick <= inp;

  end
endmodule
/*  -- usage
 fft_inpl_kitEdge # (.FRONT_EDGE(1)) edge_detect_0 (
     .nGrst(nGrst), .rst(rst), .clk(clk),
     .inp(in),
     .outp(out) );
*/
// -----------------------------------------------------------------------------



//     #####
//    #     #   ####   #    #  #    #  #####  ######  #####
//    #        #    #  #    #  ##   #    #    #       #    #
//    #        #    #  #    #  # #  #    #    #####   #    #
//    #        #    #  #    #  #  # #    #    #       #####
//    #     #  #    #  #    #  #   ##    #    #       #   #
//     #####    ####    ####   #    #    #    ######  #    #

// Counts to TC.  Generates tc when Q == TC
module fft_inpl_counter (clk, nGrst, rst, cntEn, tc, Q);
  parameter
    WIDTH = 7,
    TC =    127;
  input nGrst, rst;
  input clk, cntEn;
  output reg tc;
  output reg[WIDTH-1:0] Q;

  always @ (posedge clk or negedge nGrst)
    if(!nGrst) begin
      Q  <= 0;
      tc <= 0;
    end
    else
      if(rst) begin
        Q  <= 0;
        tc <= 0;
      end
      else
        if(cntEn) begin
          tc <= (Q==(TC-1));
          if (Q==TC) Q <= 0;
          else       Q <= Q + 1;
        end
endmodule


// simple incremental counter
module fft_inpl_kitCountS(nGrst, rst, clk, clkEn, cntEn, Q, dc);
  parameter WIDTH = 16;
  parameter DCVALUE = (1 << WIDTH) - 1; // state to decode
  parameter BUILD_DC = 1;

  input nGrst, rst, clk, clkEn, cntEn;
  output [WIDTH-1:0] Q;
  output dc;  // decoder output
  reg [WIDTH-1:0] Q;

  assign dc = (BUILD_DC==1)? (Q == DCVALUE) : 1'bx;

  always@(negedge nGrst or posedge clk)
    if(!nGrst) Q <= {WIDTH{1'b0}};
    else
      if(clkEn)
        if(rst)       Q <= {WIDTH{1'b0}};
        else
          if(cntEn)   Q <= Q + 1'b1;
endmodule
/* instance
  fft_inpl_kitCountS # ( .WIDTH(WIDTH), .DCVALUE({WIDTH{1'bx}}),
                .BUILD_DC(0) ) counter_0 (
    .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
    .cntEn(cntEn), .Q(outp), .dc() );
*/

module fft_inpl_counter_w (clk, nGrst, rst, cntEn, tc, tc_r, Q);
  parameter
    WIDTH = 7,
    TC =    127;
  input nGrst, rst;
  input clk, cntEn;
  output tc, tc_r;
  output reg[WIDTH-1:0] Q;
  reg tc, tc_r;

  wire tc_w;

  assign tc_w = (Q==(TC-2));
  always @ (posedge clk or negedge nGrst)
    if(!nGrst) begin
      Q  <= 0;
      tc <= 0;
      tc_r <= 0;
    end
    else
      if(rst) begin
        Q  <= 0;
        tc <= 0;
        tc_r <= 0;
      end
      else
        if(cntEn) begin
          tc_r <= tc;
          tc   <= tc_w;
          if (Q==TC) Q <= 0;
          else       Q <= Q + 1;
        end
endmodule

// binary counter
module fft_inpl_bcounter (clk, nGrst, rst, cntEn, Q);
  parameter WIDTH = 7;

  input clk, cntEn;
  input nGrst, rst;   // async Global & sync resets
  output reg[WIDTH-1:0] Q;

  always @ (posedge clk or negedge nGrst)
    if(!nGrst) Q <= 0;
    else
      if(cntEn)
        if(rst)   Q <= 0;
        else      Q <= Q + 1;
endmodule


//    ########    ########   ##           ###     ##    ##
//    ##     ##   ##         ##          ## ##     ##  ##
//    ##     ##   ##         ##         ##   ##     ####
//    ##     ##   ######     ##        ##     ##     ##
//    ##     ##   ##         ##        #########     ##
//    ##     ##   ##         ##        ##     ##     ##
//    ########    ########   ########  ##     ##     ##

//----------- Register-based 1-bit Delay has only input and output ---------
module fft_inpl_kitDelay_bit_reg(nGrst, rst, clk, clkEn, inp, outp);
  parameter
    DELAY = 2;

  input  nGrst, rst, clk, clkEn;
  input  inp;
  output outp;
  // extra register to avoid error if DELAY==0
  reg delayLine [0:DELAY];
  integer i;

  generate
    if(DELAY==0)
      assign outp = inp;
    else begin
      assign outp = delayLine[DELAY-1];

      always @(posedge clk or negedge nGrst)
        if(!nGrst)
          for(i=0; i<DELAY; i=i+1)         delayLine[i] <= 1'b0;
        else
          if (clkEn)
            if (rst)
              for (i = 0; i<DELAY; i=i+1)  delayLine[i] <= 1'b0;
            else begin
              for(i=DELAY-1; i>=1; i=i-1)  delayLine[i] <= delayLine[i-1];
              delayLine[0] <= inp;
            end  // clkEn
    end
  endgenerate
endmodule
/* Use
fft_inpl_kitDelay_bit_reg # (.DELAY(2)) bit_dly_0
  (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
   .inp(inp),
   .outp(outp) );
*/
//bug12509 ends

//----------- Register-based Multi-bit Delay has only input and output ---------
module fft_inpl_kitDelay_reg(nGrst, rst, clk, clkEn, inp, outp);
  parameter
    BITWIDTH = 16,
    DELAY = 2;

  input  nGrst, rst, clk, clkEn;
  input  [BITWIDTH-1:0] inp;
  output   [BITWIDTH-1:0] outp;
  // extra register to avoid error if DELAY==0
  reg [BITWIDTH-1:0] delayLine [0:DELAY];
  integer i;

  generate
    if(DELAY==0)
      assign outp = inp;
    else begin
      assign outp = delayLine[DELAY-1];

      always @(posedge clk or negedge nGrst)
        if(!nGrst)
          for(i=0; i<DELAY; i=i+1)         delayLine[i] <= 'b0;
        else
          if (clkEn)
            if (rst)
              for (i = 0; i<DELAY; i=i+1)  delayLine[i] <= 'b0;
            else begin
              for(i=DELAY-1; i>=1; i=i-1)  delayLine[i] <= delayLine[i-1];
              delayLine[0] <= inp;
            end  // clkEn
    end
  endgenerate
endmodule
/* Use
  fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), DELAY(1) ) dly_0 (
    .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
    .inp(datain), .outp(dataout)  );
*/


//                     ########      ###     ##     ##
//                     ##     ##    ## ##    ###   ###
//                     ##     ##   ##   ##   #### ####
//                     ########   ##     ##  ## ### ##
//                     ##   ##    #########  ##     ##
//                     ##    ##   ##     ##  ##     ##
//                     ##     ##  ##     ##  ##     ##
//
// --------- Two-port RAM simulation model ----------
module fft_inpl_RAM_two_port (nGrst, RCLOCK, WCLOCK,
       WRB, RDB,
       DI,
       RADDR, WADDR,
       DO       );
  parameter
    BITWIDTH     = 16,
    RAM_LOGDEPTH = 2,
    RAM_PIPE     = 2;
  localparam RAM_DEPTH = 1<<RAM_LOGDEPTH;

  input  nGrst, WCLOCK, RCLOCK;
  input  WRB, RDB;
  input  [BITWIDTH-1:0] DI;
  input  [RAM_LOGDEPTH-1:0] RADDR, WADDR;
  output [BITWIDTH-1:0] DO;

  reg [BITWIDTH-1:0] ramArray [0:RAM_DEPTH-1];
  reg [BITWIDTH-1:0] pipe1, pipe2;
  reg [BITWIDTH-1:0] arrOut;
  integer i;

  assign DO = (RAM_PIPE==2) ? pipe2 : (RAM_PIPE==1)? pipe1 : arrOut;

  // write
  always @(posedge WCLOCK or negedge nGrst)
    if(!nGrst)
      for(i=0; i<RAM_DEPTH; i=i+1)
        ramArray[i] <= 'bx;
    else
      if (WRB) ramArray[WADDR] <= DI;

  // read
  always @(posedge RCLOCK or negedge nGrst)
    if(!nGrst) begin
      pipe2   <= 'b0;
      pipe1   <= 'b0;
    end
    else begin
      if (RDB) arrOut <= ramArray[RADDR];
      else     arrOut <= 'bx;
      pipe2 <= pipe1;
      pipe1 <= arrOut;
    end
endmodule


// -----------------------  Simple Round Up: 1-clk delay  ----------------------
// ---------- Use it when it is known INBITWIDTH > OUTBITWIDTH -----------------
// Partially truncated input comes in: LSB's are truncated but one extra bit
// retained

module fft_inpl_kitRndUp (nGrst, rst, clk, clkEn, inp, valInp, outp, valOutp);
  parameter WIDTH_OUT = 12;
  parameter RND_MODE  = 0;

  input nGrst, rst, clk, clkEn, valInp;
  input[WIDTH_OUT:0] inp;
  output valOutp;
  output [WIDTH_OUT-1:0] outp;
  reg valOutp;
  reg [WIDTH_OUT-1:0] outp;

  wire[WIDTH_OUT:0] outp_int;

  assign outp_int = inp[WIDTH_OUT:0] + 'd1;

  always @(posedge clk or negedge nGrst)
    if(!nGrst) begin
      outp    <= 'b0;
      valOutp <= 1'b0;
    end
    else
      if(clkEn)
        if (rst) begin
          outp    <= 'b0;
          valOutp <= 1'b0;
        end
        else begin
          if(RND_MODE) outp <= outp_int[WIDTH_OUT:1];
          else         outp <= inp[WIDTH_OUT:1];          //?
          valOutp <= valInp;
        end
endmodule

// Result: Resizes the vector inp to the specified size.
// To create a larger vector, the new [leftmost] bit positions are filled
// with the sign bit (if UNSIGNED==0) or 0's (if UNSIGNED==1).
// When truncating, the sign bit is retained along with the rightmost part
// (if UNSIGNED==0), or the leftmost bits are all dropped (if UNSIGNED==1)
module fft_inpl_signExt (inp, outp);
  parameter INWIDTH = 16;
  parameter OUTWIDTH = 20;
  parameter UNSIGNED = 0;   // 0-signed conversion; 1-unsigned

  input [INWIDTH-1:0] inp;
  output[OUTWIDTH-1:0] outp;

  generate
    if(INWIDTH >= OUTWIDTH) begin
      assign outp[OUTWIDTH-1] = UNSIGNED ? inp[OUTWIDTH-1] : inp[INWIDTH-1];
      assign outp[OUTWIDTH-2:0] = inp[OUTWIDTH-2:0];
    end
    else
      assign outp = UNSIGNED ?  {{(OUTWIDTH-INWIDTH){1'b0}}, inp} :
                                {{(OUTWIDTH-INWIDTH){inp[INWIDTH-1]}}, inp};
  endgenerate
endmodule
/* usage:
  fft_inpl_signExt # ( .INWIDTH(DATA_WIDTH),
              .OUTWIDTH(DATA_WIDTH_MAC),
              .UNSIGNED(UNSIGNED)) signExt_0 (
    .inp(data), .outp(data2mac)   );
*/
//            ____   _    _                    __  _                 _
//           / __ \ | |  | |                  / _|(_)               | |
//          | |  | || |_ | |__    ___  _ __  | |_  _ __  __ ___   __| |
//          | |  | || __|| '_ \  / _ \| '__| |  _|| |\ \/ // _ \ / _` |
//          | |__| || |_ | | | ||  __/| |    | |  | | >  <|  __/| (_| |
//           \____/  \__||_| |_| \___||_|    |_|  |_|/_/\_\\___| \__,_|
//                                        _         _
//                                       | |       | |
//                  _ __ ___    ___    __| | _   _ | |  ___  ___
//                 | '_ ` _ \  / _ \  / _` || | | || | / _ \/ __|
//                 | | | | | || (_) || (_| || |_| || ||  __/\__ \
//                 |_| |_| |_| \___/  \__,_| \__,_||_| \___||___/
//

//rt
// Asynchronous global reset synchronizer generates a 1 or 2-clk wide sync'ed 
// pulse on rising edge of the async reset
module fft_inpl_kitSync_ngrst (nGrst, clk, pulse);
  parameter PULSE_WIDTH = 1;
  
  input nGrst, clk;
  output pulse;
  
  reg pulse; 
  reg tick1, tick2;
  wire synced_ngrst, pulsei;

  // Synchronize nGrst
  fft_inpl_kitDelay_bit_reg # (.DELAY(4)) sync_ngrst_0 (
    .nGrst(nGrst), .rst(1'b0), .clk(clk), .clkEn(1'b1),
    .inp(1'b1), .outp(synced_ngrst) ) ;
  
  always @ (posedge clk)
    tick1 <= synced_ngrst;

  generate if (PULSE_WIDTH==2) 
    begin: two_clk
      always @ (posedge clk)
        tick2 <= tick1;
    
      assign pulsei = synced_ngrst & ~tick2;    
    end
  endgenerate
  
  generate if (PULSE_WIDTH!=2) 
    begin: one_clk
      assign pulsei = synced_ngrst & ~tick1;    
    end
  endgenerate
  
  always @ (posedge clk)
    pulse <= pulsei;

endmodule  
//rt ends


module fft_inpl_slowClock (clk, ifiNreset, slowClk);
  localparam DIVIDE = 3;    // Divide by 2^DIVIDE
  input clk, ifiNreset;   // async global reset
  output slowClk;

  reg[DIVIDE-1:0] divider;
  assign slowClk = ~divider[DIVIDE-1];

  always @ (posedge clk or negedge ifiNreset) begin
    if (!ifiNreset)       divider <= 'b0;
    else                  divider <= divider + 'b1;
  end
endmodule


module fft_inpl_switch(clk, inP, inQ, sel, outP, outQ, validIn, validOut);
  parameter DWIDTH = 32;

  input clk, validIn;
  input [DWIDTH-1:0] inP, inQ;
  input sel;
  output [DWIDTH-1:0] outP, outQ;
  output validOut;
  reg[DWIDTH-1:0] outP, outQ;
  reg validOut;

  reg[DWIDTH-1:0] leftQ_r, rightP_r;
  reg pipe1;
  wire[DWIDTH-1:0] muxP_w, muxQ_w;

  assign muxP_w =  sel ? leftQ_r : inP;
  assign muxQ_w = ~sel ? leftQ_r : inP;

  always @ (posedge clk)
    begin
      outP <= rightP_r;
      outQ <= muxQ_w;
      leftQ_r <= inQ;
      rightP_r <= muxP_w;
      validOut <= pipe1;
      pipe1 <= validIn;
    end
endmodule


//      ########   ########  ##       ##    ##
//      ##     ##  ##        ##        ##  ##
//      ##     ##  ##        ##         ####
//      ########   ######    ##          ##
//      ##     ##  ##        ##          ##
//      ##     ##  ##        ##          ##
//      ########   ##        ########    ##


module fft_inpl_bfly2 (clk, upScale, inP, inQ, T, outP, outQ,
              validIn, validOut, swCrossIn, swCrossOut);
  parameter WIDTH     = 16;
  parameter TWIDTH    = 16;
  parameter DWIDTH    = 32;
  parameter TDWIDTH   = 32;
  parameter MPIPE     = 5;
  parameter FPGA_FAMILY = 12;

  input clk;
  //Signals need to be delayed by the bfly latency. That's why they are here
  input validIn, swCrossIn;
  input upScale;     // don't do downscaling if upScale==1
  input [DWIDTH-1:0] inQ, inP;
  input [TDWIDTH-1:0] T;
  output [DWIDTH-1:0] outP, outQ;
  output validOut, swCrossOut;
  reg [DWIDTH-1:0] outP, outQ;

  // CONVENTION: real - LSBs[WIDTH-1:0], imag - MSBs[DWIDTH-1:WIDTH]
  wire [WIDTH-1:0] inPr_w, inPi_w, inQr_w, inQi_w;
  wire [WIDTH-1:0] inPr_dly, inPi_dly;
  wire [TWIDTH-1:0] Tr_w  = T[TWIDTH-1:0];
  wire [TWIDTH-1:0] Ti_w  = T[TDWIDTH-1:TWIDTH];
  wire [WIDTH-1:0] Hr, Hi;

  wire [1:0] ctrl = {validIn, swCrossIn};
  wire [1:0] ctrl_dly;

  // select either 16-bit value or sign-extended 15-bit value (downscaled one)
  assign inPr_w =upScale ?
          inP[WIDTH-1:0] : {inP[WIDTH-1], inP[WIDTH-1:1]};
  assign inPi_w =upScale ?
          inP[DWIDTH-1:WIDTH] : {inP[DWIDTH-1],inP[DWIDTH-1:WIDTH+1]};

  // select either 16-bit value or left-shifted value (upscaled one)
  assign inQr_w =upScale ? {inQ[WIDTH-2:0], 1'b0} : inQ[WIDTH-1:0];
  assign inQi_w =upScale ? {inQ[DWIDTH-2:WIDTH], 1'b0} : inQ[DWIDTH-1:WIDTH];

  assign validOut = ctrl_dly[1];
  assign swCrossOut = ctrl_dly[0];

  fft_inpl_cmplx_rnd # (.WIDTH(WIDTH), .NOPIPE(0),
               .FPGA_FAMILY(FPGA_FAMILY) ) cmplx_0 (
      .nGrst(1'b1), .rst(1'b0), .clk(clk), .clkEn(1'b1),
      .Qi(inQi_w), .Qr(inQr_w), .Ti(Ti_w), .Tr(Tr_w),
      .Hi(Hi), .Hr(Hr) );

  // Delay inP to compensate for the cmplx multiplier delay
  fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), .DELAY(MPIPE+1) ) inPr_dly_0 (
    .nGrst(1'b1), .rst(1'b0), .clk(clk), .clkEn(1'b1),
    .inp(inPr_w), .outp(inPr_dly) );

  fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), .DELAY(MPIPE+1) ) inPi_dly_0 (
    .nGrst(1'b1), .rst(1'b0), .clk(clk), .clkEn(1'b1),
    .inp(inPi_w), .outp(inPi_dly) );

  fft_inpl_kitDelay_reg # (.BITWIDTH(2), .DELAY(MPIPE+2) ) ctrl_dly_0 (
    .nGrst(1'b1), .rst(1'b0), .clk(clk), .clkEn(1'b1),
    .inp(ctrl), .outp(ctrl_dly) );

  always @ (posedge clk)
    begin
      outQ[DWIDTH-1:WIDTH]  <= (inPi_dly - Hi);
      outQ[WIDTH-1:0]       <= (inPr_dly - Hr);
      outP[DWIDTH-1:WIDTH]  <= (inPi_dly + Hi);
      outP[WIDTH-1:0]       <= (inPr_dly + Hr);
    end
endmodule


module fft_inpl_autoScale (clk,
                  ldRiskOV, bflyRiskOV, startLoad,
                  startFFT, bflyOutValid, wLastStage,
                  fftRd_done_tick,
                  datai_valid, upScale,
                  scale_exp);
  parameter SCALE_MODE   = 0;   // autoscaling ON
  parameter SCALE_EXP_ON = 0; // 1-build scaling exponent
  parameter LOGLOGPTS    = 3;
  parameter MEMBUF       = 0;

  input clk;
  input ldRiskOV, bflyRiskOV;
  input startLoad, startFFT, bflyOutValid, wLastStage;
  input fftRd_done_tick;
  input datai_valid;
  output upScale;
  output [LOGLOGPTS-1:0] scale_exp;
  reg upScale;

  reg [LOGLOGPTS-1:0] scale_exp_r, scale_exp_count;
  reg ldMonitor, bflyMonitor;
  wire stageEnd_w;

  fft_inpl_kitEdge # (.FRONT_EDGE(0)) edge_detect_0 (
     .nGrst(1'b1), .rst(1'b0), .clk(clk),
     .inp(bflyOutValid&(!wLastStage)),
     .outp(stageEnd_w) );

  always @ (posedge clk) begin
    // Set ldMonitor if Autoscaling is ON.  Otherwise keep it = 0.
    if(startLoad)   ldMonitor <= 1-SCALE_MODE;
    else    // Monitor the data being loaded: reset ldMonitor if any valid
            // input data violates the condition
      if(ldRiskOV & datai_valid) ldMonitor <= 1'b0;

    // monitor the data being FFT'ed
    if(bflyRiskOV & bflyOutValid) bflyMonitor <= 1'b0;

    //check ldMonitor on startFFT (startFFT coinsides with the next startLoad)
    if(startFFT) begin
      upScale <= ldMonitor;
      // Set monitor if Autoscaling is ON (SCALE_MODE==0).
      bflyMonitor <= 1-SCALE_MODE;
    end
    else
    // Check the bflyMonitor at a stage end except the last stage, since the
    // end of the last stage may come on or even after the startFFT signal
    // when the upScale is supposed to check the ldMonitor only
      if(stageEnd_w) begin
        upScale <= bflyMonitor;
        // Initialize monitor at the beginning of every stage
        bflyMonitor <= 1-SCALE_MODE;
      end
  end

  generate
    if(SCALE_EXP_ON==1)
      always @ (posedge clk) begin
        if(startFFT==1'b1)
          if(ldMonitor==1'b0)
            scale_exp_count <= 'b1;
          else
            scale_exp_count <= 'b0;
        else
          if(~bflyMonitor & stageEnd_w)
            scale_exp_count <= scale_exp_count+1;
      end
  endgenerate

  generate        // use in Buffered mode only
    if( (SCALE_EXP_ON==1) && (MEMBUF==1) )
      always @ (posedge clk)
        if(fftRd_done_tick==1'b1)
          scale_exp_r     <= scale_exp_count;
  endgenerate

  generate
    if(MEMBUF==1)
      assign scale_exp = scale_exp_r;
    else
      assign scale_exp = scale_exp_count;
  endgenerate
endmodule
