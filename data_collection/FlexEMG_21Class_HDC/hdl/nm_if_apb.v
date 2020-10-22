////////////////////////////////////////////////////////////////////////////////
// File: nm_if_apb.v
// Description: CM-level address decoder
//
// CORTERA NEUROTECHNOLOGIES INC. CONFIDENTIAL
// Unpublished Copyright (C) 2015 CORTERA NEUROTECHNOLOGIES INC.
// All rights reserved.
//
// NOTICE:  All information contained herein is the property of 
// CORTERA NEUROTECHNOLOGIES INC. The intellectual and technical concepts 
// contained herein are proprietary to CORTERA NEUROTECHNOLOGIES INC. and may
// be covered by U.S. and foreign patents, patents in process, and are protected
// by trade secret and/or copyright law.  Dissemination of this information or 
// reproduction of this material is strictly forbidden unless prior written 
// permission is obtained from CORTERA NEUROTECHNOLOGIES INC.
//
// The copyright notice above does not evidence any actual or intended publication
// or disclosure of this source code, which includes information that is confidential
// and/or proprietary, and is a trade secret, of CORTERA NEUROTECHNOLOGIES INC.   
// ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, 
// OR PUBLIC DISPLAY OF OR THROUGH USE OF THIS SOURCE CODE WITHOUT 
// THE EXPRESS WRITTEN CONSENT OF CORTERA NEUROTECHNOLOGIES INC. IS STRICTLY PROHIBITED, AND 
// IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL TREATIES.  THE 
// RECEIPT OR POSSESSION OF THIS SOURCE CODE AND/OR RELATED INFORMATION
// DOES NOT CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE
// ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT MAY 
// DESCRIBE, IN WHOLE OR IN PART.                
//////////////////////////////////////////////////////////////////////////////////
module nm_if_apb #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire clk,
    input wire rstb, 

	input wire [15:0] addr,		    // register address
	input wire [31:0] data_wr,	    // write data in

	input wire rden,			    // read enable (active high)
	input wire wren,			    // write enable (active high)

    //
    // Inputs
    //

    // signals driven by cm_demux
    input wire [1:0] rst_busy,

    // signals driven by the channels
	input wire [33:0] tx_data_rb_n1,
	input wire [33:0] tx_data_rb_n0, 
	input wire [1:0] adc_frame_rdy,
	input wire [1:0] adc_fifo_empty,
	input wire [1:0] ack_rdy,
	input wire [1:0] tx_busy,
	input wire [1:0] fft_rdy,
    input wire [31:0] adc_fft_dout_n1,
    input wire [31:0] adc_fft_dout_n0,
    input wire [31:0] ack_dout_n1,
	input wire [31:0] ack_dout_n0,
    input wire [4:0] label_out,
    input wire [9:0] distance_out,

    // signals driven by the pdma_if block
    input wire [7:0] pdma_data,

    // enables detected in cmam
    input wire pdma_en,
    input wire fft_en,

    //
    // Outputs
    //

	output reg [31:0] data_rd,	    // read data to APB

    output wire ack_rdy_irq_req,    // ACK ready interrupt request

    output wire [1:0] rst_start,

    output wire pdma_fifo_pop,

    output wire [1:0] ack_read,
    output wire [1:0] m3_adc_fifo_pop,

    output reg [1:0] tx_start,
    output reg [1:0] tx_mode,
    output reg [63:0] adc_vec_n1,
    output reg [63:0] adc_vec_n0,
	output reg [33:0] tx_data_n1,
	output reg [33:0] tx_data_n0,
    output wire [1:0] fft_rd_strobe,
    output reg [1:0] mode_in,
    output reg [4:0] label_in,

    // hardware debug signals exported by this module
	output wire [DEBUG_BUS_SIZE-1:0] debug
);
					
////
//// APB read decoder
////

// see cm_if_apb.v for address mapping

// The PDMA channel is normally consumed by the PDMA engine in the MSS
assign pdma_fifo_pop = (addr == 16'h0008) && rden;

// ACK channels read by MSS M3
assign ack_read[0] = (addr == 16'h0018) && rden;
assign ack_read[1] = (addr == 16'h0028) && rden;

// ADC channels read by MSS M3 (debug only - FFT and PDMA blocks must be disabled)
assign m3_adc_fifo_pop[0] = (addr == 16'h001C) && rden && !pdma_en && !fft_en;
assign m3_adc_fifo_pop[1] = (addr == 16'h002C) && rden && !pdma_en && !fft_en;

// FFT data read by MSS M3
assign fft_rd_strobe[0] = (addr == 16'h001C) && rden;
assign fft_rd_strobe[1] = (addr == 16'h002C) && rden;

/// ACK ready interrupt request
assign ack_rdy_irq_req = (ack_rdy != 2'b00);

//
// ADC data ready latches (for non-PDMA operation)
//

reg nm0_has_adc;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || adc_fifo_empty[0]) 
        nm0_has_adc <= 1'b0;
    else if (adc_frame_rdy[0])
        nm0_has_adc <= 1'b1;
end

reg nm1_has_adc;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || adc_fifo_empty[1]) 
        nm1_has_adc <= 1'b0;
    else if (adc_frame_rdy[1])
        nm1_has_adc <= 1'b1;
end

// This code does not support NM3 or NM4
wire [1:0] nm_has_adc;
assign nm_has_adc = {nm1_has_adc, nm0_has_adc};

// Hack to make new reset method look like old one to the GUI
reg rst_stb;
reg [7:0] rst_valid;
reg [7:0] rst_data;
wire any_rst_busy;
reg [1:0] link_rst_type;

assign any_rst_busy = rst_busy[1] || rst_busy[0];

assign rst_start[0] = rst_valid[0] && (link_rst_type == 2'd2) && rst_stb;
assign rst_start[1] = rst_valid[1] && (link_rst_type == 2'd2) && rst_stb;

// data_rd mux
always @(*) begin
	case(addr)
		16'h0000:
            // status word
            data_rd = {
                2'd0, 
                ack_rdy,        // 29:28
                2'd0, 
                fft_rdy,        // 25:24
                2'd0, 
                tx_busy,        // 21:20
                3'd0, 
                any_rst_busy,   // 16
                10'd0, 
                tx_mode,        // 5:4  (readback)
                2'd0, 
                link_rst_type   // 1:0  (readback)
            };

		16'h0004:
            // reset readback
			data_rd = {16'd0, rst_valid, rst_data};

		16'h0008:
            // PDMA (ADC data to M3, debug only)
			data_rd = {24'd0, pdma_data};

        // NM0

		16'h0010:
			data_rd = {30'b0, tx_data_rb_n0[33:32]};	
		16'h0014:
			data_rd = tx_data_rb_n0[31:0];
		16'h0018:
			data_rd = ack_dout_n0;
		16'h001C:
			data_rd = adc_fft_dout_n0[31:0];
 
        // NM1

		16'h0020:
			data_rd = {30'b0, tx_data_rb_n1[33:32]};	
		16'h0024:
			data_rd = tx_data_rb_n1[31:0];
		16'h0028:
			data_rd = ack_dout_n1;
		16'h002C:
			data_rd = adc_fft_dout_n1[31:0];

        // Gestures

        16'h0034:
			data_rd = label_out;
		16'h0038:
			data_rd = distance_out;
 
		default:
			data_rd = 32'd0;
 	endcase
end 

////
//// APB write decoder
////

// see cmam_if_wrap.v for address mapping

always @(posedge clk or negedge rstb) begin
	if (!rstb) begin
		link_rst_type <= 2'd0;
		tx_mode <= 2'd0;
        tx_start <= 2'd0;
        rst_stb <= 1'b0;
		rst_valid <= 8'd0;
		rst_data <= 8'd0;
        adc_vec_n0 <= 64'd0;
        adc_vec_n1 <= 64'd0;
        mode_in <= 2'b0;
        label_in <= 5'b0;
	end 

    else begin
        rst_stb <= 1'b0;
        tx_start <= 2'd0;

		if (wren) begin
            case (addr)
                16'h0000:
                begin
                    // command word
                    tx_start      <= data_wr[13:12];
                    rst_stb       <= data_wr[8];
                    tx_mode       <= data_wr[5:4];
                    link_rst_type <= data_wr[1:0];
                end

                16'h0004:
                    // reset word
                    {rst_valid, rst_data} <= data_wr[15:0];

                // NM0
                16'h0010:
                    tx_data_n0[33:32] <= data_wr[1:0];                
                16'h0014:
                    tx_data_n0[31:0] <= data_wr;
                16'h0018:
                    adc_vec_n0[63:32] <= data_wr;
                16'h001c:
                    adc_vec_n0[31:0] <= data_wr;

                // NM1
                16'h0020:
                    tx_data_n1[33:32] <= data_wr[1:0];                
                16'h0024:
                    tx_data_n1[31:0] <= data_wr;
                16'h0028:
                    adc_vec_n1[63:32] <= data_wr;
                16'h002c:
                    adc_vec_n1[31:0] <= data_wr;

                // Gestures
                16'h0030:
                    {mode_in, label_in} <= data_wr[6:0];
            endcase
		end
	end
end

////
////  hardware debug mux
////

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    rden,           // 1
    data_rd[28],    // 1
    ack_read[0],    // 1
    ack_rdy[0]      // 1
};

endmodule



					
