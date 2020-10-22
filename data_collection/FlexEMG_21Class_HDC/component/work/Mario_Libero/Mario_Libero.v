//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Thu Feb 21 19:54:12 2019
// Version: v11.8 SP3 11.8.3.6
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// Mario_Libero
module Mario_Libero(
    // Inputs
    MMUART_1_RXD,
    N2C_DATA_0,
    SPI_0_DI,
    XTL,
    // Outputs
    ACC_CLKIN,
    C2N_DATA_0,
    C2N_VALID_0,
    CLK_OUT,
    CLK_OUT2,
    DDR_CKE,
    DDR_CSN,
    MMUART_1_TXD,
    SPI_0_CLK,
    SPI_0_DO,
    SPI_0_SS0,
    SPI_DEBUG
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  MMUART_1_RXD;
input  N2C_DATA_0;
input  SPI_0_DI;
input  XTL;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output ACC_CLKIN;
output C2N_DATA_0;
output C2N_VALID_0;
output CLK_OUT;
output CLK_OUT2;
output DDR_CKE;
output DDR_CSN;
output MMUART_1_TXD;
output SPI_0_CLK;
output SPI_0_DO;
output SPI_0_SS0;
output SPI_DEBUG;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          ACC_CLKIN_net_0;
wire          C2N_DATA_0_net_0;
wire          C2N_VALID_0_net_0;
wire          CLK_OUT_0;
wire          cm_top_0_HDC_ClkEn;
wire          cmam_if_0_ACK_RDY_IRQ_REQ;
wire          cmam_if_0_PDMA_DATA_RDY;
wire          cmam_if_0_PDMA_DONE_IRQ_REQ;
wire          CoreAPB3_0_APBmslave0_PENABLE;
wire   [31:0] CoreAPB3_0_APBmslave0_PRDATA;
wire          CoreAPB3_0_APBmslave0_PREADY;
wire          CoreAPB3_0_APBmslave0_PSELx;
wire          CoreAPB3_0_APBmslave0_PSLVERR;
wire   [31:0] CoreAPB3_0_APBmslave0_PWDATA;
wire          CoreAPB3_0_APBmslave0_PWRITE;
wire   [31:0] CoreAPB3_0_APBmslave1_1_PRDATA;
wire          CoreAPB3_0_APBmslave1_1_PREADY;
wire          CoreAPB3_0_APBmslave1_1_PSELx;
wire          CoreAPB3_0_APBmslave1_1_PSLVERR;
wire   [0:0]  CoreGPIO_0_INT0to0_1;
wire   [1:1]  CoreGPIO_0_INT1to1_0;
wire   [2:2]  CoreGPIO_0_INT2to2;
wire   [3:3]  CoreGPIO_0_INT3to3;
wire          FCCC_0_GL0_0;
wire          FCCC_0_GL1_0;
wire          FCCC_0_LOCK;
wire   [31:0] Mario_Libero_MSS_0_FIC_0_APB_MASTER_PADDR;
wire          Mario_Libero_MSS_0_FIC_0_APB_MASTER_PENABLE;
wire   [31:0] Mario_Libero_MSS_0_FIC_0_APB_MASTER_PRDATA;
wire          Mario_Libero_MSS_0_FIC_0_APB_MASTER_PREADY;
wire          Mario_Libero_MSS_0_FIC_0_APB_MASTER_PSELx;
wire          Mario_Libero_MSS_0_FIC_0_APB_MASTER_PSLVERR;
wire   [31:0] Mario_Libero_MSS_0_FIC_0_APB_MASTER_PWDATA;
wire          Mario_Libero_MSS_0_FIC_0_APB_MASTER_PWRITE;
wire          Mario_Libero_MSS_0_MSS_RESET_N_M2F;
wire          MMUART_1_RXD;
wire          MMUART_1_TXD_1;
wire          OSC_0_XTLOSC_CCC_OUT_XTLOSC_CCC;
wire          SPI_0_CLK_3;
wire          SPI_0_DI;
wire          SPI_0_DO_5;
wire          SPI_0_SS0_3;
wire          XTL;
wire          CLK_OUT_0_net_0;
wire          CLK_OUT_0_net_1;
wire          ACC_CLKIN_net_1;
wire          C2N_DATA_0_net_1;
wire          C2N_VALID_0_net_1;
wire          MMUART_1_TXD_1_net_0;
wire          SPI_0_DO_5_net_0;
wire          SPI_0_CLK_3_net_0;
wire          SPI_0_SS0_3_net_0;
wire          SPI_0_CLK_3_net_1;
wire   [3:0]  INT_net_0;
wire   [3:0]  GPIO_IN_net_0;
wire   [1:0]  DMA_DMAREADY_FIC_0_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          VCC_net;
wire          GND_net;
wire   [31:0] IADDR_const_net_0;
wire   [7:2]  PADDR_const_net_0;
wire   [7:0]  PWDATA_const_net_0;
wire   [31:0] PRDATAS2_const_net_0;
wire   [31:0] PRDATAS3_const_net_0;
wire   [31:0] PRDATAS4_const_net_0;
wire   [31:0] PRDATAS5_const_net_0;
wire   [31:0] PRDATAS6_const_net_0;
wire   [31:0] PRDATAS7_const_net_0;
wire   [31:0] PRDATAS8_const_net_0;
wire   [31:0] PRDATAS9_const_net_0;
wire   [31:0] PRDATAS10_const_net_0;
wire   [31:0] PRDATAS11_const_net_0;
wire   [31:0] PRDATAS12_const_net_0;
wire   [31:0] PRDATAS13_const_net_0;
wire   [31:0] PRDATAS14_const_net_0;
wire   [31:0] PRDATAS15_const_net_0;
wire   [31:0] PRDATAS16_const_net_0;
//--------------------------------------------------------------------
// Inverted Nets
//--------------------------------------------------------------------
wire          N2C_DATA_0;
wire          N2C_DATA_0_IN_POST_INV0_0;
//--------------------------------------------------------------------
// Bus Interface Nets Declarations - Unequal Pin Widths
//--------------------------------------------------------------------
wire   [7:0]  CoreAPB3_0_APBmslave0_PADDR_1_7to0;
wire   [7:0]  CoreAPB3_0_APBmslave0_PADDR_1;
wire   [31:0] CoreAPB3_0_APBmslave0_PADDR;
wire   [15:0] CoreAPB3_0_APBmslave0_PADDR_0_15to0;
wire   [15:0] CoreAPB3_0_APBmslave0_PADDR_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign VCC_net               = 1'b1;
assign GND_net               = 1'b0;
assign IADDR_const_net_0     = 32'h00000000;
assign PADDR_const_net_0     = 6'h00;
assign PWDATA_const_net_0    = 8'h00;
assign PRDATAS2_const_net_0  = 32'h00000000;
assign PRDATAS3_const_net_0  = 32'h00000000;
assign PRDATAS4_const_net_0  = 32'h00000000;
assign PRDATAS5_const_net_0  = 32'h00000000;
assign PRDATAS6_const_net_0  = 32'h00000000;
assign PRDATAS7_const_net_0  = 32'h00000000;
assign PRDATAS8_const_net_0  = 32'h00000000;
assign PRDATAS9_const_net_0  = 32'h00000000;
assign PRDATAS10_const_net_0 = 32'h00000000;
assign PRDATAS11_const_net_0 = 32'h00000000;
assign PRDATAS12_const_net_0 = 32'h00000000;
assign PRDATAS13_const_net_0 = 32'h00000000;
assign PRDATAS14_const_net_0 = 32'h00000000;
assign PRDATAS15_const_net_0 = 32'h00000000;
assign PRDATAS16_const_net_0 = 32'h00000000;
//--------------------------------------------------------------------
// Inversions
//--------------------------------------------------------------------
assign N2C_DATA_0_IN_POST_INV0_0 = ~ N2C_DATA_0;
//--------------------------------------------------------------------
// TieOff assignments
//--------------------------------------------------------------------
assign DDR_CSN              = 1'b1;
assign DDR_CKE              = 1'b0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign CLK_OUT_0_net_0      = CLK_OUT_0;
assign CLK_OUT              = CLK_OUT_0_net_0;
assign CLK_OUT_0_net_1      = CLK_OUT_0;
assign CLK_OUT2             = CLK_OUT_0_net_1;
assign ACC_CLKIN_net_1      = ACC_CLKIN_net_0;
assign ACC_CLKIN            = ACC_CLKIN_net_1;
assign C2N_DATA_0_net_1     = C2N_DATA_0_net_0;
assign C2N_DATA_0           = C2N_DATA_0_net_1;
assign C2N_VALID_0_net_1    = C2N_VALID_0_net_0;
assign C2N_VALID_0          = C2N_VALID_0_net_1;
assign MMUART_1_TXD_1_net_0 = MMUART_1_TXD_1;
assign MMUART_1_TXD         = MMUART_1_TXD_1_net_0;
assign SPI_0_DO_5_net_0     = SPI_0_DO_5;
assign SPI_0_DO             = SPI_0_DO_5_net_0;
assign SPI_0_CLK_3_net_0    = SPI_0_CLK_3;
assign SPI_0_CLK            = SPI_0_CLK_3_net_0;
assign SPI_0_SS0_3_net_0    = SPI_0_SS0_3;
assign SPI_0_SS0            = SPI_0_SS0_3_net_0;
assign SPI_0_CLK_3_net_1    = SPI_0_CLK_3;
assign SPI_DEBUG            = SPI_0_CLK_3_net_1;
//--------------------------------------------------------------------
// Slices assignments
//--------------------------------------------------------------------
assign CoreGPIO_0_INT0to0_1[0] = INT_net_0[0:0];
assign CoreGPIO_0_INT1to1_0[1] = INT_net_0[1:1];
assign CoreGPIO_0_INT2to2[2]   = INT_net_0[2:2];
assign CoreGPIO_0_INT3to3[3]   = INT_net_0[3:3];
//--------------------------------------------------------------------
// Concatenation assignments
//--------------------------------------------------------------------
assign GPIO_IN_net_0            = { 1'b0 , 1'b0 , cmam_if_0_ACK_RDY_IRQ_REQ , cmam_if_0_PDMA_DONE_IRQ_REQ };
assign DMA_DMAREADY_FIC_0_net_0 = { 1'b0 , cmam_if_0_PDMA_DATA_RDY };
//--------------------------------------------------------------------
// Bus Interface Nets Assignments - Unequal Pin Widths
//--------------------------------------------------------------------
assign CoreAPB3_0_APBmslave0_PADDR_1_7to0 = CoreAPB3_0_APBmslave0_PADDR[7:0];
assign CoreAPB3_0_APBmslave0_PADDR_1 = { CoreAPB3_0_APBmslave0_PADDR_1_7to0 };
assign CoreAPB3_0_APBmslave0_PADDR_0_15to0 = CoreAPB3_0_APBmslave0_PADDR[15:0];
assign CoreAPB3_0_APBmslave0_PADDR_0 = { CoreAPB3_0_APBmslave0_PADDR_0_15to0 };

//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------cm_top
cm_top cm_top_0(
        // Inputs
        .PCLK              ( FCCC_0_GL0_0 ),
        .ACC_CLK           ( GND_net ),
        .PRESETN           ( Mario_Libero_MSS_0_MSS_RESET_N_M2F ),
        .PENABLE           ( CoreAPB3_0_APBmslave0_PENABLE ),
        .PWRITE            ( CoreAPB3_0_APBmslave0_PWRITE ),
        .PSEL              ( CoreAPB3_0_APBmslave0_PSELx ),
        .n2c_data          ( N2C_DATA_0_IN_POST_INV0_0 ),
        .HDC_Clk           ( FCCC_0_GL1_0 ),
        .PADDR             ( CoreAPB3_0_APBmslave0_PADDR_0 ),
        .PWDATA            ( CoreAPB3_0_APBmslave0_PWDATA ),
        // Outputs
        .ACK_RDY_IRQ_REQ   ( cmam_if_0_ACK_RDY_IRQ_REQ ),
        .PDMA_DONE_IRQ_REQ ( cmam_if_0_PDMA_DONE_IRQ_REQ ),
        .PDMA_DATA_RDY     ( cmam_if_0_PDMA_DATA_RDY ),
        .C2N_DATA_0        ( C2N_DATA_0_net_0 ),
        .C2N_VALID_0       ( C2N_VALID_0_net_0 ),
        .PREADY            ( CoreAPB3_0_APBmslave0_PREADY ),
        .PSLVERR           ( CoreAPB3_0_APBmslave0_PSLVERR ),
        .HDC_ClkEn         ( cm_top_0_HDC_ClkEn ),
        .PRDATA            ( CoreAPB3_0_APBmslave0_PRDATA ) 
        );

//--------CoreAPB3   -   Actel:DirectCore:CoreAPB3:4.1.100
CoreAPB3 #( 
        .APB_DWIDTH      ( 32 ),
        .APBSLOT0ENABLE  ( 1 ),
        .APBSLOT1ENABLE  ( 1 ),
        .APBSLOT2ENABLE  ( 0 ),
        .APBSLOT3ENABLE  ( 0 ),
        .APBSLOT4ENABLE  ( 0 ),
        .APBSLOT5ENABLE  ( 0 ),
        .APBSLOT6ENABLE  ( 0 ),
        .APBSLOT7ENABLE  ( 0 ),
        .APBSLOT8ENABLE  ( 0 ),
        .APBSLOT9ENABLE  ( 0 ),
        .APBSLOT10ENABLE ( 0 ),
        .APBSLOT11ENABLE ( 0 ),
        .APBSLOT12ENABLE ( 0 ),
        .APBSLOT13ENABLE ( 0 ),
        .APBSLOT14ENABLE ( 0 ),
        .APBSLOT15ENABLE ( 0 ),
        .FAMILY          ( 19 ),
        .IADDR_OPTION    ( 0 ),
        .MADDR_BITS      ( 20 ),
        .SC_0            ( 0 ),
        .SC_1            ( 0 ),
        .SC_2            ( 0 ),
        .SC_3            ( 0 ),
        .SC_4            ( 0 ),
        .SC_5            ( 0 ),
        .SC_6            ( 0 ),
        .SC_7            ( 0 ),
        .SC_8            ( 0 ),
        .SC_9            ( 0 ),
        .SC_10           ( 0 ),
        .SC_11           ( 0 ),
        .SC_12           ( 0 ),
        .SC_13           ( 0 ),
        .SC_14           ( 0 ),
        .SC_15           ( 0 ),
        .UPR_NIBBLE_POSN ( 8 ) )
CoreAPB3_0(
        // Inputs
        .PRESETN    ( GND_net ), // tied to 1'b0 from definition
        .PCLK       ( GND_net ), // tied to 1'b0 from definition
        .PWRITE     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PWRITE ),
        .PENABLE    ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PENABLE ),
        .PSEL       ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PSELx ),
        .PREADYS0   ( CoreAPB3_0_APBmslave0_PREADY ),
        .PSLVERRS0  ( CoreAPB3_0_APBmslave0_PSLVERR ),
        .PREADYS1   ( CoreAPB3_0_APBmslave1_1_PREADY ),
        .PSLVERRS1  ( CoreAPB3_0_APBmslave1_1_PSLVERR ),
        .PREADYS2   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS2  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS3   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS3  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS4   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS4  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS5   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS5  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS6   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS6  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS7   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS7  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS8   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS8  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS9   ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS9  ( GND_net ), // tied to 1'b0 from definition
        .PREADYS10  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS10 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS11  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS11 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS12  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS12 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS13  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS13 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS14  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS14 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS15  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS15 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS16  ( VCC_net ), // tied to 1'b1 from definition
        .PSLVERRS16 ( GND_net ), // tied to 1'b0 from definition
        .PADDR      ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PADDR ),
        .PWDATA     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PWDATA ),
        .PRDATAS0   ( CoreAPB3_0_APBmslave0_PRDATA ),
        .PRDATAS1   ( CoreAPB3_0_APBmslave1_1_PRDATA ),
        .PRDATAS2   ( PRDATAS2_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS3   ( PRDATAS3_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS4   ( PRDATAS4_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS5   ( PRDATAS5_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS6   ( PRDATAS6_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS7   ( PRDATAS7_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS8   ( PRDATAS8_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS9   ( PRDATAS9_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS10  ( PRDATAS10_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS11  ( PRDATAS11_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS12  ( PRDATAS12_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS13  ( PRDATAS13_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS14  ( PRDATAS14_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS15  ( PRDATAS15_const_net_0 ), // tied to 32'h00000000 from definition
        .PRDATAS16  ( PRDATAS16_const_net_0 ), // tied to 32'h00000000 from definition
        .IADDR      ( IADDR_const_net_0 ), // tied to 32'h00000000 from definition
        // Outputs
        .PREADY     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PREADY ),
        .PSLVERR    ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PSLVERR ),
        .PWRITES    ( CoreAPB3_0_APBmslave0_PWRITE ),
        .PENABLES   ( CoreAPB3_0_APBmslave0_PENABLE ),
        .PSELS0     ( CoreAPB3_0_APBmslave0_PSELx ),
        .PSELS1     ( CoreAPB3_0_APBmslave1_1_PSELx ),
        .PSELS2     (  ),
        .PSELS3     (  ),
        .PSELS4     (  ),
        .PSELS5     (  ),
        .PSELS6     (  ),
        .PSELS7     (  ),
        .PSELS8     (  ),
        .PSELS9     (  ),
        .PSELS10    (  ),
        .PSELS11    (  ),
        .PSELS12    (  ),
        .PSELS13    (  ),
        .PSELS14    (  ),
        .PSELS15    (  ),
        .PSELS16    (  ),
        .PRDATA     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PRDATA ),
        .PADDRS     ( CoreAPB3_0_APBmslave0_PADDR ),
        .PWDATAS    ( CoreAPB3_0_APBmslave0_PWDATA ) 
        );

//--------Mario_Libero_CoreGPIO_0_CoreGPIO   -   Actel:DirectCore:CoreGPIO:3.2.102
Mario_Libero_CoreGPIO_0_CoreGPIO #( 
        .APB_WIDTH       ( 32 ),
        .FIXED_CONFIG_0  ( 0 ),
        .FIXED_CONFIG_1  ( 0 ),
        .FIXED_CONFIG_2  ( 0 ),
        .FIXED_CONFIG_3  ( 0 ),
        .FIXED_CONFIG_4  ( 0 ),
        .FIXED_CONFIG_5  ( 0 ),
        .FIXED_CONFIG_6  ( 0 ),
        .FIXED_CONFIG_7  ( 0 ),
        .FIXED_CONFIG_8  ( 0 ),
        .FIXED_CONFIG_9  ( 0 ),
        .FIXED_CONFIG_10 ( 0 ),
        .FIXED_CONFIG_11 ( 0 ),
        .FIXED_CONFIG_12 ( 0 ),
        .FIXED_CONFIG_13 ( 0 ),
        .FIXED_CONFIG_14 ( 0 ),
        .FIXED_CONFIG_15 ( 0 ),
        .FIXED_CONFIG_16 ( 0 ),
        .FIXED_CONFIG_17 ( 0 ),
        .FIXED_CONFIG_18 ( 0 ),
        .FIXED_CONFIG_19 ( 0 ),
        .FIXED_CONFIG_20 ( 0 ),
        .FIXED_CONFIG_21 ( 0 ),
        .FIXED_CONFIG_22 ( 0 ),
        .FIXED_CONFIG_23 ( 0 ),
        .FIXED_CONFIG_24 ( 0 ),
        .FIXED_CONFIG_25 ( 0 ),
        .FIXED_CONFIG_26 ( 0 ),
        .FIXED_CONFIG_27 ( 0 ),
        .FIXED_CONFIG_28 ( 0 ),
        .FIXED_CONFIG_29 ( 0 ),
        .FIXED_CONFIG_30 ( 0 ),
        .FIXED_CONFIG_31 ( 0 ),
        .INT_BUS         ( 0 ),
        .IO_INT_TYPE_0   ( 2 ),
        .IO_INT_TYPE_1   ( 2 ),
        .IO_INT_TYPE_2   ( 2 ),
        .IO_INT_TYPE_3   ( 2 ),
        .IO_INT_TYPE_4   ( 7 ),
        .IO_INT_TYPE_5   ( 7 ),
        .IO_INT_TYPE_6   ( 7 ),
        .IO_INT_TYPE_7   ( 7 ),
        .IO_INT_TYPE_8   ( 7 ),
        .IO_INT_TYPE_9   ( 7 ),
        .IO_INT_TYPE_10  ( 7 ),
        .IO_INT_TYPE_11  ( 7 ),
        .IO_INT_TYPE_12  ( 7 ),
        .IO_INT_TYPE_13  ( 7 ),
        .IO_INT_TYPE_14  ( 7 ),
        .IO_INT_TYPE_15  ( 7 ),
        .IO_INT_TYPE_16  ( 7 ),
        .IO_INT_TYPE_17  ( 7 ),
        .IO_INT_TYPE_18  ( 7 ),
        .IO_INT_TYPE_19  ( 7 ),
        .IO_INT_TYPE_20  ( 7 ),
        .IO_INT_TYPE_21  ( 7 ),
        .IO_INT_TYPE_22  ( 7 ),
        .IO_INT_TYPE_23  ( 7 ),
        .IO_INT_TYPE_24  ( 7 ),
        .IO_INT_TYPE_25  ( 7 ),
        .IO_INT_TYPE_26  ( 7 ),
        .IO_INT_TYPE_27  ( 7 ),
        .IO_INT_TYPE_28  ( 7 ),
        .IO_INT_TYPE_29  ( 7 ),
        .IO_INT_TYPE_30  ( 7 ),
        .IO_INT_TYPE_31  ( 7 ),
        .IO_NUM          ( 4 ),
        .IO_TYPE_0       ( 1 ),
        .IO_TYPE_1       ( 1 ),
        .IO_TYPE_2       ( 1 ),
        .IO_TYPE_3       ( 1 ),
        .IO_TYPE_4       ( 0 ),
        .IO_TYPE_5       ( 0 ),
        .IO_TYPE_6       ( 0 ),
        .IO_TYPE_7       ( 0 ),
        .IO_TYPE_8       ( 0 ),
        .IO_TYPE_9       ( 0 ),
        .IO_TYPE_10      ( 0 ),
        .IO_TYPE_11      ( 0 ),
        .IO_TYPE_12      ( 0 ),
        .IO_TYPE_13      ( 0 ),
        .IO_TYPE_14      ( 0 ),
        .IO_TYPE_15      ( 0 ),
        .IO_TYPE_16      ( 0 ),
        .IO_TYPE_17      ( 0 ),
        .IO_TYPE_18      ( 0 ),
        .IO_TYPE_19      ( 0 ),
        .IO_TYPE_20      ( 0 ),
        .IO_TYPE_21      ( 0 ),
        .IO_TYPE_22      ( 0 ),
        .IO_TYPE_23      ( 0 ),
        .IO_TYPE_24      ( 0 ),
        .IO_TYPE_25      ( 0 ),
        .IO_TYPE_26      ( 0 ),
        .IO_TYPE_27      ( 0 ),
        .IO_TYPE_28      ( 0 ),
        .IO_TYPE_29      ( 0 ),
        .IO_TYPE_30      ( 0 ),
        .IO_TYPE_31      ( 0 ),
        .IO_VAL_0        ( 0 ),
        .IO_VAL_1        ( 0 ),
        .IO_VAL_2        ( 0 ),
        .IO_VAL_3        ( 0 ),
        .IO_VAL_4        ( 0 ),
        .IO_VAL_5        ( 0 ),
        .IO_VAL_6        ( 0 ),
        .IO_VAL_7        ( 0 ),
        .IO_VAL_8        ( 0 ),
        .IO_VAL_9        ( 0 ),
        .IO_VAL_10       ( 0 ),
        .IO_VAL_11       ( 0 ),
        .IO_VAL_12       ( 0 ),
        .IO_VAL_13       ( 0 ),
        .IO_VAL_14       ( 0 ),
        .IO_VAL_15       ( 0 ),
        .IO_VAL_16       ( 0 ),
        .IO_VAL_17       ( 0 ),
        .IO_VAL_18       ( 0 ),
        .IO_VAL_19       ( 0 ),
        .IO_VAL_20       ( 0 ),
        .IO_VAL_21       ( 0 ),
        .IO_VAL_22       ( 0 ),
        .IO_VAL_23       ( 0 ),
        .IO_VAL_24       ( 0 ),
        .IO_VAL_25       ( 0 ),
        .IO_VAL_26       ( 0 ),
        .IO_VAL_27       ( 0 ),
        .IO_VAL_28       ( 0 ),
        .IO_VAL_29       ( 0 ),
        .IO_VAL_30       ( 0 ),
        .IO_VAL_31       ( 0 ),
        .OE_TYPE         ( 1 ) )
CoreGPIO_0(
        // Inputs
        .PRESETN  ( Mario_Libero_MSS_0_MSS_RESET_N_M2F ),
        .PCLK     ( FCCC_0_GL0_0 ),
        .PSEL     ( CoreAPB3_0_APBmslave1_1_PSELx ),
        .PENABLE  ( CoreAPB3_0_APBmslave0_PENABLE ),
        .PWRITE   ( CoreAPB3_0_APBmslave0_PWRITE ),
        .PADDR    ( CoreAPB3_0_APBmslave0_PADDR_1 ),
        .PWDATA   ( CoreAPB3_0_APBmslave0_PWDATA ),
        .GPIO_IN  ( GPIO_IN_net_0 ),
        // Outputs
        .PSLVERR  ( CoreAPB3_0_APBmslave1_1_PSLVERR ),
        .PREADY   ( CoreAPB3_0_APBmslave1_1_PREADY ),
        .INT_OR   (  ),
        .PRDATA   ( CoreAPB3_0_APBmslave1_1_PRDATA ),
        .INT      ( INT_net_0 ),
        .GPIO_OUT (  ),
        .GPIO_OE  (  ) 
        );

//--------Mario_Libero_FCCC_0_FCCC   -   Actel:SgCore:FCCC:2.0.201
Mario_Libero_FCCC_0_FCCC FCCC_0(
        // Inputs
        .XTLOSC ( OSC_0_XTLOSC_CCC_OUT_XTLOSC_CCC ),
        .GL1_EN ( cm_top_0_HDC_ClkEn ),
        // Outputs
        .GL0    ( FCCC_0_GL0_0 ),
        .GL1    ( FCCC_0_GL1_0 ),
        .LOCK   ( FCCC_0_LOCK ) 
        );

//--------INV
INV INV_0(
        // Inputs
        .A ( FCCC_0_GL0_0 ),
        // Outputs
        .Y ( CLK_OUT_0 ) 
        );

//--------Mario_Libero_MSS
Mario_Libero_MSS Mario_Libero_MSS_0(
        // Inputs
        .MCCC_CLK_BASE          ( FCCC_0_GL0_0 ),
        .MCCC_CLK_BASE_PLL_LOCK ( FCCC_0_LOCK ),
        .FIC_0_APB_M_PREADY     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PREADY ),
        .FIC_0_APB_M_PSLVERR    ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PSLVERR ),
        .GPIO_5_F2M             ( CoreGPIO_0_INT0to0_1 ),
        .GPIO_6_F2M             ( CoreGPIO_0_INT1to1_0 ),
        .GPIO_7_F2M             ( CoreGPIO_0_INT2to2 ),
        .GPIO_8_F2M             ( CoreGPIO_0_INT3to3 ),
        .MMUART_1_RXD           ( MMUART_1_RXD ),
        .SPI_0_DI_F2M           ( SPI_0_DI ),
        .SPI_0_CLK_F2M          ( GND_net ),
        .SPI_0_SS0_F2M          ( GND_net ),
        .FIC_0_APB_M_PRDATA     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PRDATA ),
        .DMA_DMAREADY_FIC_0     ( DMA_DMAREADY_FIC_0_net_0 ),
        // Outputs
        .FIC_0_APB_M_PSEL       ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PSELx ),
        .FIC_0_APB_M_PWRITE     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PWRITE ),
        .FIC_0_APB_M_PENABLE    ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PENABLE ),
        .MSS_RESET_N_M2F        ( Mario_Libero_MSS_0_MSS_RESET_N_M2F ),
        .GPIO_0_M2F             (  ),
        .GPIO_1_M2F             (  ),
        .GPIO_2_M2F             (  ),
        .GPIO_3_M2F             (  ),
        .GPIO_4_M2F             ( ACC_CLKIN_net_0 ),
        .MMUART_1_TXD           ( MMUART_1_TXD_1 ),
        .SPI_0_DO_M2F           ( SPI_0_DO_5 ),
        .SPI_0_CLK_M2F          ( SPI_0_CLK_3 ),
        .SPI_0_SS0_M2F          ( SPI_0_SS0_3 ),
        .SPI_0_SS0_M2F_OE       (  ),
        .FIC_0_APB_M_PADDR      ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PADDR ),
        .FIC_0_APB_M_PWDATA     ( Mario_Libero_MSS_0_FIC_0_APB_MASTER_PWDATA ) 
        );

//--------Mario_Libero_OSC_0_OSC   -   Actel:SgCore:OSC:2.0.101
Mario_Libero_OSC_0_OSC OSC_0(
        // Inputs
        .XTL                ( XTL ),
        // Outputs
        .RCOSC_25_50MHZ_CCC (  ),
        .RCOSC_25_50MHZ_O2F (  ),
        .RCOSC_1MHZ_CCC     (  ),
        .RCOSC_1MHZ_O2F     (  ),
        .XTLOSC_CCC         ( OSC_0_XTLOSC_CCC_OUT_XTLOSC_CCC ),
        .XTLOSC_O2F         (  ) 
        );


endmodule
