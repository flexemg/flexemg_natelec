///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: toplevel_tb.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S060T> <Package::325 FCSBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

`timescale 1ns/100ps

module toplevel_tb;

parameter SYSCLK_PERIOD = 50;// 20MHZ

reg SYSCLK;
reg NSYSRESET;

initial
begin
    SYSCLK = 1'b0;
    NSYSRESET = 1'b0;
end

//////////////////////////////////////////////////////////////////////
// Reset Pulse
//////////////////////////////////////////////////////////////////////
initial
begin
    #(SYSCLK_PERIOD * 10 )
        NSYSRESET = 1'b1;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;

wire acc_clkin_o;

wire [1:0] a2n_valid;
wire [1:0] a2n_data;
wire [1:0] n2a_data;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  Mario_Libero
////////////////////////////////////////////////////////////////////// 
Mario_Libero Mario_Libero_0 (
    .XTL(SYSCLK),
    .MMUART_1_RXD({1{1'b0}}),

    .CLK_OUT( ),
    .CLK_OUT2( ),

    .MMUART_1_TXD( ),

    .GPIO0( ),
    .GPIO1( ),
    .GPIO2( ),
    .GPIO3( ),

    .A2N_VALID_0(a2n_valid[0]),
    .A2N_DATA_0(a2n_data[0]),
    .N2A_DATA_0(~n2a_data[0]),
    .A2N_VALID_1(a2n_valid[1]),
    .A2N_DATA_1(a2n_data[1]),
    .N2A_DATA_1(~n2a_data[1]),

    .I2C_1_SCL(scl),
    .I2C_1_SDA(sda_o),

    .ACC_CLKIN(acc_clkin_o),
    .ACC_IRQ({1{1'b0}}),

    .DEBUG()
);

endmodule

