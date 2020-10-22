`timescale 1 ns / 1 ns

// ********************************************************************
// Actel Corporation Proprietary and Confidential
//  Copyright 2009 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description:	User testbench for CoreAI (Analog Interface)
//
// Revision Information:
// Date			Description
// ----			-----------------------------------------
// 03Mar09		Initial Version 2.0
//
// SVN Revision Information:
// SVN $Revision: $
// SVN $Date: $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
// 1. best viewed with tabstops set to "4"
// 2. Most of the behavior is driven from the BFM scripts for the APB master.
//    Consult the Actel AMBA BFM documentation for more information.
//
// History:		04/27/09  - AS translated using XTEK
//
// *********************************************************************




module testbench;

    //`include "../../coreparameters.v"
    `include "../../../../coreparameters.v"
    
   // vector file for driving the APB master BFM
   // NOTE: location of the following files can be overridden at run time
   parameter            APB_MASTER_VECTFILE = "coregpio_usertb_apb_master.vec";
   // propagation delay in ns
   parameter            TPD = 3;
   
   //---------------------------------------------------------------------------
   // components
   //---------------------------------------------------------------------------
   // from work.components ...
   
   //-----------------------------------------------------------------------------
   // constants
   //-----------------------------------------------------------------------------
   parameter            APB_MASTER_CLK_CYCLE = 100;
   parameter            APB_MASTER_CLK_CYCLE_LO_TIME = (APB_MASTER_CLK_CYCLE/2);
   // add 1 if APB_MASTER_CLK_CYCLE is odd number to compensate for PCLK period
   parameter            APB_MASTER_CLK_CYCLE_HI_TIME = (APB_MASTER_CLK_CYCLE/2);
   
   parameter [31:0]     ADDR_IN = 32'h00000000;
   parameter [31:0]     ADDR_OUT = 32'h00000001;
   parameter [31:0]     ADDR_INT = 32'h00000002;
   parameter [31:0]     ADDR_OE = 32'h00000003;
   
   //----------------------------------------------------------------------------
   // signals
   //-----------------------------------------------------------------------------
   
   // system
   reg                  SYSRSTN_apb;
   reg                  SYSCLK_apb;
   
   // APB
   wire                 PCLK;
   wire                 PRESETN;
   wire [31:0]          PADDR_apb_bfm_wide;
   wire [7:0]           PADDR;
   wire [15:0]          PSEL_apb_bfm_wide;
   wire                 PSEL;
   wire                 PENABLE;
   wire                 PWRITE;
   wire [31:0]          PWDATA_apb_bfm_wide;
   wire [APB_WIDTH-1:0] PWDATA;
   
   // BFM
   wire [31:0]          PRDATA_apb_bfm_wide;
   wire [APB_WIDTH-1:0] PRDATA;
   wire                 PREADY;
   wire                 PSLVERR;
   
   wire [31:0]          GP_IN_apb_bfm;
   wire [31:0]          GP_OUT_apb_bfm;
   wire                 FINISHED_apb_bfm;
   wire                 FAILED_apb_bfm;
   
   // DUT
   reg [IO_NUM-1:0]     GPIO_IN;
   wire [IO_NUM-1:0]    GPIO_OUT;
   wire [IO_NUM-1:0]    GPIO_OE;
   wire [IO_NUM-1:0]    INT;
   wire                 INT_OR;
   
   // BFM memory interface
   wire [31:0]          BFM_ADDR;
   wire [31:0]          BFM_DATA;
   wire [31:0]          BFM_DATA_i;
   wire                 BFM_RD;
   wire                 BFM_WR;
   
   // misc. signals
   wire [255:0]         GND256;
   wire [31:0]          GND32;
   wire [7:0]           GND8;
   wire [4:0]           GND5;
   wire [3:0]           GND4;
   wire                 GND1;
   reg [0:0]            stopsim;
   
   assign PADDR = PADDR_apb_bfm_wide[7:0];
   assign PSEL = PSEL_apb_bfm_wide[0];
   assign PWDATA = PWDATA_apb_bfm_wide[APB_WIDTH - 1:0];
   
   generate
      if (APB_WIDTH == 32)
      begin : rdata_32
         assign PRDATA_apb_bfm_wide[31:0] = PRDATA[31:0];
      end
   endgenerate
   
   generate
      if (APB_WIDTH == 16)
      begin : rdata_16
         assign PRDATA_apb_bfm_wide[31:0] = {16'h0000, PRDATA[15:0]};
      end
   endgenerate
   
   generate
      if (APB_WIDTH == 8)
      begin : rdata_8
         assign PRDATA_apb_bfm_wide[31:0] = {24'h000000, PRDATA[7:0]};
      end
   endgenerate
   
      // System clock
      initial SYSCLK_apb = 1'b0;
      always
      begin
      	#APB_MASTER_CLK_CYCLE_LO_TIME SYSCLK_apb = 1'b1;
      	#APB_MASTER_CLK_CYCLE_HI_TIME SYSCLK_apb = 1'b0;
      end
      
      // Main simulation
      initial
      begin: main_sim
      	SYSRSTN_apb	= 0;
      	@ (posedge SYSCLK_apb); #TPD;
      	SYSRSTN_apb	= 1;
      	@ (posedge SYSCLK_apb); #TPD;
      
      	// wait until BFM is finished
      	while (!(FINISHED_apb_bfm===1'b1))
      	begin
      		@ (posedge SYSCLK_apb); #TPD;
      	end
      	stopsim=1;
      	#1;
      	$stop;
      end
      
      // ------------------------------------------------------
      // BFM register interface
      
      // store BFM-driven registers
      
      always @(posedge PCLK or negedge PRESETN)
      begin: store_bfm_reg
         if (PRESETN == 1'b0)
            GPIO_IN <= 0;
         else 
         begin
            if (BFM_WR == 1'b1 & BFM_ADDR[31:0] == ADDR_IN)
               GPIO_IN <= BFM_DATA[IO_NUM - 1:0];
         end
      end
      
      // read back data from BFM registers
      assign BFM_DATA_i[IO_NUM - 1:0] = ((BFM_ADDR[31:0] == ADDR_IN)) ? GPIO_IN : 
                                        ((BFM_ADDR[31:0] == ADDR_OUT)) ? GPIO_OUT : 
                                        ((BFM_ADDR[31:0] == ADDR_INT)) ? INT : 
                                        ((BFM_ADDR[31:0] == ADDR_OE)) ? GPIO_OE : 
                                        {IO_NUM{1'bx}};

      generate
        if (IO_NUM < 32)
        begin
          assign BFM_DATA_i[31:IO_NUM] = 0;
        end
      endgenerate
      
      // tristate during a write
      assign BFM_DATA = ((BFM_WR == 1'b0)) ? BFM_DATA_i : 
                        {IO_NUM{1'bz}};
      
      // End BFM register interface RTL
      // ------------------------------------------------------
      
      // BFM instantiation
      
      // passing testbench parameters to BFM ARGVALUE* parameters
      BFM_APB #(.VECTFILE(APB_MASTER_VECTFILE), .TPD(TPD), .ARGVALUE0(IO_NUM), .ARGVALUE1(APB_WIDTH), .ARGVALUE2(OE_TYPE), .ARGVALUE3(INT_BUS), .ARGVALUE4(FIXED_CONFIG_0), .ARGVALUE5(FIXED_CONFIG_1), .ARGVALUE6(FIXED_CONFIG_2), .ARGVALUE7(FIXED_CONFIG_3), .ARGVALUE8(FIXED_CONFIG_4), .ARGVALUE9(FIXED_CONFIG_5), .ARGVALUE10(FIXED_CONFIG_6), .ARGVALUE11(FIXED_CONFIG_7), .ARGVALUE12(FIXED_CONFIG_8), .ARGVALUE13(FIXED_CONFIG_9), .ARGVALUE14(FIXED_CONFIG_10), .ARGVALUE15(FIXED_CONFIG_11), .ARGVALUE16(FIXED_CONFIG_12), .ARGVALUE17(FIXED_CONFIG_13), .ARGVALUE18(FIXED_CONFIG_14), .ARGVALUE19(FIXED_CONFIG_15), .ARGVALUE20(FIXED_CONFIG_16), .ARGVALUE21(FIXED_CONFIG_17), .ARGVALUE22(FIXED_CONFIG_18), .ARGVALUE23(FIXED_CONFIG_19), .ARGVALUE24(FIXED_CONFIG_20), .ARGVALUE25(FIXED_CONFIG_21), .ARGVALUE26(FIXED_CONFIG_22), .ARGVALUE27(FIXED_CONFIG_23), .ARGVALUE28(FIXED_CONFIG_24), .ARGVALUE29(FIXED_CONFIG_25), .ARGVALUE30(FIXED_CONFIG_26), .ARGVALUE31(FIXED_CONFIG_27), .ARGVALUE32(FIXED_CONFIG_28), .ARGVALUE33(FIXED_CONFIG_29), .ARGVALUE34(FIXED_CONFIG_30), .ARGVALUE35(FIXED_CONFIG_31), .ARGVALUE36(IO_TYPE_0), .ARGVALUE37(IO_TYPE_1), .ARGVALUE38(IO_TYPE_2), .ARGVALUE39(IO_TYPE_3), .ARGVALUE40(IO_TYPE_4), .ARGVALUE41(IO_TYPE_5), .ARGVALUE42(IO_TYPE_6), .ARGVALUE43(IO_TYPE_7), .ARGVALUE44(IO_TYPE_8), .ARGVALUE45(IO_TYPE_9), .ARGVALUE46(IO_TYPE_10), .ARGVALUE47(IO_TYPE_11), .ARGVALUE48(IO_TYPE_12), .ARGVALUE49(IO_TYPE_13), .ARGVALUE50(IO_TYPE_14), .ARGVALUE51(IO_TYPE_15), .ARGVALUE52(IO_TYPE_16), .ARGVALUE53(IO_TYPE_17), .ARGVALUE54(IO_TYPE_18), .ARGVALUE55(IO_TYPE_19), .ARGVALUE56(IO_TYPE_20), .ARGVALUE57(IO_TYPE_21), .ARGVALUE58(IO_TYPE_22), .ARGVALUE59(IO_TYPE_23), .ARGVALUE60(IO_TYPE_24), .ARGVALUE61(IO_TYPE_25), .ARGVALUE62(IO_TYPE_26), .ARGVALUE63(IO_TYPE_27), .ARGVALUE64(IO_TYPE_28), .ARGVALUE65(IO_TYPE_29), .ARGVALUE66(IO_TYPE_30), .ARGVALUE67(IO_TYPE_31), .ARGVALUE68(IO_INT_TYPE_0), .ARGVALUE69(IO_INT_TYPE_1), .ARGVALUE70(IO_INT_TYPE_2), .ARGVALUE71(IO_INT_TYPE_3), .ARGVALUE72(IO_INT_TYPE_4), .ARGVALUE73(IO_INT_TYPE_5), .ARGVALUE74(IO_INT_TYPE_6), .ARGVALUE75(IO_INT_TYPE_7), .ARGVALUE76(IO_INT_TYPE_8), .ARGVALUE77(IO_INT_TYPE_9), .ARGVALUE78(IO_INT_TYPE_10), .ARGVALUE79(IO_INT_TYPE_11), .ARGVALUE80(IO_INT_TYPE_12), .ARGVALUE81(IO_INT_TYPE_13), .ARGVALUE82(IO_INT_TYPE_14), .ARGVALUE83(IO_INT_TYPE_15), .ARGVALUE84(IO_INT_TYPE_16), .ARGVALUE85(IO_INT_TYPE_17), .ARGVALUE86(IO_INT_TYPE_18), .ARGVALUE87(IO_INT_TYPE_19), .ARGVALUE88(IO_INT_TYPE_20), .ARGVALUE89(IO_INT_TYPE_21), .ARGVALUE90(IO_INT_TYPE_22), .ARGVALUE91(IO_INT_TYPE_23), .ARGVALUE92(IO_INT_TYPE_24), .ARGVALUE93(IO_INT_TYPE_25), .ARGVALUE94(IO_INT_TYPE_26), .ARGVALUE95(IO_INT_TYPE_27), .ARGVALUE96(IO_INT_TYPE_28), .ARGVALUE97(IO_INT_TYPE_29), .ARGVALUE98(IO_INT_TYPE_30), .ARGVALUE99(IO_INT_TYPE_31)) U_APB_MASTER(
         .SYSCLK(SYSCLK_apb),
         .SYSRSTN(SYSRSTN_apb),
         .PCLK(PCLK),
         .PRESETN(PRESETN),
         .PADDR(PADDR_apb_bfm_wide),
         .PSEL(PSEL_apb_bfm_wide),
         .PENABLE(PENABLE),
         .PWRITE(PWRITE),
         .PWDATA(PWDATA_apb_bfm_wide),
         .PRDATA(PRDATA_apb_bfm_wide),
         .PREADY(PREADY),
         .PSLVERR(PSLVERR),
         .INTERRUPT(GND256),
         // NOT USING GPIO INTERFACE, ONLY
         // EXTERNAL MEMORY INTERFACE
         .GP_OUT(GP_OUT_apb_bfm),
         .GP_IN(GND32),
         .EXT_WR(BFM_WR),
         .EXT_RD(BFM_RD),
         .EXT_ADDR(BFM_ADDR),
         .EXT_DATA(BFM_DATA),
         .EXT_WAIT(GND1),
         .FINISHED(FINISHED_apb_bfm),
         .FAILED(FAILED_apb_bfm)
      );
      
      // DUT
      
      // DO NOT ASSIGN IO_VAL FOR USER TESTBENCH
      CoreGPIO #(.IO_NUM(IO_NUM), .APB_WIDTH(APB_WIDTH), .OE_TYPE(OE_TYPE), .INT_BUS(INT_BUS), .FIXED_CONFIG_0(FIXED_CONFIG_0), .FIXED_CONFIG_1(FIXED_CONFIG_1), .FIXED_CONFIG_2(FIXED_CONFIG_2), .FIXED_CONFIG_3(FIXED_CONFIG_3), .FIXED_CONFIG_4(FIXED_CONFIG_4), .FIXED_CONFIG_5(FIXED_CONFIG_5), .FIXED_CONFIG_6(FIXED_CONFIG_6), .FIXED_CONFIG_7(FIXED_CONFIG_7), .FIXED_CONFIG_8(FIXED_CONFIG_8), .FIXED_CONFIG_9(FIXED_CONFIG_9), .FIXED_CONFIG_10(FIXED_CONFIG_10), .FIXED_CONFIG_11(FIXED_CONFIG_11), .FIXED_CONFIG_12(FIXED_CONFIG_12), .FIXED_CONFIG_13(FIXED_CONFIG_13), .FIXED_CONFIG_14(FIXED_CONFIG_14), .FIXED_CONFIG_15(FIXED_CONFIG_15), .FIXED_CONFIG_16(FIXED_CONFIG_16), .FIXED_CONFIG_17(FIXED_CONFIG_17), .FIXED_CONFIG_18(FIXED_CONFIG_18), .FIXED_CONFIG_19(FIXED_CONFIG_19), .FIXED_CONFIG_20(FIXED_CONFIG_20), .FIXED_CONFIG_21(FIXED_CONFIG_21), .FIXED_CONFIG_22(FIXED_CONFIG_22), .FIXED_CONFIG_23(FIXED_CONFIG_23), .FIXED_CONFIG_24(FIXED_CONFIG_24), .FIXED_CONFIG_25(FIXED_CONFIG_25), .FIXED_CONFIG_26(FIXED_CONFIG_26), .FIXED_CONFIG_27(FIXED_CONFIG_27), .FIXED_CONFIG_28(FIXED_CONFIG_28), .FIXED_CONFIG_29(FIXED_CONFIG_29), .FIXED_CONFIG_30(FIXED_CONFIG_30), .FIXED_CONFIG_31(FIXED_CONFIG_31), .IO_TYPE_0(IO_TYPE_0), .IO_TYPE_1(IO_TYPE_1), .IO_TYPE_2(IO_TYPE_2), .IO_TYPE_3(IO_TYPE_3), .IO_TYPE_4(IO_TYPE_4), .IO_TYPE_5(IO_TYPE_5), .IO_TYPE_6(IO_TYPE_6), .IO_TYPE_7(IO_TYPE_7), .IO_TYPE_8(IO_TYPE_8), .IO_TYPE_9(IO_TYPE_9), .IO_TYPE_10(IO_TYPE_10), .IO_TYPE_11(IO_TYPE_11), .IO_TYPE_12(IO_TYPE_12), .IO_TYPE_13(IO_TYPE_13), .IO_TYPE_14(IO_TYPE_14), .IO_TYPE_15(IO_TYPE_15), .IO_TYPE_16(IO_TYPE_16), .IO_TYPE_17(IO_TYPE_17), .IO_TYPE_18(IO_TYPE_18), .IO_TYPE_19(IO_TYPE_19), .IO_TYPE_20(IO_TYPE_20), .IO_TYPE_21(IO_TYPE_21), .IO_TYPE_22(IO_TYPE_22), .IO_TYPE_23(IO_TYPE_23), .IO_TYPE_24(IO_TYPE_24), .IO_TYPE_25(IO_TYPE_25), .IO_TYPE_26(IO_TYPE_26), .IO_TYPE_27(IO_TYPE_27), .IO_TYPE_28(IO_TYPE_28), .IO_TYPE_29(IO_TYPE_29), .IO_TYPE_30(IO_TYPE_30), .IO_TYPE_31(IO_TYPE_31), .IO_INT_TYPE_0(IO_INT_TYPE_0), .IO_INT_TYPE_1(IO_INT_TYPE_1), .IO_INT_TYPE_2(IO_INT_TYPE_2), .IO_INT_TYPE_3(IO_INT_TYPE_3), .IO_INT_TYPE_4(IO_INT_TYPE_4), .IO_INT_TYPE_5(IO_INT_TYPE_5), .IO_INT_TYPE_6(IO_INT_TYPE_6), .IO_INT_TYPE_7(IO_INT_TYPE_7), .IO_INT_TYPE_8(IO_INT_TYPE_8), .IO_INT_TYPE_9(IO_INT_TYPE_9), .IO_INT_TYPE_10(IO_INT_TYPE_10), .IO_INT_TYPE_11(IO_INT_TYPE_11), .IO_INT_TYPE_12(IO_INT_TYPE_12), .IO_INT_TYPE_13(IO_INT_TYPE_13), .IO_INT_TYPE_14(IO_INT_TYPE_14), .IO_INT_TYPE_15(IO_INT_TYPE_15), .IO_INT_TYPE_16(IO_INT_TYPE_16), .IO_INT_TYPE_17(IO_INT_TYPE_17), .IO_INT_TYPE_18(IO_INT_TYPE_18), .IO_INT_TYPE_19(IO_INT_TYPE_19), .IO_INT_TYPE_20(IO_INT_TYPE_20), .IO_INT_TYPE_21(IO_INT_TYPE_21), .IO_INT_TYPE_22(IO_INT_TYPE_22), .IO_INT_TYPE_23(IO_INT_TYPE_23), .IO_INT_TYPE_24(IO_INT_TYPE_24), .IO_INT_TYPE_25(IO_INT_TYPE_25), .IO_INT_TYPE_26(IO_INT_TYPE_26), .IO_INT_TYPE_27(IO_INT_TYPE_27), .IO_INT_TYPE_28(IO_INT_TYPE_28), .IO_INT_TYPE_29(IO_INT_TYPE_29), .IO_INT_TYPE_30(IO_INT_TYPE_30), .IO_INT_TYPE_31(IO_INT_TYPE_31)) DUT(
         .PRESETN(PRESETN),
         .PCLK(PCLK),
         .PSEL(PSEL),
         .PENABLE(PENABLE),
         .PWRITE(PWRITE),
         .PADDR(PADDR),
         .PWDATA(PWDATA),
         .PRDATA(PRDATA),
         .PREADY(PREADY),
         .PSLVERR(PSLVERR),
         .INT(INT),
         .INT_OR(INT_OR),
         .GPIO_IN(GPIO_IN),
         .GPIO_OUT(GPIO_OUT),
         .GPIO_OE(GPIO_OE)
         
      );
      
endmodule

// testbench
