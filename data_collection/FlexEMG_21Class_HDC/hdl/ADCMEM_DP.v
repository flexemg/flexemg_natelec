///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: ADCMEM.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S050> <Package::484 FBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

`timescale 1ns / 100ps

module ADCMEM_DP (
    input wire clk,

    input wire [8:0] addr_0,
    input wire [15:0] din_0,
    input wire we_0,
    input wire re_0,

    input wire [8:0] addr_1,
    input wire [15:0] din_1,
    input wire we_1,
    input wire re_1,

    output wire [15:0] dout
);

reg [15:0] mem [0:511];

assign dout = (re_0) ? mem[addr_0] : (re_1) ? mem[addr_1] : 16'd0;

always @(posedge clk) begin
    if (we_0)
        mem[addr_0] <= din_0;
    else if (we_1)
        mem[addr_1] <= din_1;

end

endmodule