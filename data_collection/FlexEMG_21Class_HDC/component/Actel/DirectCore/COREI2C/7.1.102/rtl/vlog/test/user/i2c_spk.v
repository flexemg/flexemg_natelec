//*******************************************************************--
// Copyright (c) 2008  Actel Corp.                                   --
//*******************************************************************--
// Please review the terms of the license agreement before using     --
// this file. If you are not an authorized user, please destroy this --
// source code file and notify Actel Corp. immediately that you      --
// inadvertently received an unauthorized copy.                      --
//*******************************************************************--
//---------------------------------------------------------------------
//
// File name            : i2c_spk.v
// File contents        : spike generator
// Purpose              : spike generator
//
// Destination library  : COREI2C_LIB
//
// Revision: v2.0  08Aug2008
//
 
// SVN Revision Information:
// SVN $Revision: 10646 $
// SVN $Date: 2009-11-03 14:35:34 -0800 (Tue, 03 Nov 2009) $  
// 
//*******************************************************************--

`timescale 1 ns / 1 ns // timescale for following modules

module i2c_spk #(
parameter SPIKE_CYCLE_WIDTH = 0
)(
//system globals
input  PRESETN,
input  PCLK,
inout  scl,
inout  sda
   );

wire  sclo; 
wire  sdao; 
wire  scli; 
wire  sdai; 

assign scl = (sclo == 1'b0) ? 1'b0 : 1'bz ;
assign sda = (sdao == 1'b0) ? 1'b0 : 1'bz ;
assign scli = scl;
assign sdai = sda;

reg [4:0] counter;

   always @(negedge PCLK or negedge PRESETN)
   begin : counter_write_proc
   //------------------------------------------------------------------
   if (PRESETN == 1'b0)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      counter <= 0;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
            counter <= counter + 1'b1 ;
      end
   end

 assign sclo = (counter < SPIKE_CYCLE_WIDTH)? 1'b0: 1'b1;
 assign sdao = 1'b1;
  
endmodule
