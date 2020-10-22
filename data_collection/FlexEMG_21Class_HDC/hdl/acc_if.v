///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: acc_if.v
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

module acc_if #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
	input wire pclk,            // 20MHz
	input wire aclk,            // 1MHz
	input wire rstb,
 
	input wire [15:0] addr,		// register address
	input wire [31:0] data_wr,	// byte data in
	input wire wr_enable,		// write enable (active high)
	output reg [31:0] data_rd,	// read data out
	input wire rd_enable,		// read enable (active high)

    input wire acc_irq_en,
    input wire acc_irq,

    output reg i2c_scl,
    input wire i2c_sda_i,
    output reg i2c_sda_o,

    output wire [47:0] acc_data,

    output wire fifo_overflow,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

localparam ADDR_MPU = 4'h1;

wire apb_scl;
reg apb_sda_i;
wire apb_sda_o;
wire apb_req;
wire apb_grant;
wire [7:0] apb_data_rd;

wire irq_scl;
reg  irq_sda_i;
wire irq_sda_o;

wire mux_sel;

wire apb_reg_rd_ok;
wire apb_reg_wr_ok;

wire acc_irq_ok;

wire [DEBUG_BUS_SIZE-1:0] if_debug;
wire [DEBUG_BUS_SIZE-1:0] apb_debug;
wire [DEBUG_BUS_SIZE-1:0] irq_debug;
//assign debug = apb_debug;
assign debug = if_debug;

wire apb_busy;
assign apb_busy = apb_grant;

// Status reg
wire [7:0] status;
assign status[0] = apb_reg_rd_ok;
assign status[1] = apb_reg_wr_ok;
assign status[2] = acc_irq_ok;
assign status[3] = apb_busy;
assign status[4] = apb_req;
assign status[5] = irq_debug[3];    // data_rdy
assign status[6] = fifo_overflow;

// Command reg (none yet)
//reg [7:0] command;

// 4 x 2:1 mux
always @ (*) begin
    irq_sda_i <= 1'b0;
    apb_sda_i <= 1'b0;

    if (mux_sel) begin
        i2c_scl     <= apb_scl;
        apb_sda_i   <= i2c_sda_i;
        i2c_sda_o   <= apb_sda_o;
    end else begin
        i2c_scl     <= irq_scl;
        irq_sda_i   <= i2c_sda_i;
        i2c_sda_o   <= irq_sda_o;
    end
end

// Local address decoder
// Range 0x1000 - 0x1ffff is reserved for the accelerometer.
// Bits 11-4 are local addresses.
// If bits 11-4 are greater than 0x1a it's interpreted as an accelerometer 
// register address. This is handled in the clock domain crossing latches below.
// Otherwise it's an HDL status or command address.
wire [7:0] local_addr;
assign local_addr = addr[11:4];
always @ (*) begin
    data_rd <= 32'd0;

    if (addr[15:12] == ADDR_MPU)
        // decoding for read data bus 
        if (local_addr == 8'h00)
            // local status 
            data_rd <= {24'd0, status};
        else if (local_addr == 8'h01)
            // most recent accelerometer X data
            data_rd <= {16'd0, acc_data[47:16]};            
        else if (local_addr == 8'h02)
            // most recent accelerometer Y data
            data_rd <= {16'd0, acc_data[31:16]};            
        else if (local_addr == 8'h03)
            // most recent accelerometer Z data
            data_rd <= {16'd0, acc_data[15:0]};            
        else if (local_addr == 8'h04)
            // most recent register read value
            data_rd <= {24'd0, apb_data_rd};            
        
//        else if (wr_enable)
            // is a local command word write
//            command <= data_wr;
end

////
//// APB Interface
//// The APB interface crosses clock domains here, from 20MHz to 1MHz
//// The next few costructs latch rden, wren, addr and data fron the APB bus.
////

// APB interface rden latch
reg apb_rden_latch;
wire apb_rden_clr;
always @ (posedge pclk or negedge rstb) begin
    if (!rstb || apb_rden_clr)
        apb_rden_latch <= 1'b0;
    else if (local_addr >= 8'h1a && rd_enable) 
        apb_rden_latch <= 1'b1;
    else
        apb_rden_latch <= apb_rden_latch;
 end

// APB interface wren latch
reg apb_wren_latch;
wire apb_wren_clr;
always @ (posedge pclk or negedge rstb) begin
    if (!rstb || apb_wren_clr)
        apb_wren_latch <= 1'b0;
    else if (local_addr >= 8'h1a && wr_enable) 
        apb_wren_latch <= 1'b1;
    else
        apb_wren_latch <= apb_wren_latch;
end

// APB interface addr latch
reg [7:0] apb_addr;
always @ (posedge pclk) begin
    if (local_addr >= 8'h1a && (wr_enable || rd_enable)) 
        apb_addr <= local_addr;
    else
        apb_addr <= apb_addr;
end

// APB interface din latch
reg [7:0] apb_data_wr;
always @ (posedge pclk) begin
    if (local_addr >= 8'h1a && wr_enable) 
        apb_data_wr <= data_wr[7:0];
    else
        apb_data_wr <= apb_data_wr;
end

// APB bus processor
acc_apb_proc #(
    .DEBUG_BUS_SIZE(DEBUG_BUS_SIZE)
  )
  acc_apb_p (
    .clk(aclk), 
    .rstb(rstb), 

    .addr(apb_addr),
    .data_wr(apb_data_wr),
    .wren_latch(apb_wren_latch),
    .wren_clr(apb_wren_clr),
    .data_rd(apb_data_rd),
    .rden_latch(apb_rden_latch),
    .rden_clr(apb_rden_clr),

    .apb_req(apb_req),
    .apb_grant(apb_grant),

    .scl(apb_scl),
    .sda_i(apb_sda_i),
    .sda_o(apb_sda_o),

    .rd_ok(apb_reg_rd_ok),
    .wr_ok(apb_reg_wr_ok),

    .debug(apb_debug)
);

////
//// IRQ Interface
////

acc_irq_proc #(
    .DEBUG_BUS_SIZE(DEBUG_BUS_SIZE)
  ) 
  acc_irq_p (
    .clk(aclk), 
    .rstb(rstb), 

    .mux_sel(mux_sel),

    .acc_irq(acc_irq),
    .irq_en(acc_irq_en),
    .irq_ok(acc_irq_ok),

    .apb_req(apb_req),
    .apb_grant(apb_grant),

    .scl(irq_scl),
    .sda_i(irq_sda_i),
    .sda_o(irq_sda_o),

    .acc_data(acc_data),

    .fifo_overflow(fifo_overflow),  // debug

    .debug(irq_debug)
);

////
//// Debug channel bit assignment.
////

localparam ASSIGNED_DEBUG_BITS = 4;

assign if_debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    apb_reg_wr_ok,      // 1
    apb_reg_rd_ok,      // 1
    acc_irq_ok,         // 1
    acc_irq             // 1
};

endmodule

