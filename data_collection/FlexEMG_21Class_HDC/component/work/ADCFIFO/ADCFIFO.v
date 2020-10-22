//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Sun Jan 22 16:04:06 2017
// Version: v11.7 SP1 11.7.1.11
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// ADCFIFO
module ADCFIFO(
    // Inputs
    CLK,
    DATA,
    RE,
    RESET,
    WE,
    // Outputs
    EMPTY,
    FULL,
    OVERFLOW,
    Q,
    RDCNT,
    UNDERFLOW,
    WRCNT
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         CLK;
input  [15:0] DATA;
input         RE;
input         RESET;
input         WE;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        EMPTY;
output        FULL;
output        OVERFLOW;
output [15:0] Q;
output [6:0]  RDCNT;
output        UNDERFLOW;
output [6:0]  WRCNT;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CLK;
wire   [15:0] DATA;
wire          EMPTY_net_0;
wire          FULL_net_0;
wire          OVERFLOW_net_0;
wire   [15:0] Q_1;
wire   [6:0]  RDCNT_2;
wire          RE;
wire          RESET;
wire          UNDERFLOW_net_0;
wire          WE;
wire   [6:0]  WRCNT_1;
wire          FULL_net_1;
wire          EMPTY_net_1;
wire          OVERFLOW_net_1;
wire          UNDERFLOW_net_1;
wire   [15:0] Q_1_net_0;
wire   [6:0]  WRCNT_1_net_0;
wire   [6:0]  RDCNT_2_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
wire   [15:0] MEMRD_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net           = 1'b0;
assign MEMRD_const_net_0 = 16'h0000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign FULL_net_1      = FULL_net_0;
assign FULL            = FULL_net_1;
assign EMPTY_net_1     = EMPTY_net_0;
assign EMPTY           = EMPTY_net_1;
assign OVERFLOW_net_1  = OVERFLOW_net_0;
assign OVERFLOW        = OVERFLOW_net_1;
assign UNDERFLOW_net_1 = UNDERFLOW_net_0;
assign UNDERFLOW       = UNDERFLOW_net_1;
assign Q_1_net_0       = Q_1;
assign Q[15:0]         = Q_1_net_0;
assign WRCNT_1_net_0   = WRCNT_1;
assign WRCNT[6:0]      = WRCNT_1_net_0;
assign RDCNT_2_net_0   = RDCNT_2;
assign RDCNT[6:0]      = RDCNT_2_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------ADCFIFO_ADCFIFO_0_COREFIFO   -   Actel:DirectCore:COREFIFO:2.4.100
ADCFIFO_ADCFIFO_0_COREFIFO #( 
        .AE_STATIC_EN   ( 0 ),
        .AEVAL          ( 129 ),
        .AF_STATIC_EN   ( 0 ),
        .AFVAL          ( 958 ),
        .CTRL_TYPE      ( 2 ),
        .ESTOP          ( 1 ),
        .FAMILY         ( 19 ),
        .FSTOP          ( 1 ),
        .FWFT           ( 0 ),
        .OVERFLOW_EN    ( 1 ),
        .PIPE           ( 1 ),
        .PREFETCH       ( 0 ),
        .RCLK_EDGE      ( 1 ),
        .RDCNT_EN       ( 1 ),
        .RDEPTH         ( 64 ),
        .RE_POLARITY    ( 0 ),
        .READ_DVALID    ( 0 ),
        .RESET_POLARITY ( 0 ),
        .RWIDTH         ( 16 ),
        .SYNC           ( 1 ),
        .UNDERFLOW_EN   ( 1 ),
        .WCLK_EDGE      ( 1 ),
        .WDEPTH         ( 64 ),
        .WE_POLARITY    ( 0 ),
        .WRCNT_EN       ( 1 ),
        .WRITE_ACK      ( 0 ),
        .WWIDTH         ( 16 ) )
ADCFIFO_0(
        // Inputs
        .CLK       ( CLK ),
        .WCLOCK    ( GND_net ), // tied to 1'b0 from definition
        .RCLOCK    ( GND_net ), // tied to 1'b0 from definition
        .RESET     ( RESET ),
        .WE        ( WE ),
        .RE        ( RE ),
        .DATA      ( DATA ),
        .MEMRD     ( MEMRD_const_net_0 ), // tied to 16'h0000 from definition
        // Outputs
        .FULL      ( FULL_net_0 ),
        .EMPTY     ( EMPTY_net_0 ),
        .AFULL     (  ),
        .AEMPTY    (  ),
        .OVERFLOW  ( OVERFLOW_net_0 ),
        .UNDERFLOW ( UNDERFLOW_net_0 ),
        .WACK      (  ),
        .DVLD      (  ),
        .MEMWE     (  ),
        .MEMRE     (  ),
        .Q         ( Q_1 ),
        .WRCNT     ( WRCNT_1 ),
        .RDCNT     ( RDCNT_2 ),
        .MEMWADDR  (  ),
        .MEMRADDR  (  ),
        .MEMWD     (  ) 
        );


endmodule
