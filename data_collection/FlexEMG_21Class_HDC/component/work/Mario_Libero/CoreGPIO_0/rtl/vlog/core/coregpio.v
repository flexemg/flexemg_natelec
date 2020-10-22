`timescale 1 ns / 1 ns

// ********************************************************************/ 
// Actel Corporation Proprietary and Confidential
// Copyright 2007 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// Description: CoreGPIO
//                      
//
// Revision Information:
// Date     Description
// Mar09  Initial Release 
//
// SVN Revision Information:
// SVN $Revision:  $
// SVN $Date $
//

module Mario_Libero_CoreGPIO_0_CoreGPIO(
   PRESETN,
   PCLK,
   PSEL,
   PENABLE,
   PWRITE,
   PSLVERR,
   PREADY,
   PADDR,
   PWDATA,
   PRDATA,
   INT,
   INT_OR,
   GPIO_IN,
   GPIO_OUT,
   GPIO_OE
);
  // parameter              FAMILY = 17;
   parameter              IO_NUM = 32;
   parameter              APB_WIDTH = 32;
   parameter [0:0]        OE_TYPE = 0;
   parameter [0:0]        INT_BUS = 0;
   parameter [0:0]        FIXED_CONFIG_0 = 0;
   parameter [0:0]        FIXED_CONFIG_1 = 0;
   parameter [0:0]        FIXED_CONFIG_2 = 0;
   parameter [0:0]        FIXED_CONFIG_3 = 0;
   parameter [0:0]        FIXED_CONFIG_4 = 0;
   parameter [0:0]        FIXED_CONFIG_5 = 0;
   parameter [0:0]        FIXED_CONFIG_6 = 0;
   parameter [0:0]        FIXED_CONFIG_7 = 0;
   parameter [0:0]        FIXED_CONFIG_8 = 0;
   parameter [0:0]        FIXED_CONFIG_9 = 0;
   parameter [0:0]        FIXED_CONFIG_10 = 0;
   parameter [0:0]        FIXED_CONFIG_11 = 0;
   parameter [0:0]        FIXED_CONFIG_12 = 0;
   parameter [0:0]        FIXED_CONFIG_13 = 0;
   parameter [0:0]        FIXED_CONFIG_14 = 0;
   parameter [0:0]        FIXED_CONFIG_15 = 0;
   parameter [0:0]        FIXED_CONFIG_16 = 0;
   parameter [0:0]        FIXED_CONFIG_17 = 0;
   parameter [0:0]        FIXED_CONFIG_18 = 0;
   parameter [0:0]        FIXED_CONFIG_19 = 0;
   parameter [0:0]        FIXED_CONFIG_20 = 0;
   parameter [0:0]        FIXED_CONFIG_21 = 0;
   parameter [0:0]        FIXED_CONFIG_22 = 0;
   parameter [0:0]        FIXED_CONFIG_23 = 0;
   parameter [0:0]        FIXED_CONFIG_24 = 0;
   parameter [0:0]        FIXED_CONFIG_25 = 0;
   parameter [0:0]        FIXED_CONFIG_26 = 0;
   parameter [0:0]        FIXED_CONFIG_27 = 0;
   parameter [0:0]        FIXED_CONFIG_28 = 0;
   parameter [0:0]        FIXED_CONFIG_29 = 0;
   parameter [0:0]        FIXED_CONFIG_30 = 0;
   parameter [0:0]        FIXED_CONFIG_31 = 0;
   parameter [1:0]        IO_TYPE_0 = 0;
   parameter [1:0]        IO_TYPE_1 = 0;
   parameter [1:0]        IO_TYPE_2 = 0;
   parameter [1:0]        IO_TYPE_3 = 0;
   parameter [1:0]        IO_TYPE_4 = 0;
   parameter [1:0]        IO_TYPE_5 = 0;
   parameter [1:0]        IO_TYPE_6 = 0;
   parameter [1:0]        IO_TYPE_7 = 0;
   parameter [1:0]        IO_TYPE_8 = 0;
   parameter [1:0]        IO_TYPE_9 = 0;
   parameter [1:0]        IO_TYPE_10 = 0;
   parameter [1:0]        IO_TYPE_11 = 0;
   parameter [1:0]        IO_TYPE_12 = 0;
   parameter [1:0]        IO_TYPE_13 = 0;
   parameter [1:0]        IO_TYPE_14 = 0;
   parameter [1:0]        IO_TYPE_15 = 0;
   parameter [1:0]        IO_TYPE_16 = 0;
   parameter [1:0]        IO_TYPE_17 = 0;
   parameter [1:0]        IO_TYPE_18 = 0;
   parameter [1:0]        IO_TYPE_19 = 0;
   parameter [1:0]        IO_TYPE_20 = 0;
   parameter [1:0]        IO_TYPE_21 = 0;
   parameter [1:0]        IO_TYPE_22 = 0;
   parameter [1:0]        IO_TYPE_23 = 0;
   parameter [1:0]        IO_TYPE_24 = 0;
   parameter [1:0]        IO_TYPE_25 = 0;
   parameter [1:0]        IO_TYPE_26 = 0;
   parameter [1:0]        IO_TYPE_27 = 0;
   parameter [1:0]        IO_TYPE_28 = 0;
   parameter [1:0]        IO_TYPE_29 = 0;
   parameter [1:0]        IO_TYPE_30 = 0;
   parameter [1:0]        IO_TYPE_31 = 0;
   parameter [2:0]        IO_INT_TYPE_0 = 0;
   parameter [2:0]        IO_INT_TYPE_1 = 0;
   parameter [2:0]        IO_INT_TYPE_2 = 0;
   parameter [2:0]        IO_INT_TYPE_3 = 0;
   parameter [2:0]        IO_INT_TYPE_4 = 0;
   parameter [2:0]        IO_INT_TYPE_5 = 0;
   parameter [2:0]        IO_INT_TYPE_6 = 0;
   parameter [2:0]        IO_INT_TYPE_7 = 0;
   parameter [2:0]        IO_INT_TYPE_8 = 0;
   parameter [2:0]        IO_INT_TYPE_9 = 0;
   parameter [2:0]        IO_INT_TYPE_10 = 0;
   parameter [2:0]        IO_INT_TYPE_11 = 0;
   parameter [2:0]        IO_INT_TYPE_12 = 0;
   parameter [2:0]        IO_INT_TYPE_13 = 0;
   parameter [2:0]        IO_INT_TYPE_14 = 0;
   parameter [2:0]        IO_INT_TYPE_15 = 0;
   parameter [2:0]        IO_INT_TYPE_16 = 0;
   parameter [2:0]        IO_INT_TYPE_17 = 0;
   parameter [2:0]        IO_INT_TYPE_18 = 0;
   parameter [2:0]        IO_INT_TYPE_19 = 0;
   parameter [2:0]        IO_INT_TYPE_20 = 0;
   parameter [2:0]        IO_INT_TYPE_21 = 0;
   parameter [2:0]        IO_INT_TYPE_22 = 0;
   parameter [2:0]        IO_INT_TYPE_23 = 0;
   parameter [2:0]        IO_INT_TYPE_24 = 0;
   parameter [2:0]        IO_INT_TYPE_25 = 0;
   parameter [2:0]        IO_INT_TYPE_26 = 0;
   parameter [2:0]        IO_INT_TYPE_27 = 0;
   parameter [2:0]        IO_INT_TYPE_28 = 0;
   parameter [2:0]        IO_INT_TYPE_29 = 0;
   parameter [2:0]        IO_INT_TYPE_30 = 0;
   parameter [2:0]        IO_INT_TYPE_31 = 0;
   parameter [0:0]        IO_VAL_0 = 0;
   parameter [0:0]        IO_VAL_1 = 0;
   parameter [0:0]        IO_VAL_2 = 0;
   parameter [0:0]        IO_VAL_3 = 0;
   parameter [0:0]        IO_VAL_4 = 0;
   parameter [0:0]        IO_VAL_5 = 0;
   parameter [0:0]        IO_VAL_6 = 0;
   parameter [0:0]        IO_VAL_7 = 0;
   parameter [0:0]        IO_VAL_8 = 0;
   parameter [0:0]        IO_VAL_9 = 0;
   parameter [0:0]        IO_VAL_10 = 0;
   parameter [0:0]        IO_VAL_11 = 0;
   parameter [0:0]        IO_VAL_12 = 0;
   parameter [0:0]        IO_VAL_13 = 0;
   parameter [0:0]        IO_VAL_14 = 0;
   parameter [0:0]        IO_VAL_15 = 0;
   parameter [0:0]        IO_VAL_16 = 0;
   parameter [0:0]        IO_VAL_17 = 0;
   parameter [0:0]        IO_VAL_18 = 0;
   parameter [0:0]        IO_VAL_19 = 0;
   parameter [0:0]        IO_VAL_20 = 0;
   parameter [0:0]        IO_VAL_21 = 0;
   parameter [0:0]        IO_VAL_22 = 0;
   parameter [0:0]        IO_VAL_23 = 0;
   parameter [0:0]        IO_VAL_24 = 0;
   parameter [0:0]        IO_VAL_25 = 0;
   parameter [0:0]        IO_VAL_26 = 0;
   parameter [0:0]        IO_VAL_27 = 0;
   parameter [0:0]        IO_VAL_28 = 0;
   parameter [0:0]        IO_VAL_29 = 0;
   parameter [0:0]        IO_VAL_30 = 0;
   parameter [0:0]        IO_VAL_31 = 0;
  // parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;
   input                  PRESETN;
   input                  PCLK;
   input                  PSEL;
   input                  PENABLE;
   input                  PWRITE;
   output                 PSLVERR;
   output                 PREADY;
   input [7:0]            PADDR;
   input [APB_WIDTH-1:0]  PWDATA;
   output [APB_WIDTH-1:0] PRDATA;
   output [IO_NUM-1:0]    INT;
   output                 INT_OR;
   input [IO_NUM-1:0]     GPIO_IN;
   output [IO_NUM-1:0]    GPIO_OUT;
   output [IO_NUM-1:0]    GPIO_OE;
   
   // ----------------------------------------------------------------------
   // CONSTANTS
   // ----------------------------------------------------------------------
   // FIXED_CONFIG
   // 1 = FIXED
   // 0 = REGISTER-CONTROLLED
   parameter [0:31]       FIXED_CONFIG = ({FIXED_CONFIG_0, FIXED_CONFIG_1, FIXED_CONFIG_2, FIXED_CONFIG_3, FIXED_CONFIG_4, FIXED_CONFIG_5, FIXED_CONFIG_6, FIXED_CONFIG_7, FIXED_CONFIG_8, FIXED_CONFIG_9, FIXED_CONFIG_10, FIXED_CONFIG_11, FIXED_CONFIG_12, FIXED_CONFIG_13, FIXED_CONFIG_14, FIXED_CONFIG_15, FIXED_CONFIG_16, FIXED_CONFIG_17, FIXED_CONFIG_18, FIXED_CONFIG_19, FIXED_CONFIG_20, FIXED_CONFIG_21, FIXED_CONFIG_22, FIXED_CONFIG_23, FIXED_CONFIG_24, FIXED_CONFIG_25, FIXED_CONFIG_26, FIXED_CONFIG_27, FIXED_CONFIG_28, FIXED_CONFIG_29, FIXED_CONFIG_30, FIXED_CONFIG_31});
   
   // IO_INT_TYPE
   // 3'b000 = LEVEL HIGH
   // 3'b001 = LEVEL LOW
   // 3'b010 = EDGE POS
   // 3'b011 = EDGE_NEG
   // 3'b100 = EDGE_BOTH
   // 3'b111 = DISABLED
   parameter [0:95]       IO_INT_TYPE = ({IO_INT_TYPE_0, IO_INT_TYPE_1, IO_INT_TYPE_2, IO_INT_TYPE_3, IO_INT_TYPE_4, IO_INT_TYPE_5, IO_INT_TYPE_6, IO_INT_TYPE_7, IO_INT_TYPE_8, IO_INT_TYPE_9, IO_INT_TYPE_10, IO_INT_TYPE_11, IO_INT_TYPE_12, IO_INT_TYPE_13, IO_INT_TYPE_14, IO_INT_TYPE_15, IO_INT_TYPE_16, IO_INT_TYPE_17, IO_INT_TYPE_18, IO_INT_TYPE_19, IO_INT_TYPE_20, IO_INT_TYPE_21, IO_INT_TYPE_22, IO_INT_TYPE_23, IO_INT_TYPE_24, IO_INT_TYPE_25, IO_INT_TYPE_26, IO_INT_TYPE_27, IO_INT_TYPE_28, IO_INT_TYPE_29, IO_INT_TYPE_30, IO_INT_TYPE_31});
   
   // IO_TYPE
   // 2'b00 = Input
   // 2'b01 = Output
   // 2'b10 = Both  
   parameter [0:63]       IO_TYPE = ({IO_TYPE_0, IO_TYPE_1, IO_TYPE_2, IO_TYPE_3, IO_TYPE_4, IO_TYPE_5, IO_TYPE_6, IO_TYPE_7, IO_TYPE_8, IO_TYPE_9, IO_TYPE_10, IO_TYPE_11, IO_TYPE_12, IO_TYPE_13, IO_TYPE_14, IO_TYPE_15, IO_TYPE_16, IO_TYPE_17, IO_TYPE_18, IO_TYPE_19, IO_TYPE_20, IO_TYPE_21, IO_TYPE_22, IO_TYPE_23, IO_TYPE_24, IO_TYPE_25, IO_TYPE_26, IO_TYPE_27, IO_TYPE_28, IO_TYPE_29, IO_TYPE_30, IO_TYPE_31});
   
   // IO_VAL
   // Bit value each bit at reset, 1 or 0
   parameter [0:31]       IO_VAL = ({IO_VAL_0, IO_VAL_1, IO_VAL_2, IO_VAL_3, IO_VAL_4, IO_VAL_5, IO_VAL_6, IO_VAL_7, IO_VAL_8, IO_VAL_9, IO_VAL_10, IO_VAL_11, IO_VAL_12, IO_VAL_13, IO_VAL_14, IO_VAL_15, IO_VAL_16, IO_VAL_17, IO_VAL_18, IO_VAL_19, IO_VAL_20, IO_VAL_21, IO_VAL_22, IO_VAL_23, IO_VAL_24, IO_VAL_25, IO_VAL_26, IO_VAL_27, IO_VAL_28, IO_VAL_29, IO_VAL_30, IO_VAL_31});
   
   reg [7:0]             CONFIG_reg[0:IO_NUM-1];
   // AS: 05/06/2009
   // Change from wire to reg before obfuscation, and change back
   // to wire afterwards (as well as the obfuscated file)
   // wire [7:0]            CONFIG_wire[0:IO_NUM-1];
   reg [31:0]            CONFIG_reg_o;
   reg [32-1:0]          INTR_reg;
   reg [32-1:0]          GPOUT_reg;
   wire [32-1:0]          GPIN_reg;
   wire [IO_NUM-1:0]      GPIO_OUT_i;
   wire [IO_NUM-1:0]      GPIO_OE_i;
   wire [APB_WIDTH-1:0]   PRDATA_o;
   
   reg [IO_NUM-1:0]       gpin1;
   reg [IO_NUM-1:0]       gpin2;
   reg [IO_NUM-1:0]       gpin3;
   reg [IO_NUM-1:0]       edge_pos;
   reg [IO_NUM-1:0]       edge_both;
   reg [IO_NUM-1:0]       edge_neg;
   wire [IO_NUM-1:0]      gpin2m;
   wire [IO_NUM-1:0]      level_low;
   wire [IO_NUM-1:0]      level_high;
   wire [IO_NUM-1:0]      intr;
   wire [IO_NUM-1:0]      intp;
   
   wire [31:0]            PADDR_INT;
   wire [5:0]             PADDR_TOP;
   
   wire GND1;
   wire [7:0] GND8;
   
   wire aresetn;
   wire sresetn; 
   
   assign aresetn = PRESETN;  //(SYNC_RESET==1) ? 1'b1 : PRESETN;
   assign sresetn = 1'b1; //(SYNC_RESET==1) ? PRESETN : 1'b1;
   
   assign GND1 = 1'b0;
   assign GND8 = 8'h00;
   
   assign PSLVERR = 1'b0;
   assign PREADY = 1'b1;
   assign PRDATA[APB_WIDTH - 1:0] = PRDATA_o[APB_WIDTH - 1:0];
   
   
    generate
      if (INT_BUS == 1) 
        assign INT_OR =| intr;
      else
        assign INT_OR = 1'b0;
    endgenerate
   
   generate
      if (IO_NUM < 32)
      begin : COND_GEN_NON_BITS
        genvar J;
        for (J = IO_NUM; J <= 31; J = J + 1)
        begin: GEN_NON_BITS
             assign GPIN_reg[J] = 1'b0;
             always@*
             begin
              GPOUT_reg[J] <= GND1;
              INTR_reg[J] <= GND1;
             end
        end
      end
   endgenerate
   
   generate
      begin : xhdl1
         genvar                 I;
         for (I = 0; I <= (IO_NUM - 1); I = I + 1)
         begin : GEN_BITS
            
            // ---------------------------------------------------
            // width-independent code
            // ---------------------------------------------------
            
            // combinatorial assignments
            assign gpin2m[I] = gpin2[I];
            assign level_high[I] = gpin3[I];
            assign level_low[I] = (~gpin3[I]);
            assign INT[I] = intr[I];
            assign GPIO_OE = GPIO_OE_i;
            
            // 2-wide input buffer
            
            always @(posedge PCLK or negedge aresetn)
               if ((!aresetn) || (!sresetn))
               begin
                  gpin1[I] <= 1'b0;
                  gpin2[I] <= 1'b0;
               end
               else 
               begin
                  gpin1[I] <= GPIO_IN[I];
                  gpin2[I] <= gpin1[I];
               end
            
            
            always @(posedge PCLK or negedge aresetn)
               if ((!aresetn) || (!sresetn))
                  gpin3[I] <= 1'b0;
               else 
                  gpin3[I] <= gpin2m[I];
            
            // interrupt register assignment
            if (FIXED_CONFIG[I] == 1'b0)
            begin : REG_INT
               assign intp[I] = ((CONFIG_reg[I][7:5] == 3'b000)) ? level_high[I] : 
                                ((CONFIG_reg[I][7:5] == 3'b001)) ? level_low[I] : 
                                ((CONFIG_reg[I][7:5] == 3'b010)) ? edge_pos[I] : 
                                ((CONFIG_reg[I][7:5] == 3'b011)) ? edge_neg[I] : 
                                ((CONFIG_reg[I][7:5] == 3'b100)) ? edge_both[I] : 
                                1'b0;
               assign intr[I] = ((CONFIG_reg[I][3] == 1'b1)) ? intp[I] : 
                                1'b0;
            end
         
         if (FIXED_CONFIG[I] == 1'b1)
         begin : FIXED_INT
            assign intp[I] = ((IO_INT_TYPE[3 * I:3 * I + 2] == 3'b000)) ? level_high[I] : 
                             ((IO_INT_TYPE[3 * I:3 * I + 2] == 3'b001)) ? level_low[I] : 
                             ((IO_INT_TYPE[3 * I:3 * I + 2] == 3'b010)) ? edge_pos[I] : 
                             ((IO_INT_TYPE[3 * I:3 * I + 2] == 3'b011)) ? edge_neg[I] : 
                             ((IO_INT_TYPE[3 * I:3 * I + 2] == 3'b100)) ? edge_both[I] : 
                             1'b0;
            assign intr[I] = ((IO_INT_TYPE[3 * I:3 * I + 2] != 3'b111)) ? intp[I] : 
                             1'b0;
         end
      
      if (FIXED_CONFIG[I] == 1'b0)
      begin : REG_GPIN
         assign GPIN_reg[I] = ((CONFIG_reg[I][1] == 1'b1)) ? gpin3[I] : 
                              1'b0;
      end
   
   if (FIXED_CONFIG[I] == 1'b1)
   begin : FIXED_GPIN
      assign GPIN_reg[I] = ((IO_TYPE[2 * I:2 * I + 1] != 2'b01)) ? gpin3[I] : 
                           1'b0;
   end

if (FIXED_CONFIG[I] == 1'b0)
begin : REG_GPOUT
   assign GPIO_OUT_i[I] = ((CONFIG_reg[I][0] == 1'b1)) ? GPOUT_reg[I] : 
                          1'b0;
   // AS: 20Jul09, added output register condition for OE signal
   assign GPIO_OE_i[I] = ((CONFIG_reg[I][2] == 1'b1) &&
                          (CONFIG_reg[I][0] == 1'b1)) ? 1'b1 : 1'b0;
end

if (FIXED_CONFIG[I] == 1'b1)
begin : FIXED_GPOUT
assign GPIO_OUT_i[I] = ((IO_TYPE[2 * I:2 * I + 1] != 2'b00)) ? GPOUT_reg[I] : 
                       1'b0;
assign GPIO_OE_i[I] = 1'b1;
end

if (OE_TYPE == 0)
begin : OE_EXT
assign GPIO_OUT[I] = GPIO_OUT_i[I];
end

if (OE_TYPE == 1)
begin : OE_INT
assign GPIO_OUT[I] = ((GPIO_OE_i[I] == 1'b1)) ? GPIO_OUT_i[I] : 
                     1'bZ;
end


// APB Config registers
// only generated if fixed config for
// 'i' is disabled
if (FIXED_CONFIG[I] == 1'b0)
begin : REG_GEN
  always @(posedge PCLK or negedge aresetn)
  begin
    if ((!aresetn) || (!sresetn))
      CONFIG_reg[I][7:0] <= 8'h00;
    else 
    begin
      if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:2] == I))
        CONFIG_reg[I][7:0] <= PWDATA[7:0];
      else
        CONFIG_reg[I][7:0] <= CONFIG_reg[I][7:0];
    end
  end
end
else
begin
  //assign CONFIG_wire[I][7:0] = 8'h00;
  always@*
  begin
    CONFIG_reg[I][7:0] <= GND8;
  end
end

// ---------------------------------------------------
// width-dependent code
// ---------------------------------------------------

// 32-bit APB width 
if (APB_WIDTH == 32)
begin : APB_32
// positive edge

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_pos[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b010)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if ((gpin2m[I] == 1'b1) & ((~gpin3[I]) == 1'b1))
edge_pos[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I]));
else
edge_pos[I] <= edge_pos[I];
end
else
edge_pos[I] <= 1'b0;
end

// negative edge

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_neg[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b011)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if (((~gpin2m[I]) == 1'b1) & (gpin3[I] == 1'b1))
edge_neg[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I]));
else
edge_neg[I] <= edge_neg[I];
end
else
edge_neg[I] <= 1'b0;
end

// both edges

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_both[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b100)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if ((gpin2m[I] == 1'b1) ^ (gpin3[I] == 1'b1))
edge_both[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80))
edge_both[I] <= edge_both[I] & ((~PWDATA[I]));
else
edge_both[I] <= edge_both[I];
end
else
edge_both[I] <= 1'b0;
end

// interrupt register sequential logic

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
INTR_reg[I] <= 1'b0;
else 
begin
if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1))
case (PADDR[7:0])
8'h80 :
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I]));
default :
INTR_reg[I] <= intr[I];
endcase
else
INTR_reg[I] <= intr[I];
end

// GPOUT registers

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
GPOUT_reg[I] <= IO_VAL[I];
else 
begin
if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1))
case (PADDR[7:0])
8'hA0 :
GPOUT_reg[I] <= PWDATA[I];
default :
GPOUT_reg[I] <= GPOUT_reg[I];
endcase
else
GPOUT_reg[I] <= GPOUT_reg[I];
end
end

// APB_WIDTH = 32

// 16-bit APB width 
if (APB_WIDTH == 16)
begin : APB_16
// positive edge

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_pos[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b010)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if ((gpin2m[I] == 1'b1) & ((~gpin3[I]) == 1'b1))
edge_pos[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 16))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 16))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I - 16]));
else
edge_pos[I] <= edge_pos[I];
end
else
edge_pos[I] <= 1'b0;
end

// negative edge

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_neg[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b011)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if (((~gpin2m[I]) == 1'b1) & (gpin3[I] == 1'b1))
edge_neg[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 16))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 16))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I - 16]));
else
edge_neg[I] <= edge_neg[I];
end
else
edge_neg[I] <= 1'b0;
end

// both edges

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_both[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b100)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if ((gpin2m[I] == 1'b1) ^ (gpin3[I] == 1'b1))
edge_both[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 16))
edge_both[I] <= edge_both[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 16))
edge_both[I] <= edge_both[I] & ((~PWDATA[I - 16]));
else
edge_both[I] <= edge_both[I];
end
else
edge_both[I] <= 1'b0;
end

// interrupt register sequential logic

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
INTR_reg[I] <= 1'b0;
else 
begin
if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 16))
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 16))
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I - 16]));
else
INTR_reg[I] <= intr[I];
end

// GPOUT registers

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
GPOUT_reg[I] <= IO_VAL[I];
else 
begin
if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'hA0) & (I < 16))
GPOUT_reg[I] <= PWDATA[I];
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'hA4) & (I >= 16))
GPOUT_reg[I] <= PWDATA[I - 16];
else
GPOUT_reg[I] <= GPOUT_reg[I];
end
end

// APB_WIDTH = 16

// 8-bit APB width 
if (APB_WIDTH == 8)
begin : APB_8
// positive edge

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_pos[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b010)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if ((gpin2m[I] == 1'b1) & ((~gpin3[I]) == 1'b1))
edge_pos[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 8))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 8) & (I < 16))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I - 8]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h88) & (I >= 16) & (I < 24))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I - 16]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h8C) & (I >= 24))
edge_pos[I] <= edge_pos[I] & ((~PWDATA[I - 24]));
else
edge_pos[I] <= edge_pos[I];
end
else
edge_pos[I] <= 1'b0;
end

// negative edge

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_neg[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b011)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if (((~gpin2m[I]) == 1'b1) & (gpin3[I] == 1'b1))
edge_neg[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 8))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 8) & (I < 16))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I - 8]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h88) & (I >= 16) & (I < 24))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I - 16]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h8C) & (I >= 24))
edge_neg[I] <= edge_neg[I] & ((~PWDATA[I - 24]));
else
edge_neg[I] <= edge_neg[I];
end
else
edge_neg[I] <= 1'b0;
end

// both edges

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
edge_both[I] <= 1'b0;
else 
begin
if (((FIXED_CONFIG[I] == 1'b1) & (IO_INT_TYPE[(3 * I):(3 * I + 2)] == 3'b100)) | ((FIXED_CONFIG[I] == 1'b0) & (CONFIG_reg[I][3] == 1'b1)))
begin
if ((gpin2m[I] == 1'b1) ^ (gpin3[I] == 1'b1))
edge_both[I] <= 1'b1;
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 8))
edge_both[I] <= edge_both[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 8) & (I < 16))
edge_both[I] <= edge_both[I] & ((~PWDATA[I - 8]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h88) & (I >= 16) & (I < 24))
edge_both[I] <= edge_both[I] & ((~PWDATA[I - 16]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h8C) & (I >= 24))
edge_both[I] <= edge_both[I] & ((~PWDATA[I - 24]));
else
edge_both[I] <= edge_both[I];
end
else
edge_both[I] <= 1'b0;
end

// interrupt register sequential logic

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
INTR_reg[I] <= 1'b0;
else 
begin
if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h80) & (I < 8))
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h84) & (I >= 8) & (I < 16))
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I - 8]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h88) & (I >= 16) & (I < 24))
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I - 16]));
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'h8C) & (I >= 24))
INTR_reg[I] <= INTR_reg[I] & ((~PWDATA[I - 24]));
else
INTR_reg[I] <= intr[I];
end

// GPOUT registers

always @(posedge PCLK or negedge aresetn)
if ((!aresetn) || (!sresetn))
GPOUT_reg[I] <= IO_VAL[I];
else 
begin
if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'hA0) & (I < 8))
GPOUT_reg[I] <= PWDATA[I];
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'hA4) & (I >= 8) & (I < 16))
GPOUT_reg[I] <= PWDATA[I - 8];
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'hA8) & (I >= 16) & (I < 24))
GPOUT_reg[I] <= PWDATA[I - 16];
else if ((PSEL == 1'b1) & (PWRITE == 1'b1) & (PENABLE == 1'b1) & (PADDR[7:0] == 8'hAC) & (I >= 24))
GPOUT_reg[I] <= PWDATA[I - 24];
else
GPOUT_reg[I] <= GPOUT_reg[I];
end
end
end
end
endgenerate

// APB_WIDTH = 8

// bit i

assign PADDR_TOP[5:0] = PADDR[7:2];
assign PADDR_INT = PADDR_TOP;

always @ *
begin
if(PADDR_INT < IO_NUM)
begin
case (PADDR_INT)
0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 :
  CONFIG_reg_o[31:0] <= {1'b0,CONFIG_reg[PADDR_INT][7:0]};
default :
  CONFIG_reg_o[31:0] <= {32{1'b0}};
endcase
end
else
  CONFIG_reg_o[31:0] <= {32{1'b0}};
end

// Asynchronous APB read data (32-bit)
generate
if (APB_WIDTH == 32)
begin : RDATA_32

assign PRDATA_o[31:0] = ((PADDR[7:0] < 8'h80)) ? CONFIG_reg_o[31:0] : 
                        ((PADDR[7:0] == 8'h80)) ? INTR_reg[31:0] : 
                        ((PADDR[7:0] == 8'h90)) ? GPIN_reg[31:0] : 
                        ((PADDR[7:0] == 8'hA0)) ? GPOUT_reg[31:0] : 
                        32'h00000000;
end
endgenerate

// Asynchronous APB read data (16-bit)
generate
if (APB_WIDTH == 16)
begin : RDATA_16
assign PRDATA_o[15:0] = ((PADDR[7:0] < 8'h80)) ?  CONFIG_reg_o[15:0] : 
                        ((PADDR[7:0] == 8'h80)) ? INTR_reg[15:0] : 
                        ((PADDR[7:0] == 8'h84)) ? INTR_reg[31:16] : 
                        ((PADDR[7:0] == 8'h90)) ? GPIN_reg[15:0] : 
                        ((PADDR[7:0] == 8'h94)) ? GPIN_reg[31:16] : 
                        ((PADDR[7:0] == 8'hA0)) ? GPOUT_reg[15:0] : 
                        ((PADDR[7:0] == 8'hA4)) ? GPOUT_reg[31:16] : 
                        16'h0000;
end
endgenerate

// Asynchronous APB read data (8-bit)
generate
if (APB_WIDTH == 8)
begin : RDATA_8
assign PRDATA_o[7:0] = ((PADDR[7:0] < 8'h80)) ? CONFIG_reg_o[7:0] : 
                       ((PADDR[7:0] == 8'h80)) ? INTR_reg[7:0] : 
                       ((PADDR[7:0] == 8'h84)) ? INTR_reg[15:8] : 
                       ((PADDR[7:0] == 8'h88)) ? INTR_reg[23:16] : 
                       ((PADDR[7:0] == 8'h8C)) ? INTR_reg[31:24] : 
                       ((PADDR[7:0] == 8'h90)) ? GPIN_reg[7:0] : 
                       ((PADDR[7:0] == 8'h94)) ? GPIN_reg[15:8] : 
                       ((PADDR[7:0] == 8'h98)) ? GPIN_reg[23:16] : 
                       ((PADDR[7:0] == 8'h9C)) ? GPIN_reg[31:24] : 
                       ((PADDR[7:0] == 8'hA0)) ? GPOUT_reg[7:0] : 
                       ((PADDR[7:0] == 8'hA4)) ? GPOUT_reg[15:8] : 
                       ((PADDR[7:0] == 8'hA8)) ? GPOUT_reg[23:16] : 
                       ((PADDR[7:0] == 8'hAC)) ? GPOUT_reg[31:24] : 
                       8'h00;
end
endgenerate

endmodule

