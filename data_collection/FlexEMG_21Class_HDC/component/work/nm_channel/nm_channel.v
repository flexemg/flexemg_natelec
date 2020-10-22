//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue Feb 19 01:54:08 2019
// Version: v11.8 SP3 11.8.3.6
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// nm_channel
module nm_channel(
    // Inputs
    HDC_Clk,
    LabelIn_DI,
    ModeIn_SI,
    ack_read,
    adc_fifo_pop,
    adc_vec_bits,
    artifact_en,
    clk,
    fft_channel,
    fft_en,
    fft_rd_strobe,
    n2c_data,
    rst_start,
    rstb,
    tx_data,
    tx_mode,
    tx_start,
    // Outputs
    HDC_ClkEn,
    ack_dout,
    ack_dp_debug,
    ack_rdy,
    adc_art_debug,
    adc_dp_debug,
    adc_fifo_dout,
    adc_fifo_empty,
    adc_fifo_overflow,
    adc_fifo_underflow,
    adc_frame_rdy,
    adc_vec_debug,
    c2n_data,
    c2n_valid,
    distance_out,
    label_out,
    nrx_debug,
    ntx_debug,
    rst_busy,
    tx_busy,
    tx_data_rb,
    valid_out
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         HDC_Clk;
input  [4:0]  LabelIn_DI;
input  [1:0]  ModeIn_SI;
input         ack_read;
input         adc_fifo_pop;
input  [63:0] adc_vec_bits;
input         artifact_en;
input         clk;
input  [5:0]  fft_channel;
input         fft_en;
input         fft_rd_strobe;
input         n2c_data;
input         rst_start;
input         rstb;
input  [33:0] tx_data;
input         tx_mode;
input         tx_start;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        HDC_ClkEn;
output [31:0] ack_dout;
output [3:0]  ack_dp_debug;
output        ack_rdy;
output [3:0]  adc_art_debug;
output [3:0]  adc_dp_debug;
output [15:0] adc_fifo_dout;
output        adc_fifo_empty;
output        adc_fifo_overflow;
output        adc_fifo_underflow;
output        adc_frame_rdy;
output [3:0]  adc_vec_debug;
output        c2n_data;
output        c2n_valid;
output [9:0]  distance_out;
output [4:0]  label_out;
output [3:0]  nrx_debug;
output [3:0]  ntx_debug;
output        rst_busy;
output        tx_busy;
output [33:0] tx_data_rb;
output        valid_out;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] ack_dout_net_0;
wire   [3:0]  ack_dp_debug_1;
wire          ack_rdy_net_0;
wire          ack_read;
wire   [3:0]  adc_art_debug_0;
wire   [3:0]  adc_dp_debug_0;
wire   [15:0] adc_fifo_dout_1;
wire          adc_fifo_empty_net_0;
wire          adc_fifo_overflow_net_0;
wire          adc_fifo_pop;
wire          adc_fifo_underflow_net_0;
wire          adc_frame_rdy_net_0;
wire   [63:0] adc_vec_bits;
wire   [3:0]  adc_vec_debug_0;
wire          artifact_en;
wire          c2n_data_net_0;
wire          c2n_valid_net_0;
wire          clk;
wire   [9:0]  distance_out_net_0;
wire   [5:0]  fft_channel;
wire          fft_en;
wire          fft_rd_strobe;
wire          HDC_Clk;
wire          HDC_ClkEn_net_0;
wire   [4:0]  label_out_net_0;
wire   [4:0]  LabelIn_DI;
wire   [1:0]  ModeIn_SI;
wire          n2c_data;
wire          nmic_rx_0_ack_rx_start;
wire          nmic_rx_0_adc_done;
wire          nmic_rx_0_adc_rx_start;
wire          nmic_rx_0_bit_valid;
wire          nmic_rx_0_crc_ok;
wire          nmic_rx_0_pkt_done;
wire          nmic_rx_0_rx_bit_sampled;
wire   [3:0]  nrx_debug_0;
wire   [3:0]  ntx_debug_0;
wire          rst_busy_net_0;
wire          rst_start;
wire          rstb;
wire          twoMHz_strobe_0_twoMHz_stb;
wire          tx_busy_net_0;
wire   [33:0] tx_data;
wire   [33:0] tx_data_rb_net_0;
wire          tx_mode;
wire          tx_start;
wire          valid_out_net_0;
wire          ack_rdy_net_1;
wire          adc_fifo_empty_net_1;
wire          adc_frame_rdy_net_1;
wire          tx_busy_net_1;
wire          c2n_data_net_1;
wire          c2n_valid_net_1;
wire          rst_busy_net_1;
wire          adc_fifo_overflow_net_1;
wire          adc_fifo_underflow_net_1;
wire          valid_out_net_1;
wire   [33:0] tx_data_rb_net_1;
wire   [15:0] adc_fifo_dout_1_net_0;
wire   [31:0] ack_dout_net_1;
wire   [3:0]  adc_dp_debug_0_net_0;
wire   [3:0]  adc_art_debug_0_net_0;
wire   [3:0]  adc_vec_debug_0_net_0;
wire   [3:0]  nrx_debug_0_net_0;
wire   [3:0]  ntx_debug_0_net_0;
wire   [3:0]  ack_dp_debug_1_net_0;
wire   [4:0]  label_out_net_1;
wire   [9:0]  distance_out_net_1;
wire          HDC_ClkEn_net_1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign ack_rdy_net_1            = ack_rdy_net_0;
assign ack_rdy                  = ack_rdy_net_1;
assign adc_fifo_empty_net_1     = adc_fifo_empty_net_0;
assign adc_fifo_empty           = adc_fifo_empty_net_1;
assign adc_frame_rdy_net_1      = adc_frame_rdy_net_0;
assign adc_frame_rdy            = adc_frame_rdy_net_1;
assign tx_busy_net_1            = tx_busy_net_0;
assign tx_busy                  = tx_busy_net_1;
assign c2n_data_net_1           = c2n_data_net_0;
assign c2n_data                 = c2n_data_net_1;
assign c2n_valid_net_1          = c2n_valid_net_0;
assign c2n_valid                = c2n_valid_net_1;
assign rst_busy_net_1           = rst_busy_net_0;
assign rst_busy                 = rst_busy_net_1;
assign adc_fifo_overflow_net_1  = adc_fifo_overflow_net_0;
assign adc_fifo_overflow        = adc_fifo_overflow_net_1;
assign adc_fifo_underflow_net_1 = adc_fifo_underflow_net_0;
assign adc_fifo_underflow       = adc_fifo_underflow_net_1;
assign valid_out_net_1          = valid_out_net_0;
assign valid_out                = valid_out_net_1;
assign tx_data_rb_net_1         = tx_data_rb_net_0;
assign tx_data_rb[33:0]         = tx_data_rb_net_1;
assign adc_fifo_dout_1_net_0    = adc_fifo_dout_1;
assign adc_fifo_dout[15:0]      = adc_fifo_dout_1_net_0;
assign ack_dout_net_1           = ack_dout_net_0;
assign ack_dout[31:0]           = ack_dout_net_1;
assign adc_dp_debug_0_net_0     = adc_dp_debug_0;
assign adc_dp_debug[3:0]        = adc_dp_debug_0_net_0;
assign adc_art_debug_0_net_0    = adc_art_debug_0;
assign adc_art_debug[3:0]       = adc_art_debug_0_net_0;
assign adc_vec_debug_0_net_0    = adc_vec_debug_0;
assign adc_vec_debug[3:0]       = adc_vec_debug_0_net_0;
assign nrx_debug_0_net_0        = nrx_debug_0;
assign nrx_debug[3:0]           = nrx_debug_0_net_0;
assign ntx_debug_0_net_0        = ntx_debug_0;
assign ntx_debug[3:0]           = ntx_debug_0_net_0;
assign ack_dp_debug_1_net_0     = ack_dp_debug_1;
assign ack_dp_debug[3:0]        = ack_dp_debug_1_net_0;
assign label_out_net_1          = label_out_net_0;
assign label_out[4:0]           = label_out_net_1;
assign distance_out_net_1       = distance_out_net_0;
assign distance_out[9:0]        = distance_out_net_1;
assign HDC_ClkEn_net_1          = HDC_ClkEn_net_0;
assign HDC_ClkEn                = HDC_ClkEn_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------ack_datapath
ack_datapath #( 
        .DEBUG_BUS_SIZE ( 4 ) )
ack_datapath_0(
        // Inputs
        .clk          ( clk ),
        .rstb         ( rstb ),
        .start        ( nmic_rx_0_ack_rx_start ),
        .rx_bit       ( nmic_rx_0_rx_bit_sampled ),
        .rx_bit_valid ( nmic_rx_0_bit_valid ),
        .crc_ok       ( nmic_rx_0_crc_ok ),
        .pkt_done     ( nmic_rx_0_pkt_done ),
        .ack_read     ( ack_read ),
        // Outputs
        .ack_rdy      ( ack_rdy_net_0 ),
        .ack_dout     ( ack_dout_net_0 ),
        .debug        ( ack_dp_debug_1 ) 
        );

//--------adc_datapath
adc_datapath adc_datapath_0(
        // Inputs
        .start          ( nmic_rx_0_adc_rx_start ),
        .pkt_done       ( nmic_rx_0_pkt_done ),
        .rx_bit         ( nmic_rx_0_rx_bit_sampled ),
        .rx_bit_valid   ( nmic_rx_0_bit_valid ),
        .fifo_pop       ( adc_fifo_pop ),
        .crc_ok         ( nmic_rx_0_crc_ok ),
        .artifact_en    ( artifact_en ),
        .fft_rd_strobe  ( fft_rd_strobe ),
        .clk            ( clk ),
        .rstb           ( rstb ),
        .fft_en         ( fft_en ),
        .adc_done       ( nmic_rx_0_adc_done ),
        .vector_bits    ( adc_vec_bits ),
        .fft_channel    ( fft_channel ),
        .ModeIn_SI      ( ModeIn_SI ),
        .LabelIn_DI     ( LabelIn_DI ),
        .HDC_Clk        ( HDC_Clk ),
        // Outputs
        .fifo_empty     ( adc_fifo_empty_net_0 ),
        .frame_rdy      ( adc_frame_rdy_net_0 ),
        .fifo_underflow ( adc_fifo_underflow_net_0 ),
        .fifo_overflow  ( adc_fifo_overflow_net_0 ),
        .valid_out      ( valid_out_net_0 ),
        .fifo_dout      ( adc_fifo_dout_1 ),
        .adc_vec_debuf  ( adc_vec_debug_0 ),
        .adc_art_debug  ( adc_art_debug_0 ),
        .adc_dp_debug   ( adc_dp_debug_0 ),
        .label_out      ( label_out_net_0 ),
        .distance_out   ( distance_out_net_0 ),
        .HDC_ClkEn      ( HDC_ClkEn_net_0 ) 
        );

//--------nmic_rx
nmic_rx #( 
        .DEBUG_BUS_SIZE ( 4 ) )
nmic_rx_0(
        // Inputs
        .clk            ( clk ),
        .rstb           ( rstb ),
        .twoMHz_stb     ( twoMHz_strobe_0_twoMHz_stb ),
        .rx_bit         ( n2c_data ),
        // Outputs
        .adc_done       ( nmic_rx_0_adc_done ),
        .pkt_done       ( nmic_rx_0_pkt_done ),
        .rx_bit_sampled ( nmic_rx_0_rx_bit_sampled ),
        .bit_valid      ( nmic_rx_0_bit_valid ),
        .adc_rx_start   ( nmic_rx_0_adc_rx_start ),
        .ack_rx_start   ( nmic_rx_0_ack_rx_start ),
        .crc_ok         ( nmic_rx_0_crc_ok ),
        .debug          ( nrx_debug_0 ) 
        );

//--------nmic_tx
nmic_tx #( 
        .DEBUG_BUS_SIZE ( 4 ) )
nmic_tx_0(
        // Inputs
        .clk           ( clk ),
        .rstb          ( rstb ),
        .twoMHz_stb    ( twoMHz_strobe_0_twoMHz_stb ),
        .tx_mode       ( tx_mode ),
        .tx_start      ( tx_start ),
        .rst_start     ( rst_start ),
        .tx_data_in    ( tx_data ),
        // Outputs
        .tx_busy       ( tx_busy_net_0 ),
        .rst_busy      ( rst_busy_net_0 ),
        .c2n_valid     ( c2n_valid_net_0 ),
        .c2n_data      ( c2n_data_net_0 ),
        .tx_data_in_rb ( tx_data_rb_net_0 ),
        .debug         ( ntx_debug_0 ) 
        );

//--------twoMHz_strobe
twoMHz_strobe twoMHz_strobe_0(
        // Inputs
        .clk        ( clk ),
        .rstb       ( rstb ),
        // Outputs
        .twoMHz_stb ( twoMHz_strobe_0_twoMHz_stb ) 
        );


endmodule
