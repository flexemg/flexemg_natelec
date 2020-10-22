///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: nm.v
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

module nm_sim #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
	input wire clk, 
	input wire rstb,
 
    input wire run,

    input wire stim_ld,
    input wire [2:0] num_stims,

    input wire c2n_valid,
    input wire c2n_data,

    output wire n2c_data,

    output wire [DEBUG_BUS_SIZE-1:0] debug,
    output wire [DEBUG_BUS_SIZE-1:0] adc_debug,
    output wire [DEBUG_BUS_SIZE-1:0] cnr_debug,

    input wire nmid
);

wire adc_idle;
wire adc_data;

wire cnr_req;
wire cnr_grant;
wire cnr_data;

assign cnr_grant = (cnr_req && adc_idle);
assign n2c_data = (cnr_grant) ? cnr_data : adc_data;

// clk divider (20MHz system clock / 10 = 2Mbps)
reg [3:0] clk_div;
always @ (posedge clk or negedge rstb) begin
    if (!rstb) 
        clk_div <= 4'd0;
    else if (clk_div == 4'd9)
        clk_div <= 4'd0;
    else 
        clk_div <= clk_div + 1;
end

wire twoMHz_stb;
assign twoMHz_stb = (clk_div == 4'd0);

nm_sim_adc_gen #(
    .DEBUG_BUS_SIZE(DEBUG_BUS_SIZE)
  ) nm_adc (
    .clk(clk),
    .rstb(rstb),

    .twoMHz_stb(twoMHz_stb),

    .run(run),

    .stim_ld(stim_ld),
    .num_stims(num_stims),

    .tx_idle(adc_idle),
    .tx_wait(cnr_grant),

    .dout(adc_data),

    .debug(adc_debug),

    .nmid(nmid)
);
    
nm_sim_cmd_and_reg #(
    .DEBUG_BUS_SIZE(DEBUG_BUS_SIZE)
  ) nm_cnr (
    .clk(clk),
    .rstb(rstb),

    .run(run),

    .rx_valid(c2n_valid),
    .rx_bit(c2n_data),

    .tx_rdy(cnr_req),
    .tx_ok(cnr_grant),

    .dout(cnr_data),

    .debug(cnr_debug)
);

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    cnr_req,    // 1
    cnr_grant,  // 1
    cnr_data,   // 1
    twoMHz_stb  // 1
};

endmodule

