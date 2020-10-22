///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: ADCMEM_SP.v
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

module ADCMEM_SP (
    input wire clk,

    input wire [8:0] addr,
    input wire [15:0] din,
    input wire we,
    input wire re,

    output wire [15:0] dout
);

reg [15:0] mem [0:511];

assign dout = (re) ? mem[addr] : 16'd0;

always @(posedge clk) begin
    if (we)
        mem[addr] <= din;
    else if (we)
        mem[addr] <= din;

end

endmodule