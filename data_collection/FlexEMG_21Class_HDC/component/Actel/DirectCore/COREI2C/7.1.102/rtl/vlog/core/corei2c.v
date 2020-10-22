// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// file: corei2c.v
//
// Description: CoreI2C Wrapper
//
// SVN Revision Information:
// SVN $Revision: 24155 $
// SVN $Date: 2014-12-24 18:18:17 +0000 (Wed, 24 Dec 2014) $
//
// *********************************************************************/

`timescale 1 ns / 1 ns // timescale for following modules

module COREI2C #(
parameter FAMILY         			=17,
parameter OPERATING_MODE 			=0,
parameter BAUD_RATE_FIXED			=0,
parameter BAUD_RATE_VALUE			=3'b000,
parameter BCLK_ENABLED				=1,
parameter GLITCHREG_NUM				=3,
parameter SMB_EN         			=0,
parameter IPMI_EN					=1,
parameter FREQUENCY      			=30,
parameter FIXED_SLAVE0_ADDR_EN		=0,
parameter FIXED_SLAVE0_ADDR_VALUE	=8'h00,
parameter ADD_SLAVE1_ADDRESS_EN		=1,
parameter FIXED_SLAVE1_ADDR_EN		=0,
parameter FIXED_SLAVE1_ADDR_VALUE	=8'h00,
parameter I2C_NUM					=1
)(
//system globals
input  PRESETN,
input  PCLK,
input  BCLK,
//microcontroller IF
input  PSEL,
input  PENABLE,
input  PWRITE,
input  [8:0] PADDR,
input  [7:0] PWDATA,
output reg [7:0] PRDATA,
output [I2C_NUM-1:0] INT,
//serial IF signals
input  [I2C_NUM-1:0] SCLI,
input  [I2C_NUM-1:0] SDAI,
output [I2C_NUM-1:0] SCLO,
output [I2C_NUM-1:0] SDAO,
//optional signals
input  [I2C_NUM-1:0] SMBALERT_NI,
output [I2C_NUM-1:0] SMBALERT_NO,
output [I2C_NUM-1:0] SMBA_INT,
input  [I2C_NUM-1:0] SMBSUS_NI,
output [I2C_NUM-1:0] SMBSUS_NO,
output [I2C_NUM-1:0] SMBS_INT
   );

// Function to determine bit width of parameter-based buses:
  function [31:0] ceil_log2;
      input integer x;
      integer tmp, res;
    begin
      tmp = 1;
      res = 0;
      while (tmp < x) begin
        tmp = tmp * 2;
        res = res + 1;
      end
      ceil_log2 = res;
    end
  endfunction
//


// serADR   : 0C  : 00  :
parameter [4:0] serADR0_ID = 5'b01100;  // serADR location
parameter [7:0] serADR0_RV = 8'b00000000; // serADR reset


// serADR1   : 1C  : 00  :
parameter [4:0] serADR1_ID = 5'b11100;  // serADR location
parameter [7:0] serADR1_RV = 8'b00000000; // serADR reset

//------------------------------------------------------------------------------
// Sync/Async Reset
//------------------------------------------------------------------------------
parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;
wire aresetn;
wire sresetn;
assign aresetn = (SYNC_RESET==1) ? 1'b1 : PRESETN;
assign sresetn = (SYNC_RESET==1) ? PRESETN : 1'b1;

wire [0:I2C_NUM-1] PSELi ;
wire [ceil_log2(FREQUENCY * 215)-1:0] term_cnt_215us =  (FREQUENCY * 215);
reg  [ceil_log2(FREQUENCY * 215)-1:0] term_cnt_215us_reg;
wire pulse_215us;
reg   BCLK_ff0;         // baud rate clock flip flop 0
reg   BCLK_ff;          // baud rate clock flip flop
wire  BCLKe;            // baud rate clock edge detector

reg   [7:0] seradr0apb; // seradr0 APB register
wire  [7:0] seradr0;    // seradr0
reg   [7:0] seradr1apb; // seradr1 APB register
wire  [7:0] seradr1;    // seradr1
wire 		seradr1apb0;

wire [7:0] PRDATAi [0:I2C_NUM-1]; // This syntax is not supported by Verilog 2001.

assign seradr1apb0 = (ADD_SLAVE1_ADDRESS_EN==1)? seradr1apb[0]: 1'b0;

//COMMON COUNTER LOGIC
always @(posedge PCLK or negedge aresetn)
begin : term_cnt_215us_proc
if ((!aresetn) || (!sresetn))
   begin
   term_cnt_215us_reg <= 0 ;
   end
else
   begin
      if (term_cnt_215us_reg == 0)
      begin
      term_cnt_215us_reg <= term_cnt_215us;
      end
      else
      begin
      term_cnt_215us_reg <= term_cnt_215us_reg - 1;
      end
   end
end

assign pulse_215us = ((term_cnt_215us_reg == 0) && ((IPMI_EN==1)||(SMB_EN==1)))? 1'b1: 1'b0;

// COMMMON BCLK LOGIC:
//------------------------------------------------------------------
// BCLK edge detector
//------------------------------------------------------------------
always @(posedge PCLK or negedge aresetn)
begin : BCLK_ff_proc
//------------------------------------------------------------------
if ((!aresetn) || (!sresetn))
   //-----------------------------------
   // Synchronous reset
   //-----------------------------------
   begin
   BCLK_ff0 <= 1'b1 ;
   BCLK_ff  <= 1'b1 ;
   end
else
   //-----------------------------------
   // Synchronous write
   //-----------------------------------
   begin
   BCLK_ff0 <= BCLK ;
   BCLK_ff  <= BCLK_ff0 ;
   end
end

//------------------------------------------------------------------
// BCLK edge detector
//------------------------------------------------------------------
assign BCLKe = BCLK_ENABLED == 1 ? BCLK_ff0 & ~BCLK_ff : 1'b0; // risinge edge


// COMMON ADDRESS LOGIC:

//------------------------------------------------------------------
// seradr0 APB register
//------------------------------------------------------------------
generate
begin: g_seradr0_reg_bits
 if (FIXED_SLAVE0_ADDR_EN == 0)
 begin
   always @(posedge PCLK or negedge aresetn)
   begin : seradr0_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      		seradr0apb <= serADR0_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
      if ((PENABLE && PWRITE && PSEL) && (PADDR[4:0] == serADR0_ID))
         begin
          	seradr0apb <= PWDATA ;
         end
      end
   end
     assign seradr0 = seradr0apb;
 end
 else
 begin
     assign seradr0 = {FIXED_SLAVE0_ADDR_VALUE[6:0],1'b0};
 end
end
endgenerate

//------------------------------------------------------------------
// seradr1 APB register
//------------------------------------------------------------------
generate
begin: g_seradr1_reg_bits
 if ((FIXED_SLAVE1_ADDR_EN == 0) && (ADD_SLAVE1_ADDRESS_EN == 1))
 begin
   always @(posedge PCLK or negedge aresetn)
   begin : seradr1_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      		seradr1apb <= serADR1_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
      if ((PENABLE && PWRITE && PSEL) && (PADDR[4:0] == serADR1_ID))
         begin
          	seradr1apb <= PWDATA ;
         end
      end
   end
     assign seradr1 = seradr1apb;
 end
 else if((FIXED_SLAVE1_ADDR_EN == 1) && (ADD_SLAVE1_ADDRESS_EN == 1))
 begin
   always @(posedge PCLK or negedge aresetn)
   begin : seradr1_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      		seradr1apb <= {7'b0,serADR1_RV[0]} ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
      if ((PENABLE && PWRITE && PSEL) && (PADDR[4:0] == serADR1_ID))
         begin
          	seradr1apb <= {7'b0,PWDATA[0]} ;
         end
      end
   end
     assign seradr1 = {FIXED_SLAVE1_ADDR_VALUE[6:0],seradr1apb[0]};
 end
 else
 begin
     assign seradr1 = 8'b0;
 end
end
endgenerate


genvar z;
generate for (z=0; z<=(I2C_NUM-1); z=z+1)
begin: I2C_NUM_GENERATION
COREI2CREAL #(
.FAMILY         			(FAMILY         		),
.OPERATING_MODE 			(OPERATING_MODE 		),
.BAUD_RATE_FIXED			(BAUD_RATE_FIXED		),
.BAUD_RATE_VALUE			(BAUD_RATE_VALUE		),
.BCLK_ENABLED				(BCLK_ENABLED			),
.GLITCHREG_NUM				(GLITCHREG_NUM			),
.SMB_EN         			(SMB_EN         		),
.IPMI_EN					(IPMI_EN				),
.FREQUENCY      			(FREQUENCY      		),
.FIXED_SLAVE0_ADDR_EN		(FIXED_SLAVE0_ADDR_EN	),
.FIXED_SLAVE0_ADDR_VALUE	(FIXED_SLAVE0_ADDR_VALUE),
.ADD_SLAVE1_ADDRESS_EN		(ADD_SLAVE1_ADDRESS_EN	),
.FIXED_SLAVE1_ADDR_EN		(FIXED_SLAVE1_ADDR_EN	),
.FIXED_SLAVE1_ADDR_VALUE	(FIXED_SLAVE1_ADDR_VALUE)
)
ui2c
(
.pulse_215us(pulse_215us),
.seradr0	(seradr0),
.seradr1apb0(seradr1apb0),
.seradr1	(seradr1),
.PCLK       (PCLK),
.aresetn    (aresetn),
.sresetn    (sresetn),
.BCLKe      (BCLKe),
.SCLI      	(SCLI[z]),
.SDAI      	(SDAI[z]),
.SCLO      	(SCLO[z]),
.SDAO      	(SDAO[z]),
.INT        (INT[z]),
.PWDATA     (PWDATA),
.PRDATA     (PRDATAi[z]),
.PADDR      (PADDR[4:0]),
.PSEL       (PSELi[z]),
.PENABLE    (PENABLE),
.PWRITE     (PWRITE),
.SMBALERT_NI(SMBALERT_NI[z]),
.SMBALERT_NO(SMBALERT_NO[z]),
.SMBA_INT 	(SMBA_INT[z]),
.SMBSUS_NI  (SMBSUS_NI[z]),
.SMBSUS_NO  (SMBSUS_NO[z]),
.SMBS_INT	(SMBS_INT[z])
);
end
endgenerate

//always @*
//begin
//case (PADDR[8:5])
//4'd0 :	PRDATA = PRDATAi[0 ];
//4'd1 :	PRDATA = PRDATAi[1 ];
//4'd2 :	PRDATA = PRDATAi[2 ];
//4'd3 :	PRDATA = PRDATAi[3 ];
//4'd4 :	PRDATA = PRDATAi[4 ];
//4'd5 :	PRDATA = PRDATAi[5 ];
//4'd6 :	PRDATA = PRDATAi[6 ];
//4'd7 :	PRDATA = PRDATAi[7 ];
//4'd8 :	PRDATA = PRDATAi[8 ];
//4'd9 :	PRDATA = PRDATAi[9 ];
//4'd10:	PRDATA = PRDATAi[10];
//4'd11:	PRDATA = PRDATAi[11];
//4'd12:	PRDATA = PRDATAi[12];
//default: PRDATA = 8'h00;
//endcase
//end
//
//assign PSELi[0 ] = PSEL & (PADDR[8:5] == 4'd0 );
//assign PSELi[1 ] = PSEL & (PADDR[8:5] == 4'd1 );
//assign PSELi[2 ] = PSEL & (PADDR[8:5] == 4'd2 );
//assign PSELi[3 ] = PSEL & (PADDR[8:5] == 4'd3 );
//assign PSELi[4 ] = PSEL & (PADDR[8:5] == 4'd4 );
//assign PSELi[5 ] = PSEL & (PADDR[8:5] == 4'd5 );
//assign PSELi[6 ] = PSEL & (PADDR[8:5] == 4'd6 );
//assign PSELi[7 ] = PSEL & (PADDR[8:5] == 4'd7 );
//assign PSELi[8 ] = PSEL & (PADDR[8:5] == 4'd8 );
//assign PSELi[9 ] = PSEL & (PADDR[8:5] == 4'd9 );
//assign PSELi[10] = PSEL & (PADDR[8:5] == 4'd10);
//assign PSELi[11] = PSEL & (PADDR[8:5] == 4'd11);
//assign PSELi[12] = PSEL & (PADDR[8:5] == 4'd12);
//


genvar x;
generate for (x=0; x<=(I2C_NUM-1); x=x+1)
begin: I2C_NUM_PSELi_GEN
assign PSELi[x ] = PSEL & (PADDR[8:5] == x );
end
endgenerate

generate if (I2C_NUM==1)
begin: I2C_NUM_PRDATA_GEN1
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==2)
begin: I2C_NUM_PRDATA_GEN2
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==3)
begin: I2C_NUM_PRDATA_GEN3
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==4)
begin: I2C_NUM_PRDATA_GEN4
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==5)
begin: I2C_NUM_PRDATA_GEN5
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==6)
begin: I2C_NUM_PRDATA_GEN6
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];

	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==7)
begin: I2C_NUM_PRDATA_GEN7
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==8)
begin: I2C_NUM_PRDATA_GEN8
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==9)
begin: I2C_NUM_PRDATA_GEN9
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==10)
begin: I2C_NUM_PRDATA_GEN10
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==11)
begin: I2C_NUM_PRDATA_GEN11
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
		4'ha :	PRDATA = PRDATAi[10];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==12)
begin: I2C_NUM_PRDATA_GEN12
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
		4'ha :	PRDATA = PRDATAi[10];
		4'hb:	PRDATA = PRDATAi[11];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==13)
begin: I2C_NUM_PRDATA_GEN13
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
		4'ha :	PRDATA = PRDATAi[10];
		4'hb:	PRDATA = PRDATAi[11];
		4'hc:	PRDATA = PRDATAi[12];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==14)
begin: I2C_NUM_PRDATA_GEN14
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
		4'ha :	PRDATA = PRDATAi[10];
		4'hb:	PRDATA = PRDATAi[11];
		4'hc:	PRDATA = PRDATAi[12];
		4'hd:	PRDATA = PRDATAi[13];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==15)
begin: I2C_NUM_PRDATA_GEN15
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
		4'ha :	PRDATA = PRDATAi[10];
		4'hb:	PRDATA = PRDATAi[11];
		4'hc:	PRDATA = PRDATAi[12];
		4'hd:	PRDATA = PRDATAi[13];
		4'he:	PRDATA = PRDATAi[14];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

generate if (I2C_NUM==16)
begin: I2C_NUM_PRDATA_GEN16
  always @*
  begin
     case (PADDR[8:5])
		4'h0 :	PRDATA = PRDATAi[0 ];
		4'h1 :	PRDATA = PRDATAi[1 ];
		4'h2 :	PRDATA = PRDATAi[2 ];
		4'h3 :	PRDATA = PRDATAi[3 ];
		4'h4 :	PRDATA = PRDATAi[4 ];
		4'h5 :	PRDATA = PRDATAi[5 ];
		4'h6 :	PRDATA = PRDATAi[6 ];
		4'h7 :	PRDATA = PRDATAi[7 ];
		4'h8 :	PRDATA = PRDATAi[8 ];
		4'h9 :	PRDATA = PRDATAi[9 ];
		4'ha :	PRDATA = PRDATAi[10];
		4'hb:	PRDATA = PRDATAi[11];
		4'hc:	PRDATA = PRDATAi[12];
		4'hd:	PRDATA = PRDATAi[13];
		4'he:	PRDATA = PRDATAi[14];
		4'hf:	PRDATA = PRDATAi[15];
	 	default: PRDATA = 8'h00;
	 endcase 
  end
end
endgenerate

endmodule
