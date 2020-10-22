///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: pdma_if.v
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

module pdma_if #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire clk,
    input wire rstb,

    // PDMA interface
    input wire pdma_en,
    input wire pdma_fifo_pop,
    output reg [7:0] pdma_data,
    output reg pdma_done_irq_req,
    output wire pdma_data_rdy,

    // NM1 signals
    input wire [15:0] adc_fifo_dout_n1,
    input wire adc_frame_rdy_n1,
    input wire adc_fifo_empty_n1,
    output reg adc_fifo_pop_n1,

    // NM0 signals
    input wire [15:0] adc_fifo_dout_n0,
    input wire adc_frame_rdy_n0,
    input wire adc_fifo_empty_n0,
    output reg adc_fifo_pop_n0,

    // Accelerometer data
    input wire [47:0] acc_data,

    // debugging
    output wire pdma_fifo_overflow,
    output wire pdma_fifo_underflow,
    output wire [DEBUG_BUS_SIZE-1:0] debug
);

localparam HEADER_CONST = 16'haa00;

reg pdma_fifo_push;
wire pdma_fifo_full;
wire pdma_fifo_empty;
reg pdma_fifo_clr;

assign pdma_data_rdy = ~pdma_fifo_empty;

// data ready latch
reg data_rdy_n0;
reg data_rdy_n1;
reg latch_clr;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || latch_clr) begin
        data_rdy_n0 <= 1'b0;
        data_rdy_n1 <= 1'b0;
    end else begin
        if (adc_frame_rdy_n0)
            data_rdy_n0 <= 1'b1;
        if (adc_frame_rdy_n1)
            data_rdy_n1 <= 1'b1;
    end
end

// 6:1 mux
reg [2:0] mux_sel;
reg [15:0] pdma_fifo_din;
always @ (*) begin
    if (mux_sel == 3'd0)
        pdma_fifo_din <= HEADER_CONST;
    else if (mux_sel == 3'd1)
        pdma_fifo_din <= adc_fifo_dout_n0;
    else if (mux_sel == 3'd2)
        pdma_fifo_din <= adc_fifo_dout_n1;
    else if (mux_sel == 3'd3)
        pdma_fifo_din <= acc_data[47:32];
    else if (mux_sel == 3'd4)
        pdma_fifo_din <= acc_data[31:16];
    else if (mux_sel == 3'd5)
        pdma_fifo_din <= acc_data[15:0];
end

// output zero mux
wire [7:0] pdma_fifo_dout;
always @(*) begin
    if (pdma_fifo_empty == 1'b1)
        pdma_data <= 8'd0;
    else
        pdma_data <= pdma_fifo_dout;
end

wire pdma_fifo_dvld;
wire [8:0] pdma_fifo_rdcnt;
wire pdma_fifo_wack;
wire [7:0] pdma_fifo_wrcnt;

// pdma_done_irq_req asserted causes the pad byte to be dropped.
// The pad byte is the 1st 8 bits in the header short int
// which is the first value pushed into the PDMA FIFO.
// FIFO write side is 16 and the read side is 8 so we can do this.
wire fifo_pop_int;
assign fifo_pop_int = (pdma_done_irq_req) ? 1'b1 : pdma_fifo_pop;

// FIFO, 16x135 bit push, 8x270 bit pop
PDMAFIFO pdma_fifo (
    // Inputs
    .CLK(clk),
    .RESET(rstb && !pdma_fifo_clr),

    .DATA(pdma_fifo_din),
    .RE(fifo_pop_int),
    .WE(pdma_fifo_push),

    // Outputs
    .EMPTY(pdma_fifo_empty),
    .FULL(pdma_fifo_full),
    .Q(pdma_fifo_dout),
    .OVERFLOW(pdma_fifo_overflow),

    // debug
    .DVLD(pdma_fifo_dvld),
    .RDCNT(pdma_fifo_rdcnt),
    .UNDERFLOW(pdma_fifo_underflow),
    .WACK(pdma_fifo_wack),
    .WRCNT(pdma_fifo_wrcnt)
);

////
//// FSM
////

localparam [3:0] // synopsys enum
    STATE_IDLE       = 4'b0000, // 0
    STATE_HEADER     = 4'b0001, // 1
    STATE_NM0        = 4'b0011, // 3
    STATE_NM1        = 4'b0111, // 7
    STATE_ACC_X      = 4'b1111, // 15
    STATE_ACC_Y      = 4'b1110, // 14
    STATE_ACC_Z      = 4'b1100, // 12
    STATE_TOSS_PAD   = 4'b1000, // 8
    STATE_OVERFLOW   = 4'b0010; // 2

// FSM state variables
reg [3:0] current_state, next_state;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        current_state <= STATE_IDLE;
    else if (pdma_fifo_overflow)
        current_state <= STATE_OVERFLOW;
    else
        current_state <= next_state;
end

//FSM state logic
always @ (*) begin
    latch_clr = 1'b0;
    mux_sel = 3'd0;
    adc_fifo_pop_n0 = 1'b0;
    adc_fifo_pop_n1 = 1'b0;
    pdma_fifo_push = 1'b0;
    pdma_fifo_clr = 1'b0;
    pdma_done_irq_req = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
            if (pdma_en && data_rdy_n0 && data_rdy_n1) begin
                pdma_fifo_clr = 1'b1;
                next_state = STATE_HEADER;
            end

        STATE_HEADER:
        begin
            mux_sel = 3'd0;
            latch_clr = 1'b1;
            adc_fifo_pop_n0 = 1'b1;     // prefetch
            pdma_fifo_push = 1'b1;
            next_state = STATE_NM0;
        end

        STATE_NM0:
        begin
            mux_sel = 3'd1;
            pdma_fifo_push = 1'b1;
            adc_fifo_pop_n0 = 1'b1;
            if (adc_fifo_empty_n0) begin
                adc_fifo_pop_n1 = 1'b1; // prefetch
                next_state = STATE_NM1;
            end
        end

        STATE_NM1:
        begin
            mux_sel = 3'd2;
            pdma_fifo_push = 1'b1;
            adc_fifo_pop_n1 = 1'b1;
            if (adc_fifo_empty_n1)
                next_state = STATE_ACC_X;
        end

        STATE_ACC_X:
        begin
            mux_sel = 3'd3;
            pdma_fifo_push = 1'b1;
            next_state = STATE_ACC_Y;
        end

        STATE_ACC_Y:
        begin
            mux_sel = 3'd4;
            pdma_fifo_push = 1'b1;
            next_state = STATE_ACC_Z;
        end

        STATE_ACC_Z:
        begin
            mux_sel = 3'd5;
            pdma_fifo_push = 1'b1;
            next_state = STATE_TOSS_PAD;
        end

        STATE_TOSS_PAD:
        begin
            pdma_done_irq_req = 1'b1;
            next_state = STATE_IDLE;
        end

        STATE_OVERFLOW:
        begin
            pdma_fifo_clr = 1'b1;
            latch_clr = 1'b1;
            next_state = STATE_IDLE;
        end

        default:
            next_state = STATE_IDLE;
    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    current_state           // 4
};

endmodule






