//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue Feb 19 01:54:54 2019
// Version: v11.8 SP3 11.8.3.6
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// cm_top
module cm_top(
    // Inputs
    ACC_CLK,
    HDC_Clk,
    PADDR,
    PCLK,
    PENABLE,
    PRESETN,
    PSEL,
    PWDATA,
    PWRITE,
    n2c_data,
    // Outputs
    ACK_RDY_IRQ_REQ,
    C2N_DATA_0,
    C2N_VALID_0,
    HDC_ClkEn,
    PDMA_DATA_RDY,
    PDMA_DONE_IRQ_REQ,
    PRDATA,
    PREADY,
    PSLVERR
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         ACC_CLK;
input         HDC_Clk;
input  [15:0] PADDR;
input         PCLK;
input         PENABLE;
input         PRESETN;
input         PSEL;
input  [31:0] PWDATA;
input         PWRITE;
input         n2c_data;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        ACK_RDY_IRQ_REQ;
output        C2N_DATA_0;
output        C2N_VALID_0;
output        HDC_ClkEn;
output        PDMA_DATA_RDY;
output        PDMA_DONE_IRQ_REQ;
output [31:0] PRDATA;
output        PREADY;
output        PSLVERR;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          ACC_CLK;
wire          ACK_RDY_IRQ_REQ_net_0;
wire   [15:0] PADDR;
wire          PENABLE;
wire   [31:0] BIF_1_PRDATA;
wire          BIF_1_PREADY;
wire          PSEL;
wire          BIF_1_PSLVERR;
wire   [31:0] PWDATA;
wire          PWRITE;
wire          C2N_DATA_0_net_0;
wire          C2N_VALID_0_net_0;
wire   [15:0] cm_if_apb_0_apb_addr;
wire   [31:0] cm_if_apb_0_apb_data_wr;
wire          cm_if_apb_0_artifact_en;
wire          cm_if_apb_0_emulate_nm_0;
wire          cm_if_apb_0_emulate_nm_1;
wire          cm_if_apb_0_emulate_pdma;
wire   [11:0] cm_if_apb_0_fft_channel;
wire          cm_if_apb_0_fft_en;
wire          cm_if_apb_0_pdma_en;
wire          cm_if_apb_0_rd_enable;
wire          cm_if_apb_0_wr_enable;
wire          HDC_Clk;
wire          HDC_ClkEn_net_0;
wire          n2c_data;
wire          nm_if_0_c2n_data;
wire          nm_if_0_c2n_valid_0;
wire   [31:0] nm_if_0_data_rd;
wire          PCLK;
wire          PDMA_DATA_RDY_net_0;
wire          PDMA_DONE_IRQ_REQ_net_0;
wire          PRESETN;
wire          ACK_RDY_IRQ_REQ_net_1;
wire          PDMA_DONE_IRQ_REQ_net_1;
wire          PDMA_DATA_RDY_net_1;
wire          C2N_DATA_0_net_1;
wire          C2N_VALID_0_net_1;
wire          BIF_1_PREADY_net_0;
wire          BIF_1_PSLVERR_net_0;
wire   [31:0] BIF_1_PRDATA_net_0;
wire          HDC_ClkEn_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   [31:0] acc_PRDATA_const_net_0;
wire          GND_net;
wire   [47:0] acc_data_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign acc_PRDATA_const_net_0 = 32'h00000000;
assign GND_net                = 1'b0;
assign acc_data_const_net_0   = 48'h000000000000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign ACK_RDY_IRQ_REQ_net_1   = ACK_RDY_IRQ_REQ_net_0;
assign ACK_RDY_IRQ_REQ         = ACK_RDY_IRQ_REQ_net_1;
assign PDMA_DONE_IRQ_REQ_net_1 = PDMA_DONE_IRQ_REQ_net_0;
assign PDMA_DONE_IRQ_REQ       = PDMA_DONE_IRQ_REQ_net_1;
assign PDMA_DATA_RDY_net_1     = PDMA_DATA_RDY_net_0;
assign PDMA_DATA_RDY           = PDMA_DATA_RDY_net_1;
assign C2N_DATA_0_net_1        = C2N_DATA_0_net_0;
assign C2N_DATA_0              = C2N_DATA_0_net_1;
assign C2N_VALID_0_net_1       = C2N_VALID_0_net_0;
assign C2N_VALID_0             = C2N_VALID_0_net_1;
assign BIF_1_PREADY_net_0      = BIF_1_PREADY;
assign PREADY                  = BIF_1_PREADY_net_0;
assign BIF_1_PSLVERR_net_0     = BIF_1_PSLVERR;
assign PSLVERR                 = BIF_1_PSLVERR_net_0;
assign BIF_1_PRDATA_net_0      = BIF_1_PRDATA;
assign PRDATA[31:0]            = BIF_1_PRDATA_net_0;
assign HDC_ClkEn_net_1         = HDC_ClkEn_net_0;
assign HDC_ClkEn               = HDC_ClkEn_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------cm_if_apb
cm_if_apb #( 
        .DEBUG_BUS_SIZE ( 4 ) )
cm_if_apb_0(
        // Inputs
        .PCLK          ( PCLK ),
        .PRESETN       ( PRESETN ),
        .PENABLE       ( PENABLE ),
        .PSEL          ( PSEL ),
        .PWRITE        ( PWRITE ),
        .PADDR         ( PADDR ),
        .PWDATA        ( PWDATA ),
        .nmif_PRDATA   ( nm_if_0_data_rd ),
        .acc_PRDATA    ( acc_PRDATA_const_net_0 ),
        // Outputs
        .PREADY        ( BIF_1_PREADY ),
        .PSLVERR       ( BIF_1_PSLVERR ),
        .rd_enable     ( cm_if_apb_0_rd_enable ),
        .wr_enable     ( cm_if_apb_0_wr_enable ),
        .pdma_en       ( cm_if_apb_0_pdma_en ),
        .artifact_en   ( cm_if_apb_0_artifact_en ),
        .fft_en        ( cm_if_apb_0_fft_en ),
        .acc_irq_en    (  ),
        .emulate_pdma  ( cm_if_apb_0_emulate_pdma ),
        .emulate_nm_1  ( cm_if_apb_0_emulate_nm_1 ),
        .emulate_nm_0  ( cm_if_apb_0_emulate_nm_0 ),
        .emulate_acc   (  ),
        .nm1_stim_ld   (  ),
        .nm0_stim_ld   (  ),
        .PRDATA        ( BIF_1_PRDATA ),
        .apb_addr      ( cm_if_apb_0_apb_addr ),
        .apb_data_wr   ( cm_if_apb_0_apb_data_wr ),
        .fft_channel   ( cm_if_apb_0_fft_channel ),
        .debug_sel     (  ),
        .nm1_num_stims (  ),
        .nm0_num_stims (  ),
        .mode_dbg      (  ),
        .debug         (  ) 
        );

//--------MX2
MX2 MX2_5(
        // Inputs
        .A ( nm_if_0_c2n_data ),
        .B ( GND_net ),
        .S ( cm_if_apb_0_emulate_nm_0 ),
        // Outputs
        .Y ( C2N_DATA_0_net_0 ) 
        );

//--------MX2
MX2 MX2_7(
        // Inputs
        .A ( nm_if_0_c2n_valid_0 ),
        .B ( GND_net ),
        .S ( cm_if_apb_0_emulate_nm_0 ),
        // Outputs
        .Y ( C2N_VALID_0_net_0 ) 
        );

//--------nm_if
nm_if nm_if_0(
        // Inputs
        .clk               ( PCLK ),
        .rstb              ( PRESETN ),
        .rden              ( cm_if_apb_0_rd_enable ),
        .wren              ( cm_if_apb_0_wr_enable ),
        .pdma_en           ( cm_if_apb_0_pdma_en ),
        .pdma_emulate      ( cm_if_apb_0_emulate_pdma ),
        .pdma_fifo_pop_emu ( GND_net ),
        .artifact_en       ( cm_if_apb_0_artifact_en ),
        .fft_en            ( cm_if_apb_0_fft_en ),
        .clk_1ms           ( ACC_CLK ),
        .n2c_data          ( n2c_data ),
        .addr              ( cm_if_apb_0_apb_addr ),
        .data_wr           ( cm_if_apb_0_apb_data_wr ),
        .acc_data          ( acc_data_const_net_0 ),
        .fft_channel       ( cm_if_apb_0_fft_channel ),
        .HDC_Clk           ( HDC_Clk ),
        // Outputs
        .ack_rdy_irq_req   ( ACK_RDY_IRQ_REQ_net_0 ),
        .pdma_data_rdy     ( PDMA_DATA_RDY_net_0 ),
        .pdma_done_irq_req ( PDMA_DONE_IRQ_REQ_net_0 ),
        .c2n_data          ( nm_if_0_c2n_data ),
        .c2n_valid_0       ( nm_if_0_c2n_valid_0 ),
        .data_rd           ( nm_if_0_data_rd ),
        .adc_dp_debug      (  ),
        .adc_vec_debug     (  ),
        .adc_art_debug     (  ),
        .pdma_debug        (  ),
        .ntx_debug         (  ),
        .nrx_debug         (  ),
        .ack_dp_debug      (  ),
        .nm_apb_debug      (  ),
        .led               (  ),
        .HDC_ClkEn         ( HDC_ClkEn_net_0 ) 
        );


endmodule
