//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Mon May 22 18:45:45 2017
// Version: v11.7 SP3 11.7.3.7
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// adc_fft_if
module adc_fft_if(
    // Inputs
    chan,
    chan_cnt_inc,
    clk,
    enable,
    fft_re_in,
    frame_rdy,
    rd_strobe,
    rstb,
    // Outputs
    debug,
    fft_out,
    fft_rdy,
    irq
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [5:0]  chan;
input         chan_cnt_inc;
input         clk;
input         enable;
input  [15:0] fft_re_in;
input         frame_rdy;
input         rd_strobe;
input         rstb;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [3:0]  debug;
output [31:0] fft_out;
output        fft_rdy;
output        irq;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [5:0]  chan;
wire          chan_cnt_inc;
wire          clk;
wire          COREFFT_0_BUF_READY;
wire   [15:0] COREFFT_0_DATAO_IM;
wire   [15:0] COREFFT_0_DATAO_RE;
wire          COREFFT_0_DATAO_VALID;
wire   [3:0]  debug_0;
wire          rd_strobe;
wire          enable;
wire          fft_datai_valid;
wire   [31:0] fft_out_0;
wire          fft_outp_rdy;
wire          fft_rdy_net_0;
wire   [15:0] fft_re_in;
wire          fft_read_outp;
wire          frame_rdy;
wire          irq_net_0;
wire          rstb;
wire          irq_net_1;
wire          fft_rdy_net_1;
wire   [31:0] fft_out_0_net_0;
wire   [3:0]  debug_0_net_0;
wire   [31:0] DATA_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   [15:0] DATAI_IM_const_net_0;
wire          VCC_net;
wire          GND_net;
wire   [31:0] MEMRD_const_net_0;
//--------------------------------------------------------------------
// Inverted Nets
//--------------------------------------------------------------------
wire          EMPTY_OUT_PRE_INV0_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign DATAI_IM_const_net_0 = 16'h0000;
assign VCC_net              = 1'b1;
assign GND_net              = 1'b0;
assign MEMRD_const_net_0    = 32'h00000000;
//--------------------------------------------------------------------
// Inversions
//--------------------------------------------------------------------
assign fft_rdy_net_0 = ~ EMPTY_OUT_PRE_INV0_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign irq_net_1       = irq_net_0;
assign irq             = irq_net_1;
assign fft_rdy_net_1   = fft_rdy_net_0;
assign fft_rdy         = fft_rdy_net_1;
assign fft_out_0_net_0 = fft_out_0;
assign fft_out[31:0]   = fft_out_0_net_0;
assign debug_0_net_0   = debug_0;
assign debug[3:0]      = debug_0_net_0;
//--------------------------------------------------------------------
// Concatenation assignments
//--------------------------------------------------------------------
assign DATA_net_0 = { COREFFT_0_DATAO_IM , COREFFT_0_DATAO_RE };
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------adc_fft_cntl
adc_fft_cntl #( 
        .DEBUG_BUS_SIZE ( 4 ),
        .POINTS         ( 512 ) )
adc_fft_cntl_0(
        // Inputs
        .clk             ( clk ),
        .rstb            ( rstb ),
        .enable          ( enable ),
        .frame_rdy       ( frame_rdy ),
        .chan_cnt_inc    ( chan_cnt_inc ),
        .fft_buf_rdy     ( COREFFT_0_BUF_READY ),
        .fft_outp_rdy    ( fft_outp_rdy ),
        .fft_datao_valid ( COREFFT_0_DATAO_VALID ),
        .chan            ( chan ),
        // Outputs
        .fft_datai_valid ( fft_datai_valid ),
        .fft_read_outp   ( fft_read_outp ),
        .irq             ( irq_net_0 ),
        .debug           ( debug_0 ) 
        );

//--------adc_fft_if_COREFFT_0_COREFFT   -   Actel:DirectCore:COREFFT:7.0.104
adc_fft_if_COREFFT_0_COREFFT #( 
        .CFG_ARCH      ( 1 ),
        .DATA_BITS     ( 18 ),
        .FFT_SIZE      ( 256 ),
        .FPGA_FAMILY   ( 19 ),
        .INVERSE       ( 0 ),
        .MEMBUF        ( 0 ),
        .ORDER         ( 0 ),
        .POINTS        ( 512 ),
        .SCALE         ( 0 ),
        .SCALE_EXP_ON  ( 0 ),
        .SCALE_ON      ( 1 ),
        .SCALE_SCH     ( 255 ),
        .TWID_BITS     ( 18 ),
        .URAM_MAXDEPTH ( 512 ),
        .WIDTH         ( 16 ) )
COREFFT_0(
        // Inputs
        .CLK          ( clk ),
        .NGRST        ( rstb ),
        .DATAI_VALID  ( fft_datai_valid ),
        .READ_OUTP    ( fft_read_outp ),
        .START        ( VCC_net ), // tied to 1'b1 from definition
        .INVERSE_STRM ( GND_net ), // tied to 1'b0 from definition
        .REFRESH      ( GND_net ), // tied to 1'b0 from definition
        .CLKEN        ( VCC_net ), // tied to 1'b1 from definition
        .RST          ( GND_net ), // tied to 1'b0 from definition
        .DATAI_IM     ( DATAI_IM_const_net_0 ),
        .DATAI_RE     ( fft_re_in ),
        // Outputs
        .DATAO_VALID  ( COREFFT_0_DATAO_VALID ),
        .BUF_READY    ( COREFFT_0_BUF_READY ),
        .OUTP_READY   ( fft_outp_rdy ),
        .PONG         (  ),
        .OVFLOW_FLAG  (  ),
        .RFS          (  ),
        .DATAO_IM     ( COREFFT_0_DATAO_IM ),
        .DATAO_RE     ( COREFFT_0_DATAO_RE ),
        .SCALE_EXP    (  ) 
        );

//--------adc_fft_if_COREFIFO_0_COREFIFO   -   Actel:DirectCore:COREFIFO:2.6.108
adc_fft_if_COREFIFO_0_COREFIFO #( 
        .AE_STATIC_EN   ( 0 ),
        .AEVAL          ( 4 ),
        .AF_STATIC_EN   ( 0 ),
        .AFVAL          ( 1020 ),
        .CTRL_TYPE      ( 2 ),
        .ECC            ( 0 ),
        .ESTOP          ( 1 ),
        .FAMILY         ( 19 ),
        .FSTOP          ( 1 ),
        .FWFT           ( 0 ),
        .OVERFLOW_EN    ( 0 ),
        .PIPE           ( 1 ),
        .PREFETCH       ( 0 ),
        .RCLK_EDGE      ( 1 ),
        .RDCNT_EN       ( 0 ),
        .RDEPTH         ( 512 ),
        .RE_POLARITY    ( 0 ),
        .READ_DVALID    ( 0 ),
        .RESET_POLARITY ( 0 ),
        .RWIDTH         ( 32 ),
        .SYNC           ( 1 ),
        .UNDERFLOW_EN   ( 0 ),
        .WCLK_EDGE      ( 1 ),
        .WDEPTH         ( 512 ),
        .WE_POLARITY    ( 0 ),
        .WRCNT_EN       ( 0 ),
        .WRITE_ACK      ( 0 ),
        .WWIDTH         ( 32 ) )
COREFIFO_0(
        // Inputs
        .CLK        ( clk ),
        .WCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RESET      ( rstb ),
        .WE         ( COREFFT_0_DATAO_VALID ),
        .RE         ( rd_strobe ),
        .DATA       ( DATA_net_0 ),
        .MEMRD      ( MEMRD_const_net_0 ), // tied to 32'h00000000 from definition
        // Outputs
        .FULL       (  ),
        .EMPTY      ( EMPTY_OUT_PRE_INV0_0 ),
        .AFULL      (  ),
        .AEMPTY     (  ),
        .OVERFLOW   (  ),
        .UNDERFLOW  (  ),
        .WACK       (  ),
        .DVLD       (  ),
        .MEMWE      (  ),
        .MEMRE      (  ),
        .SB_CORRECT (  ),
        .DB_DETECT  (  ),
        .Q          ( fft_out_0 ),
        .WRCNT      (  ),
        .RDCNT      (  ),
        .MEMWADDR   (  ),
        .MEMRADDR   (  ),
        .MEMWD      (  ) 
        );


endmodule
