///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: adc_fft_cntl.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S050> <Package::484 FBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>

module adc_fft_cntl #(
    parameter DEBUG_BUS_SIZE = 4,
    parameter POINTS = 256
  )
  (
    input wire clk,
    input wire rstb,

    input enable,

    // From ADC datapath
    input wire frame_rdy,
    input wire chan_cnt_inc,

    // From cm_if_apb
    input wire [5:0] chan,

    // From FFT core
    input wire fft_buf_rdy,
    input wire fft_outp_rdy,
    input wire fft_datao_valid,

    // To FFT core
    output reg fft_datai_valid,
    output reg fft_read_outp,

    // To M3
    output reg irq,

    // Debug
    output wire [DEBUG_BUS_SIZE-1:0] debug
    
);

// chan counter
reg chan_cnt_rst;
reg [5:0] chan_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || frame_rdy || chan_cnt_rst) 
        chan_cnt <= 0;
    else if (chan_cnt_inc)
        chan_cnt <= chan_cnt + 1;
    else
        chan_cnt <= chan_cnt;
end

// chan ready indicator
wire chan_rdy;
assign chan_rdy = (chan_cnt == chan);

//// 
//// FSM
////

// state encoding
localparam [2:0] // synopsys enum
    STATE_IDLE         = 3'b000, // 0
    STATE_CHAN_WAIT    = 3'b001, // 1
    STATE_CHAN_RDY     = 3'b011, // 3
    STATE_FFT_DONE     = 3'b010, // 2
    STATE_FIFO_WR_WAIT = 3'b110, // 6
    STATE_FIFO_WR      = 3'b100; // 4

// state variables
reg [2:0] current_state, next_state;
always @(posedge clk or negedge rstb) begin
    if (!rstb)
        current_state = STATE_IDLE;
    else
        current_state = next_state;
end

always @(*) begin
    chan_cnt_rst = 1'b0;
    fft_datai_valid = 1'b0;
    fft_read_outp = 1'b0;
    irq = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
        begin
            chan_cnt_rst = 1'b1;
            if (frame_rdy && enable)
                next_state = STATE_CHAN_WAIT;
            else if (fft_outp_rdy)
                next_state = STATE_FFT_DONE;
        end

        STATE_CHAN_WAIT:
            if (chan_rdy)
                if (fft_buf_rdy)
                    next_state = STATE_CHAN_RDY;
                else
                    next_state = STATE_IDLE;

        STATE_CHAN_RDY:
        begin
            fft_datai_valid = 1'b1;
            next_state = STATE_IDLE;
        end

        STATE_FFT_DONE:
        begin
            fft_read_outp = 1'b1;
            next_state = STATE_FIFO_WR_WAIT;
        end

        STATE_FIFO_WR_WAIT:
            if (fft_datao_valid)
                next_state = STATE_FIFO_WR;

        STATE_FIFO_WR:
        begin
            fft_read_outp = 1'b1;
            if (fft_outp_rdy) 
                next_state = STATE_FIFO_WR_WAIT;
            else begin
                irq = 1'b1;
                next_state = STATE_IDLE;
            end
        end

        default:
            next_state = STATE_IDLE;
    endcase
end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    frame_rdy,          // 1
    current_state       // 3
};

endmodule

