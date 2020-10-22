//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Thu Mar 16 16:39:52 2017
// Version: v11.7 SP3 11.7.3.7
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// PDMAFIFO
module PDMAFIFO(
    // Inputs
    CLK,
    DATA,
    RE,
    RESET,
    WE,
    // Outputs
    DVLD,
    EMPTY,
    FULL,
    OVERFLOW,
    Q,
    RDCNT,
    UNDERFLOW,
    WACK,
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
output        DVLD;
output        EMPTY;
output        FULL;
output        OVERFLOW;
output [7:0]  Q;
output [8:0]  RDCNT;
output        UNDERFLOW;
output        WACK;
output [7:0]  WRCNT;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CLK;
wire   [15:0] DATA;
wire          DVLD_net_0;
wire          EMPTY_net_0;
wire          FULL_net_0;
wire          OVERFLOW_net_0;
wire   [7:0]  Q_1;
wire   [8:0]  RDCNT_1;
wire          RE;
wire          RESET;
wire          UNDERFLOW_net_0;
wire          WACK_net_0;
wire          WE;
wire   [7:0]  WRCNT_net_0;
wire          FULL_net_1;
wire          EMPTY_net_1;
wire          OVERFLOW_net_1;
wire          UNDERFLOW_net_1;
wire          WACK_net_1;
wire          DVLD_net_1;
wire   [7:0]  WRCNT_net_1;
wire   [7:0]  Q_1_net_0;
wire   [8:0]  RDCNT_1_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
wire   [7:0]  MEMRD_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net           = 1'b0;
assign MEMRD_const_net_0 = 8'h00;
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
assign WACK_net_1      = WACK_net_0;
assign WACK            = WACK_net_1;
assign DVLD_net_1      = DVLD_net_0;
assign DVLD            = DVLD_net_1;
assign WRCNT_net_1     = WRCNT_net_0;
assign WRCNT[7:0]      = WRCNT_net_1;
assign Q_1_net_0       = Q_1;
assign Q[7:0]          = Q_1_net_0;
assign RDCNT_1_net_0   = RDCNT_1;
assign RDCNT[8:0]      = RDCNT_1_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------PDMAFIFO_PDMAFIFO_0_COREFIFO   -   Actel:DirectCore:COREFIFO:2.5.106
PDMAFIFO_PDMAFIFO_0_COREFIFO #( 
        .AE_STATIC_EN   ( 0 ),
        .AEVAL          ( 4 ),
        .AF_STATIC_EN   ( 0 ),
        .AFVAL          ( 99 ),
        .CTRL_TYPE      ( 3 ),
        .ECC            ( 0 ),
        .ESTOP          ( 1 ),
        .FAMILY         ( 19 ),
        .FSTOP          ( 1 ),
        .FWFT           ( 0 ),
        .OVERFLOW_EN    ( 1 ),
        .PIPE           ( 1 ),
        .PREFETCH       ( 0 ),
        .RCLK_EDGE      ( 1 ),
        .RDCNT_EN       ( 1 ),
        .RDEPTH         ( 200 ),
        .RE_POLARITY    ( 0 ),
        .READ_DVALID    ( 1 ),
        .RESET_POLARITY ( 0 ),
        .RWIDTH         ( 8 ),
        .SYNC           ( 1 ),
        .UNDERFLOW_EN   ( 1 ),
        .WCLK_EDGE      ( 1 ),
        .WDEPTH         ( 100 ),
        .WE_POLARITY    ( 0 ),
        .WRCNT_EN       ( 1 ),
        .WRITE_ACK      ( 1 ),
        .WWIDTH         ( 16 ) )
PDMAFIFO_0(
        // Inputs
        .CLK        ( CLK ),
        .WCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RESET      ( RESET ),
        .WE         ( WE ),
        .RE         ( RE ),
        .DATA       ( DATA ),
        .MEMRD      ( MEMRD_const_net_0 ), // tied to 8'h00 from definition
        // Outputs
        .FULL       ( FULL_net_0 ),
        .EMPTY      ( EMPTY_net_0 ),
        .AFULL      (  ),
        .AEMPTY     (  ),
        .OVERFLOW   ( OVERFLOW_net_0 ),
        .UNDERFLOW  ( UNDERFLOW_net_0 ),
        .WACK       ( WACK_net_0 ),
        .DVLD       ( DVLD_net_0 ),
        .MEMWE      (  ),
        .MEMRE      (  ),
        .SB_CORRECT (  ),
        .DB_DETECT  (  ),
        .Q          ( Q_1 ),
        .WRCNT      ( WRCNT_net_0 ),
        .RDCNT      ( RDCNT_1 ),
        .MEMWADDR   (  ),
        .MEMRADDR   (  ),
        .MEMWD      (  ) 
        );


endmodule
