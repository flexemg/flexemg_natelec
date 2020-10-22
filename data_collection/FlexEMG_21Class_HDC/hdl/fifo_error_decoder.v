///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: fifo_error_decoder.v
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

//`timescale <time_units> / <precision>

module fifo_error_decoder
  ( 
    input wire clk,
    input wire rstb,
    input wire ena,

    input wire pdma_overflow,
    input wire pdma_underflow,
    input wire nm1_adc_overflow,
    input wire nm1_adc_underflow,
    input wire nm0_adc_overflow,
    input wire nm0_adc_underflow,

    output reg [1:0] led
);

// 2MHz - 1KHz clock divider
reg [10:0] div;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || div == 2000)
        div <= 0;
    else 
        div <= div + 1;
end
wire ctr_inc = (div == 2000);

// timing counter
reg [10:0] ctr;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        ctr <= 0;
    else if (ctr_inc)
        ctr <= ctr + 1'b1;
end

// codes
wire bright_solid = ena && 1'b1;
wire dim_solid =    ena && ctr[0];
wire bright_250ms = ena && (ctr[7]  && ctr[6]);
wire dim_250ms =    ena && (ctr[7]  && ctr[6] && ctr[0]);
wire bright_500ms = ena && (ctr[8]  && !ctr[7] && ctr[6]);
wire dim_500ms =    ena && (ctr[8]  && !ctr[7] && ctr[6] && ctr[0]);
wire bright_1s =    ena && (ctr[9]  && !ctr[8] && !ctr[7] && ctr[6]);
wire dim_1s =       ena && (ctr[9]  && !ctr[8] && !ctr[7] && ctr[6] && ctr[0]);
wire bright_2s =    ena && (ctr[10] && !ctr[9] && !ctr[8] && !ctr[7] && ctr[6]);
wire dim_2s =       ena && (ctr[10] && !ctr[9] && !ctr[8] && !ctr[7] && ctr[6] && ctr[0]);

//
// flag registers
//

reg pdma_of;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        pdma_of <= 1'b0;
    else if (pdma_overflow)
        pdma_of <= 1'b1;
end

reg pdma_uf;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        pdma_uf <= 1'b0;
    else if (pdma_underflow)
        pdma_uf <= 1'b1;
end

reg nm1_of;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        nm1_of <= 1'b0;
    else if (nm1_adc_overflow)
        nm1_of <= 1'b1;
end

reg nm1_uf;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        nm1_uf <= 1'b0;
    else if (nm1_adc_underflow)
        nm1_uf <= 1'b1;
end

reg nm0_of;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        nm0_of <= 1'b0;
    else if (nm0_adc_overflow)
        nm0_of <= 1'b1;
end

reg nm0_uf;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        nm0_uf <= 1'b0;
    else if (nm0_adc_underflow)
        nm0_uf <= 1'b1;
end

// LED1 (overflow) code mux
always @ (*) begin
    if (!pdma_of && !nm1_of && !nm0_of)
        led[1] <= 1'b0;
    if (!pdma_of && !nm1_of &&  nm0_of)
        led[1] <= bright_250ms;
    if (!pdma_of &&  nm1_of && !nm0_of)
        led[1] <= dim_250ms;
    if (!pdma_of &&  nm1_of &&  nm0_of)
        led[1] <= bright_500ms;
    if ( pdma_of && !nm1_of && !nm0_of)
        led[1] <= dim_500ms;
    if ( pdma_of && !nm1_of &&  nm0_of)
        led[1] <= bright_1s;
    if ( pdma_of &&  nm1_of && !nm0_of)
        led[1] <= dim_1s;
    if ( pdma_of &&  nm1_of &&  nm0_of)
        led[1] <= bright_2s;
end

// LED0 (underflow) code mux
always @ (*) begin
    if (!pdma_uf && !nm1_uf && !nm0_uf)
        led[0] <= 1'b0;
    if (!pdma_uf && !nm1_uf &&  nm0_uf)
        led[0] <= bright_250ms;
    if (!pdma_uf &&  nm1_uf && !nm0_uf)
        led[0] <= dim_250ms;
    if (!pdma_uf &&  nm1_uf &&  nm0_uf)
        led[0] <= bright_500ms;
    if ( pdma_uf && !nm1_uf && !nm0_uf)
        led[0] <= dim_500ms;
    if ( pdma_uf && !nm1_uf &&  nm0_uf)
        led[0] <= bright_1s;
    if ( pdma_uf &&  nm1_uf && !nm0_uf)
        led[0] <= dim_1s;
    if ( pdma_uf &&  nm1_uf &&  nm0_uf)
        led[0] <= bright_2s;
end

endmodule

