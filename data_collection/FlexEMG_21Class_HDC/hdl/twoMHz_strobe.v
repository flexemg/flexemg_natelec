///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: twoMHz_strobe.v
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

//`timescale <time_units> / <precision>

module twoMHz_strobe(
    input wire clk,
    input wire rstb,

    output reg twoMHz_stb
);

reg [3:0] clk_counter;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        clk_counter <= 4'd9;
    else
        clk_counter <= (clk_counter == 4'd9) ? 4'd0 : clk_counter + 1;
end

always @ (posedge clk) begin
    twoMHz_stb = (clk_counter == 0);
end

endmodule

