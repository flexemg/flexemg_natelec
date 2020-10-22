////////////////////////////////////////////////////////////////////////////////
// File: nmic_tx.v
// Description: NMIC transmitter
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
module nmic_tx #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire clk,
    input wire rstb,

    input wire twoMHz_stb,

	input wire [33:0] tx_data_in,		// left justified (MSB is first bit transmitted, LSBs ignored in cmd mode)
	output wire [33:0] tx_data_in_rb,	// readback

	input wire tx_mode,		            // 1: send command; 0: send reg op
	input wire tx_start,
    output wire tx_busy,

	input wire rst_start,
    output wire rst_busy,

	output reg c2n_valid,
    output reg c2n_data,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

wire [5:0] tx_length;
wire dbit;

// bit counter
reg bc_inc;
reg bc_rst;
reg [5:0] bit_count;
always @(posedge clk or negedge rstb) begin
	if (!rstb || bc_rst)
        bit_count <= 5'b0;
    else if (bc_inc)
        bit_count <= bit_count + 1;
    else
        bit_count <= bit_count;
end

// tx_start reg
reg tx_done;
reg tx_start_reg;
always @(posedge clk or negedge rstb) begin
	if (!rstb || tx_done)
        tx_start_reg <= 1'b0;
    else if (tx_start)
        tx_start_reg <= 1'b1;
end

// rst_start reg
reg rst_done;
reg rst_start_reg;
always @(posedge clk or negedge rstb) begin
	if (!rstb || rst_done)
        rst_start_reg <= 1'b0;
    else if (rst_start)
        rst_start_reg <= 1'b1;
end

// CRC register
reg [4:0] tx_crc, nxtcrc;
always @(posedge clk or negedge rstb) begin
	if (!rstb)
        tx_crc = 5'd0;
    else
        tx_crc = nxtcrc;
end

assign tx_length = tx_mode ? 6'd10 : 6'd33;
assign tx_data_in_rb = tx_data_in;
assign dbit = tx_data_in[(tx_mode ? 10 : 33)-bit_count];
assign tx_busy = tx_start_reg;
assign rst_busy = rst_start_reg;

////
//// FSM
////

localparam [2:0] // synopsys enum
    STATE_IDLE     = 3'b000,    // 0
    STATE_TX       = 3'b001,    // 1
    STATE_TX_CRC   = 3'b011,    // 3
    STATE_TX_WAIT  = 3'b010,    // 2
    STATE_RST      = 3'b100,    // 4    
    STATE_RST_2    = 3'b110,    // 6
    STATE_RST_WAIT = 3'b101;    // 5

// state variables
reg [2:0] current_state, next_state;
always @(posedge clk or negedge rstb) begin
	if (!rstb)
        current_state <= STATE_IDLE;
    else
        current_state <= next_state;
end

// logic
always @(*) begin
    bc_inc = 1'b0;
    bc_rst = 1'b0;
    tx_done = 1'b0;
    rst_done = 1'b0;
    nxtcrc = tx_crc;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
        begin
            c2n_valid = 1'b0;
            c2n_data = 1'b0;

            bc_rst = 1'b1;
            nxtcrc = 5'b01100;	// equivalent to initializing verifier with 11111
            if (twoMHz_stb)
                if (tx_start_reg)
                    next_state = STATE_TX;
                else if (rst_start_reg)
                    next_state = STATE_RST;
        end

        STATE_TX:
        begin
            c2n_valid = 1'b1;
            c2n_data = dbit;

            if (twoMHz_stb) begin
                nxtcrc = {tx_crc[3], tx_crc[2], (tx_crc[1] ^ (tx_crc[4] ^ dbit)), tx_crc[0], tx_crc[4] ^ dbit};
                if (bit_count < tx_length)
                    bc_inc = 1'b1;
                else if (bit_count == tx_length) begin
                    bc_rst = 1'b1;
                    next_state = STATE_TX_CRC;
                end
            end
        end

        STATE_TX_CRC:
        begin
            c2n_valid = 1'b1;
            c2n_data = tx_crc[4-bit_count[2:0]];

            if (twoMHz_stb && bit_count < 4)
                bc_inc = 1'b1; 
            else if (twoMHz_stb && bit_count == 4) begin
                tx_done = 1'b1;
                next_state = STATE_IDLE;
            end
        end

        STATE_TX_WAIT: 
        begin
            c2n_valid = 1'b0;
            c2n_data = 1'b0;

            if (tx_start == 0)
                next_state = STATE_IDLE;
        end

        STATE_RST:
        begin
            c2n_valid = 1'b1;
            c2n_data = 1'b0;

            next_state = STATE_RST_2;
        end

        STATE_RST_2:
        begin
            c2n_valid = 1'b1;
            c2n_data = 1'b0;

            next_state = STATE_RST_WAIT;
        end

        STATE_RST_WAIT:
        begin
            c2n_valid = 1'b0;
            c2n_data = 1'b0;

            if (rst_start == 0) begin
                rst_done = 1'b1;
                next_state = STATE_IDLE;
            end
        end

        default:
        begin
            c2n_valid = 1'b0;
            c2n_data = 1'b0;

            next_state = STATE_IDLE;
        end
    endcase
end
				
localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    tx_busy,        // 1
    current_state   // 3
};

endmodule
