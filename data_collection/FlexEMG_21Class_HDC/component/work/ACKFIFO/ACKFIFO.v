//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Thu Jun 29 16:39:54 2017
// Version: v11.7 SP3 11.7.3.7
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// ACKFIFO
module ACKFIFO(
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
    Q
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         CLK;
input  [31:0] DATA;
input         RE;
input         RESET;
input         WE;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        EMPTY;
output        FULL;
output        OVERFLOW;
output [31:0] Q;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CLK;
wire   [31:0] DATA;
wire          EMPTY_net_0;
wire          FULL_net_0;
wire          OVERFLOW_net_0;
wire   [31:0] Q_0;
wire          RE;
wire          RESET;
wire          WE;
wire          FULL_net_1;
wire          EMPTY_net_1;
wire          OVERFLOW_net_1;
wire   [31:0] Q_0_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
wire   [31:0] MEMRD_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net           = 1'b0;
assign MEMRD_const_net_0 = 32'h00000000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign FULL_net_1     = FULL_net_0;
assign FULL           = FULL_net_1;
assign EMPTY_net_1    = EMPTY_net_0;
assign EMPTY          = EMPTY_net_1;
assign OVERFLOW_net_1 = OVERFLOW_net_0;
assign OVERFLOW       = OVERFLOW_net_1;
assign Q_0_net_0      = Q_0;
assign Q[31:0]        = Q_0_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------ACKFIFO_ACKFIFO_0_COREFIFO   -   Actel:DirectCore:COREFIFO:2.4.100
ACKFIFO_ACKFIFO_0_COREFIFO #( 
        .AE_STATIC_EN   ( 0 ),
        .AEVAL          ( 3 ),
        .AF_STATIC_EN   ( 0 ),
        .AFVAL          ( 60 ),
        .CTRL_TYPE      ( 3 ),
        .ESTOP          ( 1 ),
        .FAMILY         ( 19 ),
        .FSTOP          ( 1 ),
        .FWFT           ( 1 ),
        .OVERFLOW_EN    ( 1 ),
        .PIPE           ( 1 ),
        .PREFETCH       ( 0 ),
        .RCLK_EDGE      ( 1 ),
        .RDCNT_EN       ( 0 ),
        .RDEPTH         ( 64 ),
        .RE_POLARITY    ( 0 ),
        .READ_DVALID    ( 0 ),
        .RESET_POLARITY ( 0 ),
        .RWIDTH         ( 32 ),
        .SYNC           ( 1 ),
        .UNDERFLOW_EN   ( 0 ),
        .WCLK_EDGE      ( 1 ),
        .WDEPTH         ( 64 ),
        .WE_POLARITY    ( 0 ),
        .WRCNT_EN       ( 0 ),
        .WRITE_ACK      ( 0 ),
        .WWIDTH         ( 32 ) )
ACKFIFO_0(
        // Inputs
        .CLK       ( CLK ),
        .WCLOCK    ( GND_net ), // tied to 1'b0 from definition
        .RCLOCK    ( GND_net ), // tied to 1'b0 from definition
        .RESET     ( RESET ),
        .WE        ( WE ),
        .RE        ( RE ),
        .DATA      ( DATA ),
        .MEMRD     ( MEMRD_const_net_0 ), // tied to 32'h00000000 from definition
        // Outputs
        .FULL      ( FULL_net_0 ),
        .EMPTY     ( EMPTY_net_0 ),
        .AFULL     (  ),
        .AEMPTY    (  ),
        .OVERFLOW  ( OVERFLOW_net_0 ),
        .UNDERFLOW (  ),
        .WACK      (  ),
        .DVLD      (  ),
        .MEMWE     (  ),
        .MEMRE     (  ),
        .Q         ( Q_0 ),
        .WRCNT     (  ),
        .RDCNT     (  ),
        .MEMWADDR  (  ),
        .MEMRADDR  (  ),
        .MEMWD     (  ) 
        );


endmodule
