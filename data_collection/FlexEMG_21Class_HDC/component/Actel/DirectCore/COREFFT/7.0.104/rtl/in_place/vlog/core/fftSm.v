// ***************************************************************************/
//Actel Corporation Proprietary and Confidential
//Copyright 2009 Actel Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT
//              State Machine and Control modules
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

/***********************************  SM TOP  *********************************/
module fft_inpl_sm_top (clk, clkEn,
  slowClk,
  nGrst,
  ifiD_valid,
  ifiRead_y,
  ldA, wEn_even, wEn_odd,  // out; inBuf loading group
  rA, wA, inBuf_wEn, inBuf_rdValid, // out; inBuf processing group
  tA, twid_wA, twid_wEn,
  outBuf_wA, outBuf_wEn, outBuf_rA,
  preSwCross,     // out; pre-bfly switch control
  smPong,
  wLastStage,     // out; write back to in-place RAM: last stage
  fftRd_done_tick,
  smStartFFT,     // out; SM starts FFTing after clearing all conditions
  smStartLoad,    // out; inBuf is ready for another data load
  ifoLoad,        // out; inBuf can accept fresh data
  ifoY_valid,     // out; FFT'ed data sample valid
  ifoY_rdy);      // out; FFT results are ready
  parameter PTS       = 256;
  parameter HALFPTS   = 128;
  parameter LOGPTS    = 8;
  parameter LOGLOGPTS = 3;
  parameter RW_DLY    = 12;
  parameter MEMBUF    = 0;

  input clk, clkEn, slowClk;
  input nGrst;
  input ifiD_valid, ifiRead_y;

  output [LOGPTS-2:0] ldA, rA, wA, tA, twid_wA;
  output [LOGPTS-2:0] outBuf_wA;
  output [LOGPTS-1:0] outBuf_rA;
  output wEn_even, wEn_odd;
  output preSwCross;
  output twid_wEn;
  output inBuf_wEn, outBuf_wEn, smPong;
  output inBuf_rdValid, wLastStage;
  output smStartFFT;
  output smStartLoad;
  output ifoLoad, ifoY_valid, ifoY_rdy;
  output fftRd_done_tick;
  reg    fftRd_done_tick;
  reg    inBuf_wEn, outBuf_wEn, smStartLoad;
  reg    smPong /*synthesis syn_repicate = 1 */ ;

  wire [LOGPTS+1:0]     rTimer, rTimer_t2;
  wire [LOGPTS-2:0]     wTimer_w, wTimer_t2;
  wire [LOGLOGPTS+1:0]  rStage_w, rStage_t2;
  reg  [LOGLOGPTS-1:0]  wStage_r;
  wire [LOGLOGPTS-1:0]  wStage_t2;
  wire smStartLoad_w;
  wire rLastStage_t2;
  wire load_done_w, sync_rAwA_w, fftRd_done_w;
  reg preInBuf_wEn, preOutBuf_wEn, trueRst;
  reg smBuf_full;   // inBuf is full: FFT processing session can start
  reg smFft_rdy;    // FFT engine is idle = available for processing
  reg smFft_run;    // FFT engine is busy

  wire sync_rAwA, pre2_sync_rAwA;
  reg outBuf_wEn_frEdge;
  // Reset logic:
  // - On nGrst start one-time loading twidLUT
  // - After load is over, assert short rstAfterInit
  wire rstAfterInit;
  wire trueRst_w;

  wire Y_rdy_rearEdge, rst_rTimer;
  wire [LOGPTS-2:0] rAi;
  wire outBuf_rA_valid;

  reg rTimerTC_tick;
  wire rTimerTC;
  wire smStartFFT_g4;
  wire rst_wTimer;                                                  

  // ----------------------  Upper SM  ------------------------
  // ------------ Start FFTing when inBuf full AND fft engine is idle
  assign smStartFFT = MEMBUF ? (smBuf_full & smFft_rdy) : load_done_w;

  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) startFFT_g4_dly_0
    (.nGrst(nGrst), .rst(1'b0), .clk(clk), .clkEn(clkEn),           
      .inp(smStartFFT),
      .outp(smStartFFT_g4) );

  // ------------ Start loading fresh data depending on buffer scheme
  assign smStartLoad_w = MEMBUF ? (trueRst_w | smStartFFT) :
                                  (trueRst_w | Y_rdy_rearEdge) ;

  // rear edge of the ifoY_rdy
  fft_inpl_kitEdge # (.FRONT_EDGE(0)) edge_detect_0 (
     .nGrst(1'b1), .rst(1'b0), .clk(clk),
     .inp(ifoY_rdy),
     .outp(Y_rdy_rearEdge) );

  // FFT read inBuf timer
  assign rst_rTimer = MEMBUF ? trueRst : (trueRst | ifoLoad);
  fft_inpl_rdFFTtimer # (.HALFPTS(HALFPTS), .LOGPTS(LOGPTS),
                .LOGLOGPTS(LOGLOGPTS), .RW_DLY(RW_DLY),
                .MEMBUF(MEMBUF) ) rdFFTtimer_0  (
         .clk(clk),
         .nGrst(nGrst),
         .rst(rst_rTimer),
         .smStartFFT(smStartFFT),
         .smFft_run(smFft_run),
         .rTimer(rTimer),
         .timerTC(rTimerTC),
         .rStage(rStage_w),
         .rLastStage(rLastStage_t2),
         .fftRd_done(fftRd_done_w),
         .rValid(inBuf_rdValid));


  fft_inpl_kitDelay_reg # (.BITWIDTH(LOGPTS+2), .DELAY(2) ) rTimer_dly2 (
    .nGrst(nGrst), 
    .rst(1'b0), 
    .clk(clk), .clkEn(1'b1),
    .inp(rTimer), .outp(rTimer_t2)  );


  fft_inpl_kitDelay_reg # (.BITWIDTH(LOGLOGPTS+2), .DELAY(2) ) rStage_dly2 (
    .nGrst(nGrst), 
    .rst(1'b0), 
    .clk(clk), .clkEn(1'b1),
    .inp(rStage_w), .outp(rStage_t2)  );

  assign sync_rAwA_w = (rTimer == RW_DLY-1);

  fft_inpl_kitDelay_bit_reg # (.DELAY(1)) pre2_sync_rw_0   ( 
    .nGrst(nGrst), 
    .rst(1'b0), 
    .clk(clk), .clkEn(clkEn),
    .inp(sync_rAwA_w),
    .outp(pre2_sync_rAwA) );

  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) sync_rw_1    (
    .nGrst(nGrst), 
    .rst(1'b0), 
    .clk(clk), .clkEn(clkEn),
    .inp(pre2_sync_rAwA),
    .outp(sync_rAwA) );

  //SPEED
  assign rst_wTimer = twid_wEn | pre2_sync_rAwA | smStartFFT; 
  fft_inpl_kitCountS # ( .WIDTH(LOGPTS-1), .BUILD_DC(0) ) wTimer_0 (
    .nGrst(nGrst),
    .rst(rst_wTimer),
    .clk(clk), .clkEn(1'b1), .cntEn(1'b1),
    .Q(wTimer_w), .dc() );


  fft_inpl_kitDelay_reg # (.BITWIDTH(LOGPTS-1), .DELAY(2) ) wTimer_dly_2 (
    .nGrst(nGrst), 
    .rst(1'b0), 
    .clk(clk), .clkEn(1'b1),
    .inp(wTimer_w), .outp(wTimer_t2)  );

  fft_inpl_kitDelay_reg #(.BITWIDTH(1), .DELAY(RW_DLY)) rw_dly_lastStage (
    .nGrst(nGrst),
    .rst(trueRst),
    .clk(clk), .clkEn(clkEn),
    .inp(rLastStage_t2), .outp(wLastStage)  );

  fft_inpl_inBuf_ldA #(.PTS(PTS), .LOGPTS(LOGPTS)) inBuf_ldA_0 (
    .clk(clk), .clkEn(clkEn),
    .nGrst(nGrst),
    .startLoad(smStartLoad),
    //inData strobe
    .ifiD_valid(ifiD_valid),
    //out; inBuf is ready for new data (PTS new samples)
    .ifoLoad(ifoLoad),
    //out; tells topSM the buffer is fully loaded and ready for FFTing
    .load_done(load_done_w),
    .ldA(ldA), .wEn_even(wEn_even), .wEn_odd(wEn_odd) );


  fft_inpl_inBuf_fftA_pipe #(.LOGPTS(LOGPTS), .LOGLOGPTS(LOGLOGPTS) ) inBuf_rA_0
   (.clk(clk), .clkEn(clkEn),
    .timer(rTimer[LOGPTS-2:0]),
    .stage(rStage_w[LOGLOGPTS-1:0]),
    .lastStage(rLastStage_t2),
    .bflyA(rAi),
    .swCross(preSwCross));

  assign rA = MEMBUF ? rAi : (
                   (outBuf_rA_valid==1'b0) ? rAi : outBuf_rA[LOGPTS-2:0] );

  fft_inpl_twid_rA #(.LOGPTS(LOGPTS), .LOGLOGPTS(LOGLOGPTS) ) twid_rA_0  (
      .clk(clk),
      .timer(rTimer_t2[LOGPTS-2:0]),
      .stage(rStage_t2[LOGLOGPTS-1:0]),
      .tA(tA));

  // Twiddle LUT initialization
  fft_inpl_twid_wA_gen #(.LOGPTS(LOGPTS), .LOGLOGPTS(LOGLOGPTS) ) twid_wA_0
      ( .slowClk(slowClk), .nGrst(nGrst),
        .twid_wA(twid_wA), .twid_wEn(twid_wEn),
        .rstAfterInit(rstAfterInit));

  // Return slowClk domain signal rstAfterInit back to clk domain
  fft_inpl_kitEdge # (.FRONT_EDGE(0)) init_rear_0 (
     .nGrst(nGrst), .rst(1'b0), .clk(clk),
     .inp(rstAfterInit),
     .outp(trueRst_w) );


  fft_inpl_kitDelay_reg # (.BITWIDTH(LOGLOGPTS), .DELAY(2) ) wStage_dly_2 (
    .nGrst(nGrst), 
    .rst(1'b0), 
    .clk(clk), .clkEn(1'b1),
    .inp(wStage_r), .outp(wStage_t2)  );

  // wA generator.  On the last stage the fftRd_done comes before the last
  // FFT results get written back to the inBuf, but it is not necessary since
  // the results get written into the output buffer.

  fft_inpl_inBuf_fftA_pipe #(.LOGPTS(LOGPTS), .LOGLOGPTS(LOGLOGPTS) ) inBuf_wA_0
   (.clk(clk), .clkEn(clkEn),
    .timer(wTimer_w),
    .stage(wStage_r),
    .lastStage(1'b0),
    .bflyA(wA),
    .swCross());

  fft_inpl_outBufA #(.PTS(PTS), .LOGPTS(LOGPTS), .MEMBUF(MEMBUF) ) outBufA_0
   (.clk(clk), .clkEn(clkEn),
    .nGrst(nGrst),
    .rst(trueRst),
    .timer(wTimer_t2),
    .outBuf_wEn_frEdge(outBuf_wEn_frEdge),
    .ifiRead_y(ifiRead_y),
    .outBuf_wA(outBuf_wA), .outBuf_rA(outBuf_rA),
    .outBuf_rA_valid(outBuf_rA_valid),
    .rTimerTC_tick(rTimerTC_tick),
    .fftRd_done(fftRd_done_w),
    .ifoY_rdy(ifoY_rdy), .ifoY_valid(ifoY_valid));

  always @ (posedge clk) begin    // pipes
    trueRst       <= trueRst_w;
    smStartLoad   <= smStartLoad_w;
    inBuf_wEn     <= preInBuf_wEn;
    outBuf_wEn    <= preOutBuf_wEn;
    rTimerTC_tick <= rTimerTC;
    fftRd_done_tick <= fftRd_done_w;
  end

  always @ (posedge clk or negedge nGrst) begin
    if(nGrst==1'b0) begin
      smBuf_full    <= 1'b0;
      smFft_rdy     <= 1'b0;
      smFft_run     <= 1'b0;
      smPong        <= 1'b1;
      preInBuf_wEn  <= 1'b0;
      preOutBuf_wEn <= 1'b0;
      wStage_r      <= 'b0;
      outBuf_wEn_frEdge <= 1'b0;
    end
    else
      if(twid_wEn==1'b1) begin 
        smBuf_full    <= 1'b0;
        smFft_rdy     <= 1'b0;
        smFft_run     <= 1'b0;
        smPong        <= 1'b1;
        preInBuf_wEn  <= 1'b0;
        preOutBuf_wEn <= 1'b0;
        wStage_r      <= 'b0;
        outBuf_wEn_frEdge <= 1'b0;
      end                      
      else begin  //mark A
        if (trueRst) begin
          smBuf_full    <= 1'b0;
          smFft_rdy     <= 1'b1;
          smFft_run     <= 1'b0;
          smPong        <= 1'b1;
          preInBuf_wEn  <= 1'b0;
          preOutBuf_wEn <= 1'b0;
          wStage_r      <= 'b0;
          outBuf_wEn_frEdge <= 1'b0;
        end
        else begin  // mark B
          outBuf_wEn_frEdge <= sync_rAwA & rLastStage_t2;

          if (load_done_w) smBuf_full <= 1;

          if (fftRd_done_w) begin
            smFft_rdy <= 1;
            smFft_run <= 0;
          end

          if (smStartFFT) begin
            smBuf_full  <= 0;
            smFft_rdy   <= 0;
            if(MEMBUF)  smPong <= ~smPong;
            else        smPong <= 1'b1;
          end

          if (smStartFFT_g4) begin
            smFft_run  <= 1;
          end

          if(pre2_sync_rAwA)
            wStage_r    <= rStage_t2[LOGLOGPTS-1:0];

          if(sync_rAwA) begin
            if(rLastStage_t2)      preOutBuf_wEn <= 1;
            if( (MEMBUF && (!rLastStage_t2)) || (!MEMBUF) )
              if(smFft_run)   preInBuf_wEn <= 1;
          end
          else begin
            if(rTimerTC_tick) begin
              preInBuf_wEn <= 0;
              preOutBuf_wEn <= 0;
            end
          end
        end  // mark B
      end // mark A
  end  // always

endmodule

//     _______          __  _______ _
//    |  __ \ \        / / |__   __(_)
//    | |__) \ \  /\  / /     | |   _ _ __ ___   ___ _ __ ___
//    |  _  / \ \/  \/ /      | |  | | '_ ` _ \ / _ \ '__/ __|
//    | | \ \  \  /\  /       | |  | | | | | | |  __/ |  \__ \
//    |_|  \_\  \/  \/        |_|  |_|_| |_| |_|\___|_|  |___/

/**************************  READ inBuf SEQUENCER  ****************************/
// Once FFT computation starts, it runs for a number of stages.  Every stage
// takes HALFPTS + RW_DLY clk for the inBuf to write Bfly results back
// in-place before a next stage starts (RW_DLY - datapath delay thru
// bfly and switch.  Cannot start another stage until current results are back
// to the in-place RAM.
module fft_inpl_rdFFTtimer (nGrst, rst, clk,
  smStartFFT,   // in; comes from topSm when it concludes the way is cleared
  smFft_run,    // in; from topSM: FFT processing in progress
  fftRd_done,
  rLastStage,
  rStage,
  rTimer,
  timerTC,
  rValid);
  parameter HALFPTS   = 128;
  parameter LOGPTS  = 8;
  parameter LOGLOGPTS  = 3;
  parameter RW_DLY = 12;
  parameter MEMBUF = 0;

  input clk, rst, nGrst;
  input smStartFFT, smFft_run;
  output rLastStage;  // terminal counts of rA and stage
  output[LOGLOGPTS+1:0] rStage;
  output[LOGPTS+1:0] rTimer;
  output timerTC;
  output fftRd_done, rValid;
  reg fftRd_done_r;
  reg [LOGLOGPTS+1:0] rStage_r;

  wire fftDone_w;
  reg preRdValid;     //r-s flop
  wire timerTCi, rLastStage_w, ce_rTimer;
  wire [LOGLOGPTS+1:0] rStage_w;
  reg rLastStage_r;

  wire [LOGPTS+1:0] rTimeri;
  wire timerTC_r, rValid_r;

  wire startFFT_tick2;

  assign rStage = rStage_r;
  assign rTimer = rTimeri;

  //g4 Delays
  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) bit_dly_2
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(1'b1),
    .inp(rLastStage_r),
    .outp(rLastStage) );
  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) bit_dly_3
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(1'b1),
    .inp(timerTC_r),
    .outp(timerTC) );
  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) bit_dly_4
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(1'b1),
    .inp(fftRd_done_r),
    .outp(fftRd_done) );
  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) bit_dly_5
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(1'b1),
    .inp(rValid_r),
    .outp(rValid) );

  fft_inpl_kitDelay_bit_reg # (.DELAY(2)) startFFT_dly_0
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(1'b1),
    .inp(smStartFFT),
    .outp(startFFT_tick2) );

  // To prevent fake ifoY_rdy and ifoY_valid caused by fftRd_done,
  // do not let rdFFTTimer run outside smFft_run
  assign ce_rTimer = smFft_run | smStartFFT;

  // counts pair of samples read.  There are PTS/2 pairs
  fft_inpl_counter_w #(.WIDTH(LOGPTS+2), .TC(HALFPTS+RW_DLY-1)) rA_timer (.clk(clk),
    .nGrst(nGrst), .rst(rst|smStartFFT), .cntEn(ce_rTimer), .tc_r(timerTC_r),
    .tc(timerTCi), .Q(rTimeri) );

  // counts stages
  fft_inpl_counter #(.WIDTH(LOGLOGPTS+2), .TC(LOGPTS-1)) stage_timer (.clk(clk),
    .nGrst(nGrst), .rst(rst|smStartFFT), .cntEn(timerTCi), .tc(rLastStage_w),
    .Q(rStage_w));

  assign fftDone_w = rLastStage_r & timerTC_r;

  always @ (posedge clk or negedge nGrst) begin
    if(nGrst==1'b0) begin
      preRdValid    <= 1'b0;
      fftRd_done_r  <= 1'b0;
      rStage_r      <= 'b0;
      rLastStage_r  <= 1'b0;
    end
    else
      if (rst==1'b1)  begin
        preRdValid    <= 1'b0;
        fftRd_done_r  <= 1'b0;
        rStage_r      <= 'b0;
        rLastStage_r  <= 1'b0;
      end                  
      else begin
        rStage_r      <= rStage_w;
        rLastStage_r  <= rLastStage_w;
        fftRd_done_r  <= fftDone_w;
        // on startFFT the valid reading session always starts
        if (startFFT_tick2) preRdValid <= 1'b1;
        else if(ce_rTimer) begin
          if (rTimeri==HALFPTS-1) preRdValid <= 1'b0;
          // reading session starts on rTimerTC except after the lastStage
          if ((!rLastStage_r) & timerTC_r & smFft_run) preRdValid <= 1'b1;
        end
      end
  end

  fft_inpl_kitDelay_bit_reg # (.DELAY(3)) bit_dly_0
    (.nGrst(1'b1), .rst(1'b0), .clk(clk), .clkEn(1'b1),
     .inp(preRdValid),
     .outp(rValid_r) );
endmodule

//                 _     _         _____
//        /\      | |   | |       / ____|
//       /  \   __| | __| |_ __  | |  __  ___ _ __
//      / /\ \ / _` |/ _` | '__| | | |_ |/ _ \ '_ \
//     / ____ \ (_| | (_| | |    | |__| |  __/ | | |
//    /_/    \_\__,_|\__,_|_|     \_____|\___|_| |_|

//********************** inBuf LOAD ADDRESS GENERATOR **********************/
module fft_inpl_inBuf_ldA (nGrst, clk, clkEn,
  startLoad,    // comes from topSM to start another loading cycle
  ifiD_valid,   // input data valid
  ifoLoad,      // tells user it is OK to keep loading: inBuf isn't full
  load_done,    // tells topSm the inbuf is full and ready for FFTing
  ldA,          // inBuf wA
  wEn_even,     // inBuf has two RAM's: even & odd as bfly takes 2 samples/clock
  wEn_odd );

  parameter PTS   = 256;
  parameter LOGPTS  = 8;

  input nGrst, clk, clkEn;
  input startLoad, ifiD_valid;
  output[LOGPTS-1:1] ldA;
  output ifoLoad, load_done, wEn_even, wEn_odd;
  reg ifoLoad;
  reg load_done;

  wire ldCountLsb;  // mark even/odd samples
  wire closeLoad_w, loadOver_w;
  wire load_over;       //g4
  wire ldValid;

  assign loadOver_w = closeLoad_w & ifiD_valid;
  assign ldValid    = ifoLoad & ifiD_valid;
  assign wEn_even   = ~ldCountLsb & ldValid;
  assign wEn_odd    =  ldCountLsb & ldValid;

  // Count samples loaded.  There is PTS samples to load, not PTS/2
  fft_inpl_counter #(.WIDTH(LOGPTS), .TC(PTS-1)) ldCount (.clk(clk),
    .nGrst(nGrst), .rst(startLoad), .cntEn(ifiD_valid), .tc(closeLoad_w),
    .Q({ldA, ldCountLsb}));

  always @ (posedge clk or negedge nGrst)
    if(!nGrst) begin
      ifoLoad   <= 1'b0;
      load_done <= 1'b0;
    end
    else begin
      load_done <= loadOver_w;
      if (loadOver_w)   ifoLoad <= 1'b0;
      else
        if (startLoad)  ifoLoad <= 1'b1;
    end
endmodule


/*************************  outBuf ADDRESS GENERATOR  *************************/
// Writes data in normal order, reads in bit-reversed.
// Write address is based on the same timer as inBuf wA
module fft_inpl_outBufA (nGrst, rst, clk, clkEn,
  timer,      // topSM counter synchronizes addr gens
  outBuf_wEn_frEdge,  // topSM supplies the signal
  ifoY_rdy,   // goes active after writing session
  outBuf_rA_valid,  // in min config, use outBuf rA to read in-place RAM
  ifiRead_y,        // host can slow down reading outBuf by lowering it
  outBuf_wA, outBuf_rA,
  rTimerTC_tick,
  fftRd_done,
  ifoY_valid);     // marks valid read data
  parameter PTS   = 256;
  parameter LOGPTS  = 8;
  parameter MEMBUF  = 0;

  input nGrst, rst, clk, clkEn;
  input[LOGPTS-2:0] timer;
  input outBuf_wEn_frEdge, ifiRead_y;
  input rTimerTC_tick;
  input fftRd_done;
  output [LOGPTS-2:0] outBuf_wA;
  output [LOGPTS-1:0] outBuf_rA;
  output ifoY_rdy, ifoY_valid;
  output outBuf_rA_valid;
  reg[LOGPTS-2:0] outBuf_wA;
  reg outBuf_rA_valid;    //FF

  wire last_readout;
  wire count_tc;
  reg rdCtl_reg;
  wire [LOGPTS-1:0] rA_straight;
  wire rstRdA_tick;

  fft_inpl_kitDelay_bit_reg # (.DELAY(1)) bit_dly_2
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
     .inp(fftRd_done),      // Reset outBuf_rA after write session
     .outp(rstRdA_tick) );

  // Read addr counter
  fft_inpl_counter #(.WIDTH(LOGPTS), .TC(PTS-1)) outBuf_rA_0 (.clk(clk), .nGrst(nGrst),
    .rst(rst|rstRdA_tick),
    .cntEn(rdCtl_reg),
    .tc(count_tc),
    .Q(rA_straight));
  assign outBuf_rA = {rA_straight[LOGPTS-1], reverse(rA_straight[LOGPTS-2:0])};

  fft_inpl_kitDelay_bit_reg # (.DELAY(3)) bit_dly_0
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
     .inp(outBuf_rA_valid),
     .outp(ifoY_rdy) );

  fft_inpl_kitDelay_bit_reg # (.DELAY(3)) bit_dly_1
    (.nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
     .inp(outBuf_rA_valid & rdCtl_reg),
     .outp(ifoY_valid) );

  // If READ_OUTP (ifiRead_y) isn't permanently asserted, last_readout must be
  // as follows to assure all output samples are accompanied by ifoY_valid.
  assign last_readout = count_tc & rdCtl_reg;

  always @ (posedge clk or negedge nGrst) begin
    if(!nGrst) begin
      outBuf_rA_valid   <= 1'b0;
      outBuf_wA         <= 'b0;
      rdCtl_reg         <= 1'b0;
    end
    else begin
      // reset flop on write session and after reading
      // In buffered mode stop outBuf_rA_valid and consequently ifoY_rdy and
      // ifoY_valid on the last stage (when engine writes results in outp
      // buffer).  The engine has priority so it writes over the older results
      if (rst||fftRd_done||(last_readout&&outBuf_rA_valid)||
          (outBuf_wEn_frEdge && MEMBUF) )  outBuf_rA_valid <= 1'b0;
      else // set it after write session
        if (rstRdA_tick)      outBuf_rA_valid <= 1'b1;
      outBuf_wA <= timer;
      rdCtl_reg <= ifiRead_y;
    end
  end

  function[LOGPTS-2:0] reverse;
    input [LOGPTS-2:0] in;
    integer i;
    begin
      for (i=0; i<LOGPTS-1; i=i+1)  reverse[i] = in[LOGPTS-2-i];
    end
  endfunction
endmodule


/**************  inBuf ADDR GEN WHEN PROCESSING DATA vs LOADING  **************/
// The core utilizes in-place algorithm, thus wA is a delayed copy of rA
module fft_inpl_inBuf_fftA_pipe (clk, clkEn,
  timer,  // topSM counter synchronizes addr gens
  stage,  // stage number
  lastStage,
  /*Out. fftOn is on when fft is running. fftDone = fall edge of fftOn.
  It tells topSM a FFT cycle is (almost)over, inBuf has been fully
  read/written out.  Use fftOn as wEn for the inBuf  */
  bflyA,      // read or write address
  swCross);   // switch control
  parameter LOGPTS  = 8;
  parameter LOGLOGPTS  = 3;

  input clk, clkEn, lastStage;
  input[LOGPTS-2:0] timer;
  input[LOGLOGPTS-1:0] stage;
  output swCross;
  output[LOGPTS-2:0] bflyA;
  reg[LOGPTS-2:0] bflyA;

  reg swCross;

  wire swCross_w;
  wire[LOGPTS-2:0] bflyA_w;
  wire[LOGPTS-1:0] addrP_w, offsetPQ_w;

  wire[LOGPTS+1:0] addrMask2 = {1'b0, {LOGPTS{1'b1}}};
  wire[LOGPTS-1:0] addrMask1 = {(LOGPTS-1){1'b1} };

  reg [LOGPTS-2:0] addrP_r2, offsetPQ_r1, offsetPQ_r2;
  reg [LOGPTS-2:0] mask2_r, mask1_r, timer_r, timer1_r;
  reg timer_bit0_r2;
  wire[LOGPTS-1:0] timer_shft_up, mask1_shft_stage;
  wire[LOGPTS:0] mask2_shft_stage;

  // addrP = (timer<<1) & (addrMask2>>stage) | timer & (addrMask1>>stage);
  assign timer_shft_up = timer<<1;
  assign mask1_shft_stage = addrMask1 >> stage;
  assign mask2_shft_stage = addrMask2 >> stage;

  assign addrP_w=(timer1_r & mask2_r) | ({1'b0, timer_r[LOGPTS-2:1]} & mask1_r);

  // address offset between P and Q
	// offsetPQ = (1<<(NumberOfStages-1-stage));
  assign offsetPQ_w = ( 1<<(LOGPTS-1) ) >> stage;
  /* rA takes either Paddr or Qaddr value (Qaddr=Paddr+offsetPQ) per clock, i.e.
  at even clk rA=Paddr, at odd clk rA=Qaddr. (Every addr has a pair of data
  samples).  Timer LSB controls which clk is happening now.  The same timer LSB
  controls switch(es). */
  assign bflyA_w = timer_bit0_r2 ? (addrP_r2+offsetPQ_r2) : addrP_r2;

  assign swCross_w = lastStage ? 0 : timer_bit0_r2;

  always @ (posedge clk) begin
    if (clkEn) begin
      offsetPQ_r1 <= offsetPQ_w[LOGPTS-1:1];
      timer_r     <= timer;
      timer1_r    <= timer_shft_up[LOGPTS-1:1];
      mask1_r     <= mask1_shft_stage[LOGPTS-1:1];
      mask2_r     <= ~(mask2_shft_stage[LOGPTS-1:1]);

      addrP_r2    <= addrP_w;
      offsetPQ_r2 <= offsetPQ_r1;
      timer_bit0_r2 <= timer_r[0];

      bflyA <= bflyA_w;
      swCross <= swCross_w;
    end
  end
endmodule


/***************************  TWIDDLE rA GENERATOR  ***************************/
module fft_inpl_twid_rA (clk, timer, stage, tA);
  parameter LOGPTS  = 8;
  parameter LOGLOGPTS  = 3;

  input clk;
  input[LOGPTS-2:0] timer;
  input[LOGLOGPTS-1:0] stage;
  output reg[LOGPTS-2:0] tA;
  //twiddleMask = ~(0xFFFFFFFF<<(NumberOfStages-1));
  //addrTwiddle =
  //    (reverseBits(count, NumberOfStages-1))<<(NumberOfStages-1-stage);
  // mask out extra left bits
  //addrTwiddle = addrTwiddle & twiddleMask;

  wire[2*LOGPTS-2:0] tA_w;
  reg [LOGPTS-2:0] timer_tick;
  reg [LOGLOGPTS-1:0] stage_tick, stage_tick2;

  wire [2*LOGPTS-1:0] tA_const;

  assign tA_const = reverse(timer_tick)<<(LOGPTS-1);
  assign tA_w = tA_const>>stage_tick2;

  always @ (posedge clk) begin
    tA          <= tA_w[LOGPTS-2:0];
    timer_tick  <= timer;
    stage_tick2 <= stage_tick;
    stage_tick  <= stage;
  end

  function[LOGPTS-2:0] reverse;
    input [LOGPTS-2:0] in;
    integer i;
    begin
      for (i=0; i<LOGPTS-1; i=i+1)
        reverse[i] = in[LOGPTS-2-i];
    end
  endfunction

endmodule


// In addition to twid_wA, the module also generates rstAfterInit, a short  //rt
// pulse after Twid RAM gets initialized                                    //rt
module fft_inpl_twid_wA_gen (slowClk, nGrst, twid_wA, twid_wEn, rstAfterInit);
  parameter LOGPTS  = 8;
  parameter LOGLOGPTS  = 3;

  input slowClk, nGrst;   // async global reset
  output [LOGPTS-2:0] twid_wA;
  output rstAfterInit, twid_wEn;
  reg rstAfterInit, twid_wEn;
  reg preRstAfterInit;
  
  wire pulse_rst;
  
  //rt
  // Generate a 1-clk sync'ed pulse on rising edge of the async reset
  fft_inpl_kitSync_ngrst # (.PULSE_WIDTH(1) )  ngrst2rst_0 ( 
    .nGrst(nGrst), 
    .clk(slowClk), 
    .pulse(pulse_rst)   );
  //rt

  fft_inpl_bcounter #(.WIDTH(LOGPTS-1)) slowTimer (.clk(slowClk),
    .nGrst(nGrst), 
//rt    .rst(1'b0),
    .rst(pulse_rst),    // to make sure all twid_wA are nice and clean 
    .cntEn(twid_wEn), .Q(twid_wA) );

  always @ (posedge slowClk or negedge nGrst) begin
    if (nGrst==1'b0)  begin
      twid_wEn        <= 1'b1;
      rstAfterInit    <= 1'b0;
      preRstAfterInit <= 1'b0;
    end
    else                                  //rt
      if (pulse_rst==1'b1) begin          //rt
        twid_wEn        <= 1'b1;          //rt
        rstAfterInit    <= 1'b0;          //rt
        preRstAfterInit <= 1'b0;          //rt
      end                                 //rt
      else begin
        rstAfterInit <= preRstAfterInit;
        if ( twid_wA == {(LOGPTS-1){1'b1}}) twid_wEn <= 1'b0;
        preRstAfterInit <= ( twid_wA == {(LOGPTS-1){1'b1}});
      end
  end
endmodule