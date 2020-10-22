`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BWRC
// Engineer: Fred Burghardt
// 
// Create Date: 09/10/2016562-05-9148
// Design Name: 
// Module Name: nm_pkt_gen
// Project Name: OMNI
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module nm_sim_cmd_and_reg #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input  wire rstb,
    input  wire clk,

    input wire run,

    input wire rx_valid,
    input wire rx_bit,

    output reg tx_rdy,
    input wire tx_ok,

    output wire dout,

    output wire [DEBUG_BUS_SIZE-1:0] debug
  );

// Return packet is statically defined here for simulation purposes.
// Packet includes sync (b0000000010101), type bit (b0), header bits (b00), payload (0x01234567) and CRC (0xf8).
// CRC is computed on type bit, header bits and 32 bit payload using an Excel spreadsheet.
// Binary representation of packet: 0000 0000 1010 1000 0000 0001 0010 0011 0100 0101 0110 0111 1111 1000
// Hex represetnation of packet: 0x00a801234567
//localparam RETURN_PACKET = 56'h00a801234567f8;
localparam TX_SYNC_AND_HDR = 16'h00a8;

reg idle;

// strobe generator
wire twoMHz_stb;
reg [3:0] clk_counter;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || idle)
        clk_counter <= 0;
    else
        clk_counter <= (clk_counter == 4'd9) ? 4'd0 : clk_counter + 1;
end

assign twoMHz_stb = (clk_counter == 9);

// bit counter
reg bc_rst;
reg bc_inc;
reg [5:0] bit_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || bc_rst)
        bit_cnt <= 6'd0;
    else if (bc_inc)
        bit_cnt <= bit_cnt + 1;
    else
        bit_cnt <= bit_cnt;
end

// Rx shift register
reg rx_sr_shift;
reg [31:0] rx_shift_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        rx_shift_reg <= 0;
    else if (rx_sr_shift)
        rx_shift_reg <= {rx_shift_reg[30:0], rx_bit};
    else
        rx_shift_reg <= rx_shift_reg;
end

// split out address and data from receive reg for use with register file and tx shift reg
wire [15:0] addr, data;
assign addr = rx_shift_reg[31:16];
assign data = rx_shift_reg[15:0];

// NM registers value storage
reg  nm_regfile_write;
reg [15:0] nm_reg_file [0:31];
always @ (posedge clk) begin
    if (nm_regfile_write)
        nm_reg_file[addr] <= data;
end

// Tx CRC computer
reg tx_crc_init, tx_crc_compute;
reg [7:0] crc;
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        crc <= 8'd0;
    else if (tx_crc_init)
		crc <= {1'b0, ~dout, 1'b0, 1'b1, ~dout, ~dout, 1'b0, ~dout};
    else if (tx_crc_compute)
        crc <= {crc[6], crc[7] ^ crc[5] ^ dout, crc[4], crc[3], crc[2] ^ dout ^ crc[7], crc[7] ^ crc[1] ^ dout, crc[0], crc[7] ^ dout};
end

// Tx CRC compute delay signal
reg tx_crc_go;
always @ (posedge clk) begin
    if (bc_inc)
        tx_crc_go = 1'b1;
    else
        tx_crc_go = 1'b0;
end

// Tx shift register
reg tx_sr_load, tx_sr_crc_load, tx_sr_shift;
reg [47:0] tx_shift_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        tx_shift_reg <= 0;
    else if (tx_sr_load)
        tx_shift_reg <= {TX_SYNC_AND_HDR, addr, nm_reg_file[addr]};
    else if (tx_sr_crc_load)
        tx_shift_reg <= {crc, 40'd0};
    else if (tx_sr_shift)
        tx_shift_reg <= {tx_shift_reg[46:0], 1'b0};
    else
        tx_shift_reg <= tx_shift_reg;
end

assign dout = tx_shift_reg[47];

// ready latch
reg tx_req;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || idle) 
        tx_rdy <= 1'd0;
    else if (tx_req)
        tx_rdy <= 1'b1;
end

reg cmd_bit = 1'b0;

//// 
//// FSM
////

// state encoding
localparam [3:0] // synopsys enum
    STATE_VALID_WAIT     = 4'b0000,  // 0
    STATE_RESET_TEST     = 4'b0001,  // 1
    STATE_TYPE_BIT       = 4'b0011,  // 3
    STATE_COMMAND_WAIT   = 4'b0010,  // 2
    STATE_REG_OP_BIT     = 4'b0111,  // 7

    STATE_REG_WRITE      = 4'b0110,  // 6
    STATE_REG_WRITE_SAVE = 4'b0100,  // 4
    STATE_REG_WRITE_WAIT = 4'b1100,  // 12

    STATE_REG_READ       = 4'b0101,  // 5
    STATE_OK_WAIT        = 4'b1101,  // 13
    STATE_TX_SYNC        = 4'b1111,  // 15
    STATE_TX_HDR_PLD     = 4'b1011,  // 11
    STATE_TX_CRC         = 4'b1010;  // 10

// state variables
reg [3:0] current_state, next_state;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || !run) begin
        current_state <= STATE_VALID_WAIT;
    end else
        current_state <= next_state;
end

// state logic
always @(*) begin
    bc_rst = 1'b0;
    bc_inc = 1'b0;
    rx_sr_shift = 1'b0;
    tx_sr_shift = 1'b0;
    tx_sr_load = 1'b0;
    tx_sr_crc_load = 1'b0;
    tx_crc_init = 1'b0;
    tx_crc_compute = 1'b0;
    tx_req = 1'b0;
    nm_regfile_write = 1'b0;
    idle = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_VALID_WAIT:
        begin
            idle = 1'b1;
            bc_rst = 1'b1;
            if (rx_valid) begin
                cmd_bit = rx_bit;
                next_state = STATE_RESET_TEST;
            end
        end

        STATE_RESET_TEST:
        begin
            if (rx_valid) begin
                next_state = STATE_VALID_WAIT;
            end else
                next_state = STATE_TYPE_BIT;
        end

        STATE_TYPE_BIT:
        begin
            if (cmd_bit) begin
                next_state = STATE_COMMAND_WAIT;
            end else
                next_state = STATE_REG_OP_BIT;
        end

        STATE_COMMAND_WAIT:
        begin
            bc_inc = twoMHz_stb;
            if (bit_cnt == 20) 
                next_state = STATE_VALID_WAIT;
        end

        STATE_REG_OP_BIT:
        begin
            if (rx_valid)
                if (rx_bit) 
                    next_state = STATE_REG_WRITE;
                else
                    next_state = STATE_REG_READ;
        end

        STATE_REG_WRITE:
        begin
            bc_inc = rx_valid;
            rx_sr_shift = rx_valid;
            if (bit_cnt == 32) 
                next_state = STATE_REG_WRITE_SAVE;
        end

        STATE_REG_WRITE_SAVE:
        begin
            nm_regfile_write = 1'b1;
            next_state = STATE_REG_WRITE_WAIT;
        end

        STATE_REG_WRITE_WAIT:
        begin
            bc_inc = rx_valid;
            if (bit_cnt == 37) 
                next_state = STATE_VALID_WAIT;
        end

        STATE_REG_READ:
        begin
            bc_inc = rx_valid;
            rx_sr_shift = rx_valid;
            if (bit_cnt == 32) 
                next_state = STATE_OK_WAIT;
        end

        STATE_OK_WAIT:
        begin
            bc_rst = 1'b1;
            tx_sr_load = 1'b1;
            tx_req = 1'b1;
            if (tx_ok) 
                next_state = STATE_TX_SYNC;
        end

        STATE_TX_SYNC:
        begin
            bc_inc = twoMHz_stb;
            tx_sr_shift = twoMHz_stb;
            if (bit_cnt == 13) begin
                tx_crc_init = 1'b1;
                next_state = STATE_TX_HDR_PLD;
            end
        end

        STATE_TX_HDR_PLD:
        begin
            bc_inc = twoMHz_stb;
            tx_sr_shift = twoMHz_stb;
            tx_crc_compute = tx_crc_go;
            if (bit_cnt == 47 && twoMHz_stb) begin
                tx_sr_crc_load = 1'b1;
                next_state = STATE_TX_CRC;
            end
        end

        STATE_TX_CRC:
        begin
            bc_inc = twoMHz_stb;
            tx_sr_shift = twoMHz_stb;
            if (bit_cnt == 56)
                next_state = STATE_VALID_WAIT;
        end

        default:
            next_state = STATE_VALID_WAIT;

    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    current_state   // 4
};

endmodule
