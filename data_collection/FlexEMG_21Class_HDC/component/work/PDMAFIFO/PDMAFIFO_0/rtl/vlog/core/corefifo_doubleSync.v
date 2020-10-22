// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: doubleSync.v
//               
//
//
// Revision Information:
// Date     Description
//
// SVN Revision Information:
// SVN $Revision: 4805 $
// SVN $Date: 2012-06-21 17:48:48 +0530 (Thu, 21 Jun 2012) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ********************************************************************/

`timescale 1ns / 100ps

module PDMAFIFO_PDMAFIFO_0_corefifo_doubleSync(
                  clk,
                  rstn,
                  inp,
                  sync_out
                  );

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter ADDRWIDTH  = 3;
   parameter SYNC_RESET = 0;
   
   // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------

   //--------
   // Inputs
   //--------
   input [ADDRWIDTH : 0] inp;
   input clk;
   input rstn;

   //--------
   // Outputs
   //--------
   output [ADDRWIDTH : 0] sync_out;

   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------

   reg    [ADDRWIDTH : 0] sync_int;
   reg    [ADDRWIDTH : 0] sync_out;
   

   wire                             aresetn;
   wire                             sresetn;
   // --------------------------------------------------------------------------
   //                               Start - of - Code
   // --------------------------------------------------------------------------   
   assign aresetn   = (SYNC_RESET == 1) ? 1'b1  : rstn;
   assign sresetn   = (SYNC_RESET == 1) ? rstn : 1'b1;

   // --------------------------------------------------------------------------   
   // Double synchronization FFs
   // --------------------------------------------------------------------------   
   always @(posedge clk or negedge aresetn) begin 
      if((!aresetn) || (!sresetn)) begin 
         sync_int <= 'h0;
         sync_out <= 'h0;
      end
      else begin
         sync_int <= inp;
         sync_out <= sync_int;
      end
   end
   
   
endmodule // corefifo_doubleSync

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
