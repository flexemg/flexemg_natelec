///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: pdma_sim.v
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

module pdma_sim (
    input wire clk,
    input wire rstb,

    input wire run,

    input wire pdma_irq_req,
    input wire pdma_data_rdy,
    output reg pdma_fifo_pop
);

localparam IDLE = 1'b0;
localparam READ = 1'b1;

reg current_state, next_state;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

always @ (*) begin
    pdma_fifo_pop = 1'b0;
    
    next_state = current_state;

    case (current_state)
        IDLE:
            if (run && pdma_irq_req)
                next_state = READ;
            else
                next_state = IDLE;

        READ:
        begin
            pdma_fifo_pop = 1'b1;
            if (~pdma_data_rdy)
                next_state = IDLE;
        end
    endcase
end

endmodule

