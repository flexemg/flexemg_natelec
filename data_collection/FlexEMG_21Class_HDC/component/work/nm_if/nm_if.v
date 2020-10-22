//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue Feb 19 01:54:36 2019
// Version: v11.8 SP3 11.8.3.6
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// nm_if
module nm_if(
    // Inputs
    HDC_Clk,
    acc_data,
    addr,
    artifact_en,
    clk,
    clk_1ms,
    data_wr,
    fft_channel,
    fft_en,
    n2c_data,
    pdma_emulate,
    pdma_en,
    pdma_fifo_pop_emu,
    rden,
    rstb,
    wren,
    // Outputs
    HDC_ClkEn,
    ack_dp_debug,
    ack_rdy_irq_req,
    adc_art_debug,
    adc_dp_debug,
    adc_vec_debug,
    c2n_data,
    c2n_valid_0,
    data_rd,
    led,
    nm_apb_debug,
    nrx_debug,
    ntx_debug,
    pdma_data_rdy,
    pdma_debug,
    pdma_done_irq_req
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         HDC_Clk;
input  [47:0] acc_data;
input  [15:0] addr;
input         artifact_en;
input         clk;
input         clk_1ms;
input  [31:0] data_wr;
input  [11:0] fft_channel;
input         fft_en;
input         n2c_data;
input         pdma_emulate;
input         pdma_en;
input         pdma_fifo_pop_emu;
input         rden;
input         rstb;
input         wren;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        HDC_ClkEn;
output [3:0]  ack_dp_debug;
output        ack_rdy_irq_req;
output [3:0]  adc_art_debug;
output [3:0]  adc_dp_debug;
output [3:0]  adc_vec_debug;
output        c2n_data;
output        c2n_valid_0;
output [31:0] data_rd;
output [1:0]  led;
output [3:0]  nm_apb_debug;
output [3:0]  nrx_debug;
output [3:0]  ntx_debug;
output        pdma_data_rdy;
output [3:0]  pdma_debug;
output        pdma_done_irq_req;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [47:0] acc_data;
wire   [3:0]  ack_dp_debug_0;
wire          ack_rdy_irq_req_net_0;
wire   [3:0]  adc_art_debug_net_0;
wire   [3:0]  adc_dp_debug_0;
wire   [3:0]  adc_vec_debug_0;
wire   [15:0] addr;
wire          artifact_en;
wire          c2n_data_net_0;
wire          c2n_valid_0_net_0;
wire          clk;
wire          clk_1ms;
wire   [0:0]  cm_if_apb_0_ack_read0to0;
wire   [63:0] cm_if_apb_0_adc_vec_n0;
wire   [0:0]  cm_if_apb_0_fft_rd_strobe0to0;
wire   [0:0]  cm_if_apb_0_m3_adc_fifo_pop0to0;
wire          cm_if_apb_0_pdma_fifo_pop;
wire   [0:0]  cm_if_apb_0_rst_start0to0;
wire   [33:0] cm_if_apb_0_tx_data_n0;
wire   [0:0]  cm_if_apb_0_tx_mode0to0;
wire   [0:0]  cm_if_apb_0_tx_start0to0;
wire   [31:0] data_rd_net_0;
wire   [31:0] data_wr;
wire   [5:0]  fft_channel_slice_0;
wire   [11:6] fft_channel_slice_1;
wire          fft_en;
wire          HDC_Clk;
wire          HDC_ClkEn_net_0;
wire   [1:0]  led_net_0;
wire          MX2_1_Y;
wire          MX2_2_Y;
wire          n2c_data;
wire   [3:0]  nm_apb_debug_net_0;
wire   [31:0] nm_channel_0_ack_dout;
wire          nm_channel_0_ack_rdy;
wire   [15:0] nm_channel_0_adc_fifo_dout_0;
wire          nm_channel_0_adc_fifo_empty;
wire          nm_channel_0_adc_fifo_overflow;
wire          nm_channel_0_adc_fifo_underflow;
wire          nm_channel_0_adc_frame_rdy;
wire   [9:0]  nm_channel_0_distance_out;
wire   [4:0]  nm_channel_0_label_out;
wire          nm_channel_0_rst_busy;
wire          nm_channel_0_tx_busy;
wire   [33:0] nm_channel_0_tx_data_rb;
wire   [4:0]  nm_if_apb_0_label_in;
wire   [1:0]  nm_if_apb_0_mode_in;
wire   [3:0]  nrx_debug_0;
wire   [3:0]  ntx_debug_0;
wire   [7:0]  pdma_data;
wire          pdma_data_rdy_net_0;
wire   [3:0]  pdma_debug_0;
wire          pdma_done_irq_req_net_0;
wire          pdma_emulate;
wire          pdma_en;
wire          pdma_fifo_pop_emu;
wire          pdma_if_0_adc_fifo_pop_n0;
wire          pdma_if_0_pdma_fifo_overflow;
wire          pdma_if_0_pdma_fifo_underflow;
wire          rden;
wire          rstb;
wire          wren;
wire          ack_rdy_irq_req_net_1;
wire          pdma_data_rdy_net_1;
wire          pdma_done_irq_req_net_1;
wire          c2n_data_net_1;
wire          c2n_valid_0_net_1;
wire   [31:0] data_rd_net_1;
wire   [3:0]  adc_dp_debug_0_net_0;
wire   [3:0]  adc_vec_debug_0_net_0;
wire   [3:0]  adc_art_debug_net_1;
wire   [3:0]  pdma_debug_0_net_0;
wire   [3:0]  ntx_debug_0_net_0;
wire   [3:0]  nrx_debug_0_net_0;
wire   [3:0]  ack_dp_debug_0_net_0;
wire   [3:0]  nm_apb_debug_net_1;
wire   [1:0]  led_net_1;
wire          HDC_ClkEn_net_1;
wire   [1:1]  rst_start_slice_0;
wire   [1:1]  ack_read_slice_0;
wire   [1:1]  m3_adc_fifo_pop_slice_0;
wire   [1:1]  tx_start_slice_0;
wire   [1:1]  tx_mode_slice_0;
wire   [1:1]  fft_rd_strobe_slice_0;
wire   [11:0] fft_channel;
wire   [1:0]  rst_busy_net_0;
wire   [1:0]  adc_frame_rdy_net_0;
wire   [1:0]  adc_fifo_empty_net_0;
wire   [1:0]  ack_rdy_net_0;
wire   [1:0]  tx_busy_net_0;
wire   [1:0]  rst_start_net_0;
wire   [1:0]  ack_read_net_0;
wire   [1:0]  m3_adc_fifo_pop_net_0;
wire   [1:0]  tx_start_net_0;
wire   [1:0]  tx_mode_net_0;
wire   [1:0]  fft_rd_strobe_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
wire   [33:0] tx_data_rb_n1_const_net_0;
wire   [1:0]  fft_rdy_const_net_0;
wire   [31:0] adc_fft_dout_n1_const_net_0;
wire   [31:0] adc_fft_dout_n0_const_net_0;
wire   [31:0] ack_dout_n1_const_net_0;
wire          VCC_net;
wire   [15:0] adc_fifo_dout_n1_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net                      = 1'b0;
assign tx_data_rb_n1_const_net_0    = 34'h000000000;
assign fft_rdy_const_net_0          = 2'h0;
assign adc_fft_dout_n1_const_net_0  = 32'h00000000;
assign adc_fft_dout_n0_const_net_0  = 32'h00000000;
assign ack_dout_n1_const_net_0      = 32'h00000000;
assign VCC_net                      = 1'b1;
assign adc_fifo_dout_n1_const_net_0 = 16'h0000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign ack_rdy_irq_req_net_1   = ack_rdy_irq_req_net_0;
assign ack_rdy_irq_req         = ack_rdy_irq_req_net_1;
assign pdma_data_rdy_net_1     = pdma_data_rdy_net_0;
assign pdma_data_rdy           = pdma_data_rdy_net_1;
assign pdma_done_irq_req_net_1 = pdma_done_irq_req_net_0;
assign pdma_done_irq_req       = pdma_done_irq_req_net_1;
assign c2n_data_net_1          = c2n_data_net_0;
assign c2n_data                = c2n_data_net_1;
assign c2n_valid_0_net_1       = c2n_valid_0_net_0;
assign c2n_valid_0             = c2n_valid_0_net_1;
assign data_rd_net_1           = data_rd_net_0;
assign data_rd[31:0]           = data_rd_net_1;
assign adc_dp_debug_0_net_0    = adc_dp_debug_0;
assign adc_dp_debug[3:0]       = adc_dp_debug_0_net_0;
assign adc_vec_debug_0_net_0   = adc_vec_debug_0;
assign adc_vec_debug[3:0]      = adc_vec_debug_0_net_0;
assign adc_art_debug_net_1     = adc_art_debug_net_0;
assign adc_art_debug[3:0]      = adc_art_debug_net_1;
assign pdma_debug_0_net_0      = pdma_debug_0;
assign pdma_debug[3:0]         = pdma_debug_0_net_0;
assign ntx_debug_0_net_0       = ntx_debug_0;
assign ntx_debug[3:0]          = ntx_debug_0_net_0;
assign nrx_debug_0_net_0       = nrx_debug_0;
assign nrx_debug[3:0]          = nrx_debug_0_net_0;
assign ack_dp_debug_0_net_0    = ack_dp_debug_0;
assign ack_dp_debug[3:0]       = ack_dp_debug_0_net_0;
assign nm_apb_debug_net_1      = nm_apb_debug_net_0;
assign nm_apb_debug[3:0]       = nm_apb_debug_net_1;
assign led_net_1               = led_net_0;
assign led[1:0]                = led_net_1;
assign HDC_ClkEn_net_1         = HDC_ClkEn_net_0;
assign HDC_ClkEn               = HDC_ClkEn_net_1;
//--------------------------------------------------------------------
// Slices assignments
//--------------------------------------------------------------------
assign cm_if_apb_0_ack_read0to0[0]        = ack_read_net_0[0:0];
assign cm_if_apb_0_fft_rd_strobe0to0[0]   = fft_rd_strobe_net_0[0:0];
assign cm_if_apb_0_m3_adc_fifo_pop0to0[0] = m3_adc_fifo_pop_net_0[0:0];
assign cm_if_apb_0_rst_start0to0[0]       = rst_start_net_0[0:0];
assign cm_if_apb_0_tx_mode0to0[0]         = tx_mode_net_0[0:0];
assign cm_if_apb_0_tx_start0to0[0]        = tx_start_net_0[0:0];
assign fft_channel_slice_0                = fft_channel[5:0];
assign fft_channel_slice_1                = fft_channel[11:6];
assign rst_start_slice_0[1]               = rst_start_net_0[1:1];
assign ack_read_slice_0[1]                = ack_read_net_0[1:1];
assign m3_adc_fifo_pop_slice_0[1]         = m3_adc_fifo_pop_net_0[1:1];
assign tx_start_slice_0[1]                = tx_start_net_0[1:1];
assign tx_mode_slice_0[1]                 = tx_mode_net_0[1:1];
assign fft_rd_strobe_slice_0[1]           = fft_rd_strobe_net_0[1:1];
//--------------------------------------------------------------------
// Concatenation assignments
//--------------------------------------------------------------------
assign rst_busy_net_0       = { 1'b0 , nm_channel_0_rst_busy };
assign adc_frame_rdy_net_0  = { 1'b0 , nm_channel_0_adc_frame_rdy };
assign adc_fifo_empty_net_0 = { 1'b0 , nm_channel_0_adc_fifo_empty };
assign ack_rdy_net_0        = { 1'b0 , nm_channel_0_ack_rdy };
assign tx_busy_net_0        = { 1'b0 , nm_channel_0_tx_busy };
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------fifo_error_decoder
fifo_error_decoder fifo_error_decoder_0(
        // Inputs
        .clk               ( clk_1ms ),
        .rstb              ( rstb ),
        .ena               ( pdma_en ),
        .pdma_overflow     ( pdma_if_0_pdma_fifo_overflow ),
        .pdma_underflow    ( pdma_if_0_pdma_fifo_underflow ),
        .nm1_adc_overflow  ( GND_net ),
        .nm1_adc_underflow ( GND_net ),
        .nm0_adc_overflow  ( nm_channel_0_adc_fifo_overflow ),
        .nm0_adc_underflow ( nm_channel_0_adc_fifo_underflow ),
        // Outputs
        .led               ( led_net_0 ) 
        );

//--------MX2
MX2 MX2_1(
        // Inputs
        .A ( cm_if_apb_0_m3_adc_fifo_pop0to0 ),
        .B ( pdma_if_0_adc_fifo_pop_n0 ),
        .S ( pdma_en ),
        // Outputs
        .Y ( MX2_1_Y ) 
        );

//--------MX2
MX2 MX2_2(
        // Inputs
        .A ( cm_if_apb_0_pdma_fifo_pop ),
        .B ( pdma_fifo_pop_emu ),
        .S ( pdma_emulate ),
        // Outputs
        .Y ( MX2_2_Y ) 
        );

//--------nm_channel
nm_channel nm_channel_0(
        // Inputs
        .clk                ( clk ),
        .rstb               ( rstb ),
        .artifact_en        ( artifact_en ),
        .n2c_data           ( n2c_data ),
        .ack_read           ( cm_if_apb_0_ack_read0to0 ),
        .adc_fifo_pop       ( MX2_1_Y ),
        .tx_start           ( cm_if_apb_0_tx_start0to0 ),
        .tx_mode            ( cm_if_apb_0_tx_mode0to0 ),
        .fft_rd_strobe      ( cm_if_apb_0_fft_rd_strobe0to0 ),
        .fft_en             ( fft_en ),
        .rst_start          ( cm_if_apb_0_rst_start0to0 ),
        .adc_vec_bits       ( cm_if_apb_0_adc_vec_n0 ),
        .fft_channel        ( fft_channel_slice_0 ),
        .tx_data            ( cm_if_apb_0_tx_data_n0 ),
        .ModeIn_SI          ( nm_if_apb_0_mode_in ),
        .LabelIn_DI         ( nm_if_apb_0_label_in ),
        .HDC_Clk            ( HDC_Clk ),
        // Outputs
        .ack_rdy            ( nm_channel_0_ack_rdy ),
        .adc_fifo_empty     ( nm_channel_0_adc_fifo_empty ),
        .adc_frame_rdy      ( nm_channel_0_adc_frame_rdy ),
        .tx_busy            ( nm_channel_0_tx_busy ),
        .c2n_data           ( c2n_data_net_0 ),
        .c2n_valid          ( c2n_valid_0_net_0 ),
        .rst_busy           ( nm_channel_0_rst_busy ),
        .adc_fifo_overflow  ( nm_channel_0_adc_fifo_overflow ),
        .adc_fifo_underflow ( nm_channel_0_adc_fifo_underflow ),
        .valid_out          (  ),
        .tx_data_rb         ( nm_channel_0_tx_data_rb ),
        .adc_fifo_dout      ( nm_channel_0_adc_fifo_dout_0 ),
        .ack_dout           ( nm_channel_0_ack_dout ),
        .adc_dp_debug       ( adc_dp_debug_0 ),
        .adc_art_debug      ( adc_art_debug_net_0 ),
        .adc_vec_debug      ( adc_vec_debug_0 ),
        .nrx_debug          ( nrx_debug_0 ),
        .ntx_debug          ( ntx_debug_0 ),
        .ack_dp_debug       ( ack_dp_debug_0 ),
        .label_out          ( nm_channel_0_label_out ),
        .distance_out       ( nm_channel_0_distance_out ),
        .HDC_ClkEn          ( HDC_ClkEn_net_0 ) 
        );

//--------nm_if_apb
nm_if_apb nm_if_apb_0(
        // Inputs
        .clk             ( clk ),
        .rstb            ( rstb ),
        .rden            ( rden ),
        .wren            ( wren ),
        .pdma_en         ( pdma_en ),
        .fft_en          ( fft_en ),
        .addr            ( addr ),
        .data_wr         ( data_wr ),
        .rst_busy        ( rst_busy_net_0 ),
        .tx_data_rb_n1   ( tx_data_rb_n1_const_net_0 ),
        .tx_data_rb_n0   ( nm_channel_0_tx_data_rb ),
        .adc_frame_rdy   ( adc_frame_rdy_net_0 ),
        .adc_fifo_empty  ( adc_fifo_empty_net_0 ),
        .ack_rdy         ( ack_rdy_net_0 ),
        .tx_busy         ( tx_busy_net_0 ),
        .fft_rdy         ( fft_rdy_const_net_0 ),
        .adc_fft_dout_n1 ( adc_fft_dout_n1_const_net_0 ),
        .adc_fft_dout_n0 ( adc_fft_dout_n0_const_net_0 ),
        .ack_dout_n1     ( ack_dout_n1_const_net_0 ),
        .ack_dout_n0     ( nm_channel_0_ack_dout ),
        .label_out       ( nm_channel_0_label_out ),
        .distance_out    ( nm_channel_0_distance_out ),
        .pdma_data       ( pdma_data ),
        // Outputs
        .ack_rdy_irq_req ( ack_rdy_irq_req_net_0 ),
        .pdma_fifo_pop   ( cm_if_apb_0_pdma_fifo_pop ),
        .data_rd         ( data_rd_net_0 ),
        .rst_start       ( rst_start_net_0 ),
        .ack_read        ( ack_read_net_0 ),
        .m3_adc_fifo_pop ( m3_adc_fifo_pop_net_0 ),
        .tx_start        ( tx_start_net_0 ),
        .tx_mode         ( tx_mode_net_0 ),
        .adc_vec_n1      (  ),
        .adc_vec_n0      ( cm_if_apb_0_adc_vec_n0 ),
        .tx_data_n1      (  ),
        .tx_data_n0      ( cm_if_apb_0_tx_data_n0 ),
        .fft_rd_strobe   ( fft_rd_strobe_net_0 ),
        .mode_in         ( nm_if_apb_0_mode_in ),
        .label_in        ( nm_if_apb_0_label_in ),
        .debug           ( nm_apb_debug_net_0 ) 
        );

//--------pdma_if
pdma_if #( 
        .DEBUG_BUS_SIZE ( 4 ) )
pdma_if_0(
        // Inputs
        .clk                 ( clk ),
        .rstb                ( rstb ),
        .pdma_en             ( pdma_en ),
        .pdma_fifo_pop       ( MX2_2_Y ),
        .adc_frame_rdy_n1    ( VCC_net ),
        .adc_fifo_empty_n1   ( VCC_net ),
        .adc_frame_rdy_n0    ( nm_channel_0_adc_frame_rdy ),
        .adc_fifo_empty_n0   ( nm_channel_0_adc_fifo_empty ),
        .adc_fifo_dout_n1    ( adc_fifo_dout_n1_const_net_0 ),
        .adc_fifo_dout_n0    ( nm_channel_0_adc_fifo_dout_0 ),
        .acc_data            ( acc_data ),
        // Outputs
        .pdma_done_irq_req   ( pdma_done_irq_req_net_0 ),
        .pdma_data_rdy       ( pdma_data_rdy_net_0 ),
        .adc_fifo_pop_n1     (  ),
        .adc_fifo_pop_n0     ( pdma_if_0_adc_fifo_pop_n0 ),
        .pdma_fifo_overflow  ( pdma_if_0_pdma_fifo_overflow ),
        .pdma_fifo_underflow ( pdma_if_0_pdma_fifo_underflow ),
        .pdma_data           ( pdma_data ),
        .debug               ( pdma_debug_0 ) 
        );


endmodule
