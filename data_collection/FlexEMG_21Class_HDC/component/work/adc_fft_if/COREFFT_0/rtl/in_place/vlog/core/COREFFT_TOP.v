// ***************************************************************************/
//Microsemi Corporation Proprietary and Confidential
//Copyright 2011 Microsemi Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT
//              CoreFFT top level module
//
//Revision Information:
//Date         Description
//12Jan2010    Initial Release
//
//SVN Revision Information:
//SVN $Revision: $
//SVN $Data: $
//
//Resolved SARs
//SAR     Date    Who         Description
//
//Notes:
// 4/7/2011 //refresh Any Refresh except the initial one is transparent

`timescale 1 ns/100 ps

module adc_fft_if_COREFFT_0_COREFFT (
  DATAI_IM,
	DATAI_RE,
	DATAI_VALID,
	DATAO_IM,
	DATAO_RE,
	CLKEN,
  CLK,
	NGRST,
	RST,
  START,
  OUTP_READY,
	BUF_READY,
	READ_OUTP,
	PONG,
	SCALE_EXP,
  DATAO_VALID,
  RFS,     // req for START
  INVERSE_STRM,
  OVFLOW_FLAG,
  REFRESH);

  parameter FPGA_FAMILY = 19; //12:RTAXD; 19,24:SF2; 25:RTG4; 26:G5
  parameter URAM_MAXDEPTH = 0;
  parameter CFG_ARCH    = 1;

  parameter DATA_BITS = 18;
  parameter TWID_BITS = 18;
  parameter FFT_SIZE  = 256;   // FFT size
  parameter SCALE_ON  = 1;
  parameter SCALE_SCH = 255;
  parameter ORDER     = 0;

  parameter INVERSE = 0;
  parameter SCALE   = 0;  //0-conditional 1-unconditional scaling
  parameter POINTS  = 256;
  parameter WIDTH   = 18;   // In-place FFT bit width
  parameter MEMBUF  = 0;
  parameter SCALE_EXP_ON = 0;

//  parameter DIE_SIZE = 20;  //reserved for use with G4 dies where a row < 16 MAC
  parameter NO_RAM   = 0;   

  // In-Place params
  localparam LOG2PTS       = ceil_log2(POINTS);
  localparam LOGLOG2PTS    = ceil_log2(LOG2PTS);
  localparam FLOGLOG2PTS   = floor_log2(LOG2PTS)+1;
  // Streaming output bitwidth
  localparam STREAM_DATAO_BITS = (SCALE_ON==0)? 
                              DATA_BITS+ceil_log2(FFT_SIZE)+1 : DATA_BITS;
  localparam IN_BITS  = (CFG_ARCH==1)? WIDTH : DATA_BITS;
  localparam OUTP_BITS = (CFG_ARCH==1)? WIDTH : STREAM_DATAO_BITS;

  input DATAI_VALID, READ_OUTP;
  input [IN_BITS-1:0] DATAI_IM, DATAI_RE;
  output[OUTP_BITS-1:0] DATAO_IM, DATAO_RE;
  output BUF_READY, PONG;
  input CLK, NGRST, RST, START, CLKEN, INVERSE_STRM, REFRESH;
  output OUTP_READY, DATAO_VALID, RFS, OVFLOW_FLAG;
  output[FLOGLOG2PTS-1:0] SCALE_EXP;

  generate
    if(CFG_ARCH == 1) begin
      adc_fft_if_COREFFT_0_COREFFT_INPLC #(
        .FPGA_FAMILY (FPGA_FAMILY),
        .URAM_MAXDEPTH(URAM_MAXDEPTH),
        .INVERSE (INVERSE),
        .SCALE   (SCALE),
        .POINTS  (POINTS),
        .WIDTH   (WIDTH),
        .MEMBUF  (MEMBUF),
        .SCALE_EXP_ON (SCALE_EXP_ON)  ) DUT_INPLACE (
            .CLK (CLK),
	          .NGRST(NGRST),
            .DATAI_IM (DATAI_IM),
            .DATAI_RE (DATAI_RE),
            .DATAI_VALID (DATAI_VALID),
            .READ_OUTP (READ_OUTP),
            .DATAO_IM (DATAO_IM),
            .DATAO_RE (DATAO_RE),
            .DATAO_VALID (DATAO_VALID),
            .BUF_READY (BUF_READY),
            .OUTP_READY (OUTP_READY),
            .SCALE_EXP (SCALE_EXP),
            .PONG  (PONG)   );
    end
  endgenerate

  generate
    if(CFG_ARCH == 2) begin
      adc_fft_if_COREFFT_0_COREFFT_STRM # (
        .FPGA_FAMILY (FPGA_FAMILY),
        .URAM_MAXDEPTH(URAM_MAXDEPTH),
        .DATA_BITS(DATA_BITS),
        .TWID_BITS(TWID_BITS),
        .FFT_SIZE(FFT_SIZE),
        .SCALE_ON(SCALE_ON),
        .DATAO_BITS(STREAM_DATAO_BITS),
        .SCALE_SCH(SCALE_SCH),
        .ORDER(ORDER),
        .NO_RAM(NO_RAM) ) DUT_STRM (
            .DATAI_IM(DATAI_IM),
            .DATAI_RE(DATAI_RE),
            .DATAO_IM(DATAO_IM),
            .DATAO_RE(DATAO_RE),
            .CLKEN(CLKEN),
            .CLK(CLK),
            .NGRST(NGRST),
            .RST(RST),
            .START(START),
            .OUTP_READY(OUTP_READY),    // short pilot pulse
            .DATAO_VALID(DATAO_VALID),  // long strobe covering whole FFT frame
            .RFS(RFS),
            .INVERSE(INVERSE_STRM),
            .OVFLOW_FLAG(OVFLOW_FLAG),
            .REFRESH(REFRESH)  );
    end
  endgenerate

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
