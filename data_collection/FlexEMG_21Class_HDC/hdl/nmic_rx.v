////////////////////////////////////////////////////////////////////////////////
// File: nmic_rx.v
// Description: NMIC receiver / fifo interface
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
module nmic_rx #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire clk,
    input wire rstb,

    input wire twoMHz_stb,
    input wire rx_bit,

    output reg adc_done,
    output reg pkt_done,
    output wire rx_bit_sampled,
    output reg bit_valid,
	output reg adc_rx_start,
    output reg ack_rx_start,
    output wire crc_ok,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

// packet type latch
reg pktType, nxtPktType;
always @(posedge clk or negedge rstb) begin
    if (!rstb) 
        pktType <= 1'b0;
    else
        pktType <= nxtPktType;
end

// bit counter
reg bc_preset;
reg bc_dec;
reg [10:0] bit_count;
always @(posedge clk or negedge rstb) begin
    if (!rstb) 
        bit_count <= 0;
    else if (bc_preset)
        if (pktType == 0)
            bit_count <= 11'd38;
        else
            bit_count <= 11'd1030;
    else if (bc_dec)
        bit_count <= bit_count - 1;
end

// sync shift register
reg [12:0] sync_shift_reg;
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        sync_shift_reg <= 13'd0;
    else if (twoMHz_stb)
        sync_shift_reg <= {sync_shift_reg[11:0], rx_bit};
end

assign rx_bit_sampled = sync_shift_reg[0];

// sync comparator
assign sync = (sync_shift_reg == 13'b0000000010101);

// CRC computer
reg crc_rst;
reg crc_init;
reg crc_compute;
reg [7:0] crc;
always @(posedge clk or negedge rstb) begin
    if (!rstb || crc_rst)
        crc <= 8'd0;
    else if (crc_init)
		crc <= {1'b0, ~rx_bit_sampled, 1'b0, 1'b1, ~rx_bit_sampled, ~rx_bit_sampled, 1'b0, ~rx_bit_sampled};
    else if (crc_compute)
        crc <= {crc[6], crc[7] ^ crc[5] ^ rx_bit_sampled, crc[4], crc[3], crc[2] ^ rx_bit_sampled ^ crc[7], crc[7] ^ crc[1] ^ rx_bit_sampled, crc[0], crc[7] ^ rx_bit_sampled};
end

// CRC comparator
assign crc_ok = (crc == 8'd0);

////
//// FSM
////

localparam [3:0] // synopsys enum
    IDLE       = 4'b0000, // 0
    NEWPKT     = 4'b0001, // 1
    TYPEBIT    = 4'b0011, // 3
    WAIT1      = 4'b0010, // 2
    HEADERBIT1 = 4'b0110, // 6
    WAIT2      = 4'b0111, // 7
    HEADERBIT2 = 4'b0101, // 5
    WAIT3      = 4'b1101, // 13
    FIRSTBIT   = 4'b1100, // 12
    WAITn      = 4'b1110, // 14
    NEXTBIT    = 4'b1111, // 15
    WAITc      = 4'b1011, // 11
    CRCBIT     = 4'b1010, // 10
    DONE       = 4'b1000; // 8

// state variables
reg [3:0] current_state, next_state;
always @(posedge clk or negedge rstb) begin
    if (!rstb) 
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// state logic
always @(*) begin
    pkt_done = 1'b0;
    bit_valid = 1'b0;
    ack_rx_start = 1'b0;
    adc_rx_start = 1'b0;
    crc_init = 1'b0;
    crc_rst = 1'b0;
    crc_compute = 1'b0;
    bc_dec = 1'b0;
    bc_preset = 1'b0;
    nxtPktType = pktType;
    adc_done = 1'b0;

    next_state = current_state;

    case (current_state)
        IDLE:
            if (sync)
                next_state = NEWPKT;

        NEWPKT:
        begin
            crc_rst = 1'b1;
            if (twoMHz_stb)
                next_state = TYPEBIT;
        end

        TYPEBIT:
        begin
            nxtPktType = rx_bit_sampled;
            crc_init = 1'b1;
            if (rx_bit_sampled == 0)
                ack_rx_start = 1'b1;
            else
                adc_rx_start = 1'b1;
            next_state = WAIT1;
        end

        WAIT1:
            if (twoMHz_stb)
                next_state = HEADERBIT1;

        HEADERBIT1:
        begin
            crc_compute = 1'b1;
            next_state = WAIT2;
        end

        WAIT2:
            if (twoMHz_stb)
                next_state = HEADERBIT2;

        HEADERBIT2:
        begin
            crc_compute = 1'b1;
            next_state = WAIT3;
        end

        WAIT3:
            if (twoMHz_stb)
                next_state = FIRSTBIT;

        FIRSTBIT:
        begin
            bit_valid = 1'b1;
            bc_preset = 1'b1;
            crc_compute = 1'b1;
            next_state = WAITn;
        end

        WAITn:
            if (twoMHz_stb)
                next_state = NEXTBIT;

        NEXTBIT:
        begin
            bit_valid = 1'b1;
            bc_dec = 1'b1;
            crc_compute = 1'b1;
            if (bit_count == 11'd8)
                next_state = WAITc;
            else
                next_state = WAITn;
        end

        WAITc:
            if (twoMHz_stb)
                next_state = CRCBIT;

        CRCBIT:
        begin
            bc_dec = 1'b1;
            crc_compute = 1'b1;
            if (bit_count == 11'd0)
                next_state = DONE;
            else
                next_state = WAITc;
        end

        DONE:
        begin
            pkt_done = 1'b1;
            adc_done = pktType;
            next_state = IDLE;
        end

        default:
            next_state = IDLE;
    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    current_state   // 4
};

endmodule

