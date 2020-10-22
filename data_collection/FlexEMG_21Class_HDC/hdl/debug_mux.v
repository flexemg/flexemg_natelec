///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: debug_mux.v
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

module debug_mux #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
	input wire PCLK,
	input wire ACC_CLK,

    // From CM_APB_IF
    input wire [4:0] chan_sel,
    input wire nm0_stim_ld,
    input wire [2:0] num_stims,
    input wire [15:0] mode_debug,
    input wire [DEBUG_BUS_SIZE-1:0] cm_apb_debug,

    // From NM1_IF
    input wire [DEBUG_BUS_SIZE-1:0] nm1_ack_dp_debug,

    // From NM0_IF
    input wire [DEBUG_BUS_SIZE-1:0] nm_apb_debug,
    input wire [1:0]                fifo_debug,
    input wire [DEBUG_BUS_SIZE-1:0] nrx_debug,
    input wire [DEBUG_BUS_SIZE-1:0] ntx_debug,
    input wire [DEBUG_BUS_SIZE-1:0] adc_dp_debug,
    input wire [DEBUG_BUS_SIZE-1:0] adc_vec_debug,
    input wire [DEBUG_BUS_SIZE-1:0] adc_art_debug,
    input wire [DEBUG_BUS_SIZE-1:0] adc_fft_debug,
    input wire [DEBUG_BUS_SIZE-1:0] ack_dp_debug,
    input wire [DEBUG_BUS_SIZE-1:0] pdma_debug,

    // From NM0 emulator
    input wire [DEBUG_BUS_SIZE-1:0] nm0_sim_debug,
    input wire [DEBUG_BUS_SIZE-1:0] nm0_sim_adc_debug,
    input wire [DEBUG_BUS_SIZE-1:0] nm0_sim_cnr_debug,

    // From ACC_IF
    input wire [DEBUG_BUS_SIZE-1:0] acc_debug,

    // FROM top level
	input wire [DEBUG_BUS_SIZE-1:0] irq_debug,
	input wire [DEBUG_BUS_SIZE-1:0] spi_debug,
	input wire [DEBUG_BUS_SIZE-1:0] gpio,

    // To M3
    output reg [DEBUG_BUS_SIZE-1:0] debug_out
);

always @(*) begin
    case (chan_sel)
    5'd0:
        debug_out = nrx_debug;
    5'd1:
        debug_out = ntx_debug;
    5'd2:
        debug_out = ack_dp_debug;
    5'd3:
        debug_out = adc_dp_debug;
    5'd4:
        debug_out = adc_vec_debug;
    5'd5:
        debug_out = adc_art_debug;
    5'd6:
        debug_out = adc_fft_debug;
    5'd7:
        debug_out = pdma_debug;
    5'd8:
        debug_out = acc_debug;
    5'd9:
        debug_out = nm_apb_debug;
    5'd10:
        debug_out = cm_apb_debug;
    5'd11:
        debug_out = spi_debug;
    5'd12:
        debug_out = irq_debug;
    5'd13:
        debug_out = nm0_sim_debug;
    5'd14:
        debug_out = nm0_sim_adc_debug;
    5'd15:
        debug_out = nm0_sim_cnr_debug;
	5'd16:
        debug_out = mode_debug[3:0];
    5'd17:
        debug_out = gpio;
    5'd18:
        debug_out = {spi_debug[0], spi_debug[2], fifo_debug};
    5'd19:
        debug_out = nm1_ack_dp_debug;
    5'd20:
        //// CUSTOM 1
        debug_out = {DEBUG_BUS_SIZE-2'd0, spi_debug[1:0]};
    5'd21:
        //// CUSTOM 2
        debug_out = {nm_apb_debug[2:0], spi_debug[3]};
    5'd22:
        //// CUSTOM 3
        debug_out = 0;
    default: 
        debug_out = 0;
    endcase
end  

endmodule

