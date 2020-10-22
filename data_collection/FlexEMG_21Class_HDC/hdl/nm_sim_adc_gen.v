`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BWRC
// Engineer: Fred Burghardt
// 
// Create Date: 09/10/2016562-05-9148
// Design Name: 
// Module Name: nm_sim_adc_gen
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

module nm_sim_adc_gen #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input  wire rstb,
    input  wire clk,

    input wire twoMHz_stb,

    input wire run,

    input wire stim_ld,
    input wire [2:0] num_stims,

    input wire tx_wait,
    output reg tx_idle,

    output wire dout,

    output wire [DEBUG_BUS_SIZE-1:0] debug,

    input wire nmid
  );

localparam SYNC_TYPE_HDR = 16'b0000000010101100;

//reg [7:0] random_num;

// bit counter
reg bc_rst;
reg [11:0] bit_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || bc_rst) 
        bit_cnt <= 0;
    else if (twoMHz_stb)
        bit_cnt <= bit_cnt + 1;
    else
        bit_cnt <= bit_cnt;
end

// timing strobes
wire next_word;
assign next_word = ((bit_cnt[3:0] == 4'd15) && twoMHz_stb);
wire [7:0] word_cnt;
assign word_cnt = bit_cnt[11:4];
wire end_of_packet;
assign end_of_packet = (word_cnt == 64);
wire next_packet;
assign next_packet = (word_cnt == 124);

// frame counter (to test artifact cancellation, otherwise unused)
reg fc_rst;
reg fc_inc;
reg [6:0] frame_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || fc_rst)
        frame_cnt <= 0;
    else if (fc_inc)
        frame_cnt <= frame_cnt + 1;
    else
        frame_cnt <= frame_cnt;
 end

// shift register
reg [15:0] sr_input;
reg sr_load;
reg [15:0] shift_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        shift_reg <= 16'd0;
    else if (sr_load)
        shift_reg <= sr_input;
    else if (twoMHz_stb)
        shift_reg <= {shift_reg[14:0], 1'b0};
    else
        shift_reg <= shift_reg;
end

assign dout = shift_reg[15];

// stim load delay latch 
reg stim_ld_dly;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        stim_ld_dly <= 1'd0;
    else 
        stim_ld_dly <= stim_ld;
end

// stim counter
reg stim_dec;
reg [2:0] stim_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        stim_cnt <= 8'd0;
    else if (stim_ld_dly)
        stim_cnt <= num_stims;
    else if (stim_dec && stim_cnt > 0)
        stim_cnt <= stim_cnt - 1;
    else
        stim_cnt <= stim_cnt;
end

wire stim;
assign stim = (stim_cnt > 0);

// CRC computer
reg crc_init;
reg crc_compute; 
reg [7:0] crc;
always @(posedge clk) begin
    if (crc_init)
		crc <= {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
    else if (crc_compute)
        crc <= {crc[6], crc[7] ^ crc[5] ^ dout, crc[4], crc[3], crc[2] ^ dout ^ crc[7], crc[7] ^ crc[1] ^ dout, crc[0], crc[7] ^ dout};
end

//// 
//// FSM
////

// state encoding
localparam [3:0] // synopsys enum
    STATE_INIT         = 4'b0000, // 0
    STATE_START        = 4'b0001, // 1
    STATE_START_WAIT   = 4'b0011, // 3
    STATE_PAYLOAD      = 4'b0111, // 7
    STATE_PAYLOAD_WAIT = 4'b1111, // 15
    STATE_CRC          = 4'b1110, // 14
    STATE_CRC_WAIT     = 4'b1100, // 12
    STATE_IDLE         = 4'b1000, // 8
    STATE_IDLE_WAIT    = 4'b1001; // 9

// state variables
reg [3:0] current_state, next_state;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || !run) begin
        current_state <= STATE_INIT;
    end else
        current_state <= next_state;
end

// state logic
always @(*) begin
    tx_idle = 1'b0;
    bc_rst = 1'b0;
    fc_rst = 1'b0;
    fc_inc = 1'b0;
    sr_load = 1'b0;
    crc_init = 1'b0;
    crc_compute = 1'b0;
    stim_dec = 1'b0;
    sr_input = 16'd0;

    next_state = current_state;

    case (current_state)
        STATE_INIT:
        begin
            fc_rst = 1'b1;
            next_state = STATE_START;
        end

        STATE_START:
        begin
                sr_input = SYNC_TYPE_HDR;
                sr_load = 1'b1;
                bc_rst = 1'b1;
            if (!tx_wait) begin
                next_state = STATE_START_WAIT;
            end
        end

        STATE_START_WAIT:
        begin
//            random_num <= $random%256; // works in pre-synthesis sim, can't push it through synthesis
//            sr_input = {stim, 7'd0, (nmid) ? (word_cnt << 1) + frame_cnt : word_cnt + frame_cnt};
            sr_input = {stim, 7'd0, word_cnt};
            crc_init = 1'b1;
            if (next_word) begin
                sr_load = 1'b1;
                next_state = STATE_PAYLOAD;
            end
        end

        STATE_PAYLOAD:
        begin
//            sr_input = {stim, 7'd0, (nmid) ? (word_cnt << 1) + frame_cnt : word_cnt + frame_cnt};
            sr_input = {stim, 7'd0, word_cnt};
            next_state = STATE_PAYLOAD_WAIT;
        end

        STATE_PAYLOAD_WAIT:
        begin
//           random_num <= $random%256; // works in pre-synthesis sim, can't push it through synthesis
//           sr_input = {stim, 7'd0, (nmid) ? (word_cnt << 1) + frame_cnt : word_cnt + frame_cnt};
            sr_input = {stim, 7'd0, word_cnt};
            crc_compute = twoMHz_stb;
            if (next_word)
                if (end_of_packet)
                    next_state = STATE_CRC;
                else begin
                    sr_load = 1'b1;
                    next_state = STATE_PAYLOAD;
                end
        end

        STATE_CRC:
        begin
            sr_input = {crc, 8'd0};
            sr_load = 1'b1;
            fc_inc = 1'b1;
            stim_dec = 1'b1;
            next_state = STATE_CRC_WAIT;
        end

        STATE_CRC_WAIT:
            if (next_word)
                next_state = STATE_IDLE;

        STATE_IDLE:
        begin
            tx_idle = 1'b1;
            next_state = STATE_IDLE_WAIT;
        end

        STATE_IDLE_WAIT:
        begin
            tx_idle = 1'b1;
            if (next_word) 
                if (next_packet) 
                    next_state = STATE_START;
                else
                    next_state = STATE_IDLE;
        end
    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    current_state   // 4
};

endmodule
