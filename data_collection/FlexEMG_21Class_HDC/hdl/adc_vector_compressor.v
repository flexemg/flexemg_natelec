////////////////////////////////////////////////////////////////////////////////
// File: adc_vector_compressor.v
// Description: 
//////////////////////////////////////////////////////////////////////////////////
module adc_vector_compressor #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire clk,
    input wire rstb,

    input wire fifo_full,
    output wire fifo_push,
    
    input wire start,

    input wire pkt_done,
    input wire crc_ok,

    input wire [1023:0] frame,

    output reg [8:0] mem_addr,
    output wire [15:0] mem_wr_data,
    output reg mem_we,
    output reg mem_re,

    output reg stim_flag,
    output reg frame_rdy,

    output wire [6:0] num_active_chans,

    output reg [2:0] mem_head_ptr,

    input wire [63:0] vector_bits,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

reg stim_test;

// channel counter
reg chan_cnt_preset;
reg chan_cnt_dec;
reg [6:0] chan_cnt;
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        chan_cnt <= 7'd0;
    else if (chan_cnt_preset)
        chan_cnt <= 7'd64;
    else if (chan_cnt_dec)
        chan_cnt <= chan_cnt - 1;
    else
        chan_cnt <= chan_cnt;
end

// mem index counter
reg mem_idx_rst;
reg mem_idx_inc;
reg [6:0] mem_idx;
always @(posedge clk or negedge rstb) begin
    if (!rstb || mem_idx_rst)
        mem_idx <= 7'd0;
    else if (mem_idx_inc)
        mem_idx <= mem_idx + 1;
    else
        mem_idx <= mem_idx;
end

assign num_active_chans = mem_idx;
assign fifo_push = mem_idx_inc;

// 64:1 mux
assign mem_wr_data = (chan_cnt > 0) ? frame[(chan_cnt-1)*16 +: 16] : 16'd0;

// head frame counter
reg mem_head_ptr_inc;
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        mem_head_ptr = 0;
    else if (mem_head_ptr_inc)
        mem_head_ptr = mem_head_ptr + 1;  // wraps at 7
    else
        mem_head_ptr = mem_head_ptr;
end

wire [2:0] mem_tail_ptr;
assign mem_tail_ptr = (mem_head_ptr == 3'd7) ? 0 : mem_head_ptr + 1;

////
//// FSM
////

localparam [2:0] // synopsys enum
    STATE_IDLE             = 3'b000,    // 0
    STATE_WAIT             = 3'b001,    // 1
    STATE_RUN              = 3'b011,    // 3
    STATE_WR_MEM           = 3'b111,    // 7
    STATE_RD_MEM_PUSH_FIFO = 3'b110,    // 6
    STATE_INC_HEAD_TAIL    = 3'b010;    // 2

// state variables
reg [2:0] current_state, next_state;
always @(posedge clk or negedge rstb) begin
    if (!rstb) 
        current_state <= STATE_IDLE;
    else
        current_state <= next_state;
end

// state logic
always @(*) begin
    mem_we = 1'b0;
    mem_re = 1'b0;
    mem_addr = 9'd0;

    chan_cnt_preset = 1'b0;
    chan_cnt_dec = 1'b0;

    mem_idx_rst = 1'b0;
    mem_idx_inc = 1'b0;

    mem_head_ptr_inc = 1'b0;

    frame_rdy = 1'b0;

    stim_test = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
        begin
            chan_cnt_preset = 1'b1;
            if (start && !fifo_full)
                next_state = STATE_WAIT;
        end

        STATE_WAIT:
        begin
            mem_idx_rst = 1'b1;
            if (pkt_done)
                if (crc_ok) begin
                    stim_test = 1'b1;
                    next_state = STATE_RUN;
                end else
                    next_state = STATE_IDLE;
        end

        STATE_RUN:
        begin
            if (chan_cnt == 0)
                next_state = STATE_INC_HEAD_TAIL;
            else if (vector_bits[7'd64-chan_cnt])
                next_state = STATE_WR_MEM;
            else
                chan_cnt_dec = 1'b1;
        end

        STATE_WR_MEM:
        begin
            mem_addr = {mem_head_ptr, mem_idx[5:0]};
            mem_we = 1'b1;
            next_state = STATE_RD_MEM_PUSH_FIFO;
        end

        STATE_RD_MEM_PUSH_FIFO:
        begin
            mem_addr = {mem_tail_ptr, mem_idx[5:0]};
            mem_re = 1'b1;
            chan_cnt_dec = 1'b1;
            mem_idx_inc =1'b1;
            next_state = STATE_RUN;
        end

        STATE_INC_HEAD_TAIL:
        begin
            mem_head_ptr_inc = 1'b1;
            frame_rdy = 1'b1;
            next_state = STATE_IDLE;
        end

        default:
            next_state = STATE_IDLE;
    endcase
end

// stim flag latch
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        stim_flag = 1'b0;
    else if (stim_test)
        stim_flag = frame[(1*16)-1]  | frame[(2*16)-1]  | frame[(3*16)-1]  | frame[(4*16)-1]  | 
                    frame[(5*16)-1]  | frame[(6*16)-1]  | frame[(7*16)-1]  | frame[(8*16)-1]  | 
                    frame[(9*16)-1]  | frame[(10*16)-1] | frame[(11*16)-1] | frame[(12*16)-1] | 
                    frame[(13*16)-1] | frame[(14*16)-1] | frame[(15*16)-1] | frame[(16*16)-1] | 
                    frame[(17*16)-1] | frame[(18*16)-1] | frame[(19*16)-1] | frame[(20*16)-1] | 
                    frame[(21*16)-1] | frame[(22*16)-1] | frame[(23*16)-1] | frame[(24*16)-1] |
                    frame[(25*16)-1] | frame[(26*16)-1] | frame[(27*16)-1] | frame[(28*16)-1] |
                    frame[(29*16)-1] | frame[(30*16)-1] | frame[(31*16)-1] | frame[(32*16)-1] | 
                    frame[(33*16)-1] | frame[(34*16)-1] | frame[(35*16)-1] | frame[(36*16)-1] |
                    frame[(37*16)-1] | frame[(38*16)-1] | frame[(39*16)-1] | frame[(40*16)-1] | 
                    frame[(41*16)-1] | frame[(42*16)-1] | frame[(43*16)-1] | frame[(44*16)-1] | 
                    frame[(45*16)-1] | frame[(46*16)-1] | frame[(47*16)-1] | frame[(48*16)-1] | 
                    frame[(49*16)-1] | frame[(50*16)-1] | frame[(51*16)-1] | frame[(52*16)-1] | 
                    frame[(53*16)-1] | frame[(54*16)-1] | frame[(55*16)-1] | frame[(56*16)-1] | 
                    frame[(57*16)-1] | frame[(58*16)-1] | frame[(59*16)-1] | frame[(60*16)-1] | 
                    frame[(61*16)-1] | frame[(62*16)-1] | frame[(63*16)-1] | frame[(64*16)-1];
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    start,              // 1
    current_state       // 3
};

endmodule

