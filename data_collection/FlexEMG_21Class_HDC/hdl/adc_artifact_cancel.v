////////////////////////////////////////////////////////////////////////////////
// File: adc_artifact_cance;.v
// Description: 
//////////////////////////////////////////////////////////////////////////////////
module adc_artifact_cancel #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire clk,
    input wire rstb,

    input wire artifact_en,
    input wire stim_flag,
    input wire frame_rdy,

    input wire [6:0] num_active_chans,
    input wire [2:0] mem_head_ptr,

    output wire [8:0] mem_addr,
    input wire [15:0] mem_dout,
	output reg [15:0] mem_wr_data,
    output reg mem_we,
    output reg mem_re,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

reg [2:0] frame_ptr;

reg [6:0] active_chans, active_chans_int;
reg [2:0] pre_stim_frame_ptr, pre_stim_frame_ptr_int;
reg [15:0] rdata_head, rdata_head_int;
reg [15:0] rdata_pre_stim, rdata_pre_stim_int;

//reg [15:0] rdata_diff;
//reg [2:0] rdata_denom;

// register inference
always @(posedge clk or negedge rstb) begin
    if (!rstb) begin
        active_chans = 7'd0;
        pre_stim_frame_ptr = 3'd0;
        rdata_head = 16'd0;
        rdata_pre_stim = 16'd0;
    end else begin
        active_chans = active_chans_int;
        pre_stim_frame_ptr = pre_stim_frame_ptr_int;
        rdata_head = rdata_head_int;
        rdata_pre_stim = rdata_pre_stim_int;
    end
end

// frame index counter
reg frame_idx_preset;
reg frame_idx_inc;
reg [2:0] frame_idx;
always @(posedge clk or negedge rstb) begin
    if (!rstb || frame_idx_preset)
        frame_idx <= 1;
    else if (frame_idx_inc)
        frame_idx <= frame_idx + 1;  // wraps at 8
    else
        frame_idx <= frame_idx;
end

// channel index counter
reg chan_idx_inc;
reg chan_idx_rst;
reg [6:0] chan_idx;
always @(posedge clk or negedge rstb) begin
    if (!rstb || chan_idx_rst)
        chan_idx <= 0;
    else if (chan_idx_inc)
        chan_idx <= chan_idx + 1;
    else
        chan_idx <= chan_idx;
end

assign mem_addr = {frame_ptr, chan_idx[5:0]};

// stim frame counter
reg stim_count_rst;
reg stim_count_inc;
reg [2:0] stim_count;
always @(posedge clk or negedge rstb) begin
    if (!rstb || stim_count_rst)
        stim_count <= 0;
    else if (stim_count_inc)
        stim_count <= stim_count + 1;  // should never wrap
    else
        stim_count <= stim_count;
end

////
//// FSM
////

localparam [3:0] // synopsys enum
    STATE_INIT               = 4'b0000,  // 0
    STATE_IDLE               = 4'b0001,  // 1
    STATE_STIM_ON_1          = 4'b0011,  // 3
    STATE_STIM_ON_2          = 4'b0111,  // 7
    STATE_READ_HEAD          = 4'b1111,  // 15
    STATE_READ_PRESTIM       = 4'b1110,  // 14
    STATE_WRITE_DATA         = 4'b1100,  // 12
    STATE_NEXT_CHAN_INC      = 4'b1000,  // 8
    STATE_NEXT_CHAN          = 4'b1001;  // 9

// state variables
reg [3:0] current_state, next_state;
always @(posedge clk or negedge rstb) begin
    if (!rstb) 
        current_state <= STATE_INIT;
    else
        current_state <= next_state;
end

// state logic
always @(*) begin
    mem_we = 1'b0;
    mem_re = 1'b0;
    frame_idx_inc = 1'b0;
    frame_idx_preset = 1'b0;
    chan_idx_inc = 1'b0;
    chan_idx_rst = 1'b0;
    stim_count_rst = 1'b0;
    stim_count_inc = 1'b0;
    frame_ptr = 3'd0;
    mem_wr_data = 16'd0;

    active_chans_int = active_chans;
    rdata_head_int = rdata_head;
    rdata_pre_stim_int = rdata_pre_stim;
    pre_stim_frame_ptr_int = pre_stim_frame_ptr;

    next_state = current_state;

    case (current_state)
        STATE_INIT:
        begin
            active_chans_int = 7'd0;
            rdata_head_int = 16'd0;
            rdata_pre_stim_int = 16'd0;
            pre_stim_frame_ptr_int = 3'd0;
            next_state = STATE_IDLE;
        end

        STATE_IDLE:
        begin
            chan_idx_rst = 1'b1;
            stim_count_rst = 1'b1;
            if (!stim_flag)
                pre_stim_frame_ptr_int = (mem_head_ptr == 0) ? 7 : mem_head_ptr - 1;
            if (artifact_en && frame_rdy && stim_flag)
                next_state = STATE_STIM_ON_1;
        end

        STATE_STIM_ON_1:
        begin
            stim_count_inc = 1'b1;
            next_state = STATE_STIM_ON_2;
        end

        STATE_STIM_ON_2:
        begin
            if (frame_rdy)
                if (stim_flag)
                    next_state = STATE_STIM_ON_1;
                else begin
                    active_chans_int = num_active_chans;
                    next_state = STATE_READ_HEAD;
                end
        end

        STATE_READ_HEAD:
        begin
            frame_ptr = (mem_head_ptr == 0) ? 7 : mem_head_ptr - 1;
            rdata_head_int = mem_dout;
            mem_re = 1'b1;
            next_state = STATE_READ_PRESTIM;
        end

        STATE_READ_PRESTIM:
        begin
            frame_ptr = pre_stim_frame_ptr;
            rdata_pre_stim_int = mem_dout;
            frame_idx_preset = 1'b1;
            mem_re = 1'b1;
//rdata_diff = rdata_head - mem_dout;
            next_state = STATE_WRITE_DATA;
        end

        STATE_WRITE_DATA:
        begin
            frame_ptr = pre_stim_frame_ptr + frame_idx;
            mem_wr_data = rdata_pre_stim + ((rdata_head - rdata_pre_stim) / (stim_count + 1)*frame_idx);
            mem_we = 1'b1;
            frame_idx_inc = 1'b1;
            if (frame_idx == stim_count)
                next_state = STATE_NEXT_CHAN_INC;
        end

        STATE_NEXT_CHAN_INC:
        begin
            chan_idx_inc = 1'b1;
            next_state = STATE_NEXT_CHAN;
        end

        STATE_NEXT_CHAN:
        begin
            if (chan_idx < active_chans)
                next_state = STATE_READ_HEAD;
            else
                next_state = STATE_IDLE;
        end

        default:
            next_state = STATE_INIT;
    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    current_state       // 4
};

endmodule

