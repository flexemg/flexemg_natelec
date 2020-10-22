//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Mon Mar 18 19:30:35 2019
// Version: v11.8 SP3 11.8.3.6
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// adc_datapath
module adc_datapath(
    // Inputs
    HDC_Clk,
    LabelIn_DI,
    ModeIn_SI,
    adc_done,
    artifact_en,
    clk,
    crc_ok,
    fft_channel,
    fft_en,
    fft_rd_strobe,
    fifo_pop,
    pkt_done,
    rstb,
    rx_bit,
    rx_bit_valid,
    start,
    vector_bits,
    // Outputs
    HDC_ClkEn,
    adc_art_debug,
    adc_dp_debug,
    adc_vec_debuf,
    distance_out,
    fifo_dout,
    fifo_empty,
    fifo_overflow,
    fifo_underflow,
    frame_rdy,
    label_out,
    valid_out
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         HDC_Clk;
input  [4:0]  LabelIn_DI;
input  [1:0]  ModeIn_SI;
input         adc_done;
input         artifact_en;
input         clk;
input         crc_ok;
input  [5:0]  fft_channel;
input         fft_en;
input         fft_rd_strobe;
input         fifo_pop;
input         pkt_done;
input         rstb;
input         rx_bit;
input         rx_bit_valid;
input         start;
input  [63:0] vector_bits;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        HDC_ClkEn;
output [3:0]  adc_art_debug;
output [3:0]  adc_dp_debug;
output [3:0]  adc_vec_debuf;
output [9:0]  distance_out;
output [15:0] fifo_dout;
output        fifo_empty;
output        fifo_overflow;
output        fifo_underflow;
output        frame_rdy;
output [4:0]  label_out;
output        valid_out;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire            adc_done;
wire            adc_dp_debug_1;
wire            adc_dp_debug_2;
wire   [1023:0] adc_frame_buffer_0_dout;
wire   [3:0]    adc_vec_debuf_net_0;
wire   [8:0]    adc_vector_compressor_0_mem_addr;
wire            adc_vector_compressor_0_mem_re;
wire            adc_vector_compressor_0_mem_we;
wire   [15:0]   adc_vector_compressor_0_mem_wr_data;
wire   [15:0]   ADCMEM_SP_0_dout;
wire            artifact_en;
wire            clk;
wire            crc_ok;
wire   [9:0]    distance_out_net_0;
wire   [5:0]    fft_channel;
wire            fft_en;
wire            fft_rd_strobe;
wire   [15:0]   fifo_dout_net_0;
wire            fifo_empty_net_0;
wire            fifo_overflow_net_0;
wire            fifo_pop;
wire            fifo_underflow_net_0;
wire            frame_rdy_net_0;
wire            HDC_Clk;
wire            HDC_ClkEn_net_0;
wire   [1023:0] hdc_top_0_Gest_Raw_Out;
wire   [4:0]    label_out_net_0;
wire   [4:0]    LabelIn_DI;
wire   [1:0]    ModeIn_SI;
wire            rstb;
wire            rx_bit;
wire            rx_bit_valid;
wire            start;
wire            valid_out_net_0;
wire   [63:0]   vector_bits;
wire            fifo_empty_net_1;
wire            frame_rdy_net_1;
wire            fifo_underflow_net_1;
wire            fifo_overflow_net_1;
wire            valid_out_net_1;
wire            HDC_ClkEn_net_1;
wire   [15:0]   fifo_dout_net_1;
wire   [3:0]    adc_vec_debuf_net_1;
wire   [0:0]    fifo_pop_net_0;
wire   [1:1]    fifo_empty_net_2;
wire   [2:2]    adc_dp_debug_2_net_0;
wire   [3:3]    adc_dp_debug_1_net_0;
wire   [4:0]    label_out_net_1;
wire   [9:0]    distance_out_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   [3:0]    adc_art_debug_const_net_0;
wire            GND_net;
wire   [8:0]    addr_1_const_net_0;
wire   [15:0]   din_1_const_net_0;
wire            VCC_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign adc_art_debug_const_net_0 = 4'h0;
assign GND_net                   = 1'b0;
assign addr_1_const_net_0        = 9'h000;
assign din_1_const_net_0         = 16'h0000;
assign VCC_net                   = 1'b1;
//--------------------------------------------------------------------
// TieOff assignments
//--------------------------------------------------------------------
assign adc_art_debug[3:0]      = 4'h0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign fifo_empty_net_1        = fifo_empty_net_0;
assign fifo_empty              = fifo_empty_net_1;
assign frame_rdy_net_1         = frame_rdy_net_0;
assign frame_rdy               = frame_rdy_net_1;
assign fifo_underflow_net_1    = fifo_underflow_net_0;
assign fifo_underflow          = fifo_underflow_net_1;
assign fifo_overflow_net_1     = fifo_overflow_net_0;
assign fifo_overflow           = fifo_overflow_net_1;
assign valid_out_net_1         = valid_out_net_0;
assign valid_out               = valid_out_net_1;
assign HDC_ClkEn_net_1         = HDC_ClkEn_net_0;
assign HDC_ClkEn               = HDC_ClkEn_net_1;
assign fifo_dout_net_1         = fifo_dout_net_0;
assign fifo_dout[15:0]         = fifo_dout_net_1;
assign adc_vec_debuf_net_1     = adc_vec_debuf_net_0;
assign adc_vec_debuf[3:0]      = adc_vec_debuf_net_1;
assign fifo_pop_net_0[0]       = fifo_pop;
assign adc_dp_debug[0:0]       = fifo_pop_net_0[0];
assign fifo_empty_net_2[1]     = fifo_empty_net_0;
assign adc_dp_debug[1:1]       = fifo_empty_net_2[1];
assign adc_dp_debug_2_net_0[2] = adc_dp_debug_2;
assign adc_dp_debug[2:2]       = adc_dp_debug_2_net_0[2];
assign adc_dp_debug_1_net_0[3] = adc_dp_debug_1;
assign adc_dp_debug[3:3]       = adc_dp_debug_1_net_0[3];
assign label_out_net_1         = label_out_net_0;
assign label_out[4:0]          = label_out_net_1;
assign distance_out_net_1      = distance_out_net_0;
assign distance_out[9:0]       = distance_out_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------adc_frame_buffer
adc_frame_buffer adc_frame_buffer_0(
        // Inputs
        .clk          ( clk ),
        .rstb         ( rstb ),
        .start        ( start ),
        .rx_bit_valid ( rx_bit_valid ),
        .rx_bit       ( rx_bit ),
        .pkt_done     ( adc_done ),
        // Outputs
        .dout         ( adc_frame_buffer_0_dout ) 
        );

//--------adc_vector_compressor
adc_vector_compressor adc_vector_compressor_0(
        // Inputs
        .clk              ( clk ),
        .rstb             ( rstb ),
        .fifo_full        ( adc_dp_debug_1 ),
        .start            ( start ),
        .pkt_done         ( adc_done ),
        .crc_ok           ( crc_ok ),
        .frame            ( hdc_top_0_Gest_Raw_Out ),
        .vector_bits      ( vector_bits ),
        // Outputs
        .fifo_push        ( adc_dp_debug_2 ),
        .mem_we           ( adc_vector_compressor_0_mem_we ),
        .mem_re           ( adc_vector_compressor_0_mem_re ),
        .stim_flag        (  ),
        .frame_rdy        ( frame_rdy_net_0 ),
        .mem_addr         ( adc_vector_compressor_0_mem_addr ),
        .mem_wr_data      ( adc_vector_compressor_0_mem_wr_data ),
        .num_active_chans (  ),
        .mem_head_ptr     (  ),
        .debug            ( adc_vec_debuf_net_0 ) 
        );

//--------ADCFIFO
ADCFIFO ADCFIFO_0(
        // Inputs
        .RESET     ( rstb ),
        .WE        ( adc_dp_debug_2 ),
        .RE        ( fifo_pop ),
        .CLK       ( clk ),
        .DATA      ( ADCMEM_SP_0_dout ),
        // Outputs
        .FULL      ( adc_dp_debug_1 ),
        .EMPTY     ( fifo_empty_net_0 ),
        .OVERFLOW  ( fifo_overflow_net_0 ),
        .UNDERFLOW ( fifo_underflow_net_0 ),
        .Q         ( fifo_dout_net_0 ),
        .WRCNT     (  ),
        .RDCNT     (  ) 
        );

//--------ADCMEM_DP
ADCMEM_DP ADCMEM_DP_0(
        // Inputs
        .clk    ( clk ),
        .we_0   ( adc_vector_compressor_0_mem_we ),
        .re_0   ( adc_vector_compressor_0_mem_re ),
        .we_1   ( GND_net ),
        .re_1   ( GND_net ),
        .addr_0 ( adc_vector_compressor_0_mem_addr ),
        .din_0  ( adc_vector_compressor_0_mem_wr_data ),
        .addr_1 ( addr_1_const_net_0 ),
        .din_1  ( din_1_const_net_0 ),
        // Outputs
        .dout   ( ADCMEM_SP_0_dout ) 
        );

//--------hdc_top
hdc_top hdc_top_0(
        // Inputs
        .HDC_Clk        ( HDC_Clk ),
        .Clk_CI         ( clk ),
        .Reset_RI       ( rstb ),
        .adc_done       ( adc_done ),
        .ReadyIn_SI     ( VCC_net ),
        .ModeIn_SI      ( ModeIn_SI ),
        .LabelIn_DI     ( LabelIn_DI ),
        .Raw_DI         ( adc_frame_buffer_0_dout ),
        // Outputs
        .HDC_ClkEn      ( HDC_ClkEn_net_0 ),
        .ReadyOut_SO    (  ),
        .ValidOut_SO    ( valid_out_net_0 ),
        .LabelOut_DO    ( label_out_net_0 ),
        .DistanceOut_DO ( distance_out_net_0 ),
        .Gest_Raw_Out   ( hdc_top_0_Gest_Raw_Out ) 
        );


endmodule
