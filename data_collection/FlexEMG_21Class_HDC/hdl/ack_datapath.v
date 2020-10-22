////////////////////////////////////////////////////////////////////////////////
// File: ack_datapath.v
// Description: NMIC receiver / ACK fifo interface
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
module ack_datapath #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
	input wire clk,
    input wire rstb,

    input wire start,

    input wire rx_bit,
    input wire rx_bit_valid,

    input wire crc_ok,
    input wire pkt_done,

    input wire ack_read,          // asserted when M3 reads the ACK address

	output reg ack_rdy, 
	output reg [31:0] ack_dout,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

// bit counter
reg bc_preset;
reg bc_dec;
reg [5:0] bit_ctr;
always @(posedge clk or negedge rstb) begin
    if (!rstb || bc_preset)
        bit_ctr <= 6'd32;
    else if (bc_dec && bit_ctr != 0)
        bit_ctr <= bit_ctr - 1;
    else
        bit_ctr <= bit_ctr;
end

// bit counter zero compare
wire bc_zero;
assign bc_zero = (bit_ctr == 0);

// shift/load register
reg sh_en;
reg sh_rst;
always @(posedge clk or negedge rstb) begin
    if (!rstb || sh_rst)
        ack_dout <= 0;
    else if (sh_en)
		ack_dout <= {ack_dout[30:0], rx_bit};
    else 
		ack_dout <= ack_dout;
end

////
//// FSM
////

// _A indicates address, _D indicates data
localparam [2:0] // synopsys enum
    STATE_IDLE     = 3'd0,  // 000
    STATE_WAIT_BIT = 3'd1,  // 001
    STATE_SHIFT    = 3'd3,  // 011
    STATE_WAIT_CRC = 3'd5,  // 101
    STATE_READY    = 3'd4;  // 100

reg [2:0] current_state, next_state;

// state variables
always @(posedge clk or negedge rstb) begin
    if (!rstb) 
        current_state <= STATE_IDLE;
    else
        current_state <= next_state;
end

// next state logic
always @(*) begin
    bc_preset = 1'b0;
    bc_dec = 1'b0;
    sh_en = 1'b0;
    sh_rst = 1'b0;
    ack_rdy = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
        begin
            sh_rst = 1'b1;
            if (start) begin
                bc_preset = 1'b1;
                next_state = STATE_WAIT_BIT;
            end
        end

        STATE_WAIT_BIT:
            if (rx_bit_valid)
                next_state = STATE_SHIFT;
            else if (bc_zero)
                next_state = STATE_WAIT_CRC;

        STATE_SHIFT:
        begin
            sh_en = 1'b1;
            bc_dec = 1'b1;
            next_state = STATE_WAIT_BIT;
        end

        STATE_WAIT_CRC:
            if (pkt_done)
                if (crc_ok)
                    next_state = STATE_READY;
                else
                    next_state = STATE_IDLE;

        STATE_READY:
        begin
            ack_rdy = 1'b1;
            if (ack_read)
                next_state = STATE_IDLE;
        end

        default:
            next_state = STATE_IDLE;
    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    start,          // 1
    current_state   // 3
};

endmodule 
