///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: adc_frame_buffer.v
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

module adc_frame_buffer ( 
    input wire clk,
    input wire rstb,

    input wire start,
    input wire rx_bit_valid,
    input wire rx_bit,
    input wire pkt_done,

    output reg [1023:0] dout
);

// RX bit shift register (buf1)
reg [1023:0] shift_reg;
always @(posedge clk or negedge rstb) begin
    if (!rstb || start)
        shift_reg <= 1024'd0;
    else if (rx_bit_valid)
        shift_reg <= {shift_reg[1022:0], rx_bit};
    else
        shift_reg <= shift_reg;
end

// double-buf register (buf2)
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        dout <= 1024'd0;
    else if (pkt_done)
        dout <= shift_reg;
    else
        dout <= dout;
end

endmodule

