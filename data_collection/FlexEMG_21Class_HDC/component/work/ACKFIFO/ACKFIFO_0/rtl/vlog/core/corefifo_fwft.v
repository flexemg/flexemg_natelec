// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description:  fwft.v
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

module ACKFIFO_ACKFIFO_0_corefifo_fwft (
                        wr_clk,
                        rd_clk,
                        clk,
                        rst,
                        empty,
                        aempty,
                        rd_en,
                        fifo_rd_en,
                        fifo_empty,
                        fifo_aempty,
                        fifo_dout,
                        wr_en,
                        din,
                        fwft_dvld,
                        reg_valid,
                        dout,
                        fifo_MEMRADDR,
                        fwft_MEMRADDR
                        );

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter                RDEPTH          = 10;
   parameter                WWIDTH          = 10;
   parameter                RWIDTH          = 10;
   parameter                WCLK_HIGH       = 1;
   parameter                RCLK_HIGH       = 1;
   parameter                RESET_LOW       = 1;
   parameter                WRITE_LOW       = 1;
   parameter                READ_LOW        = 1;
   parameter                PREFETCH        = 0;
   parameter                FWFT            = 0;
   parameter                SYNC            = 1;
   parameter                SYNC_RESET      = 0;

   localparam RDEPTH_CAL      = (RDEPTH == 0) ? RDEPTH  : (RDEPTH-1); 
 
   // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------
   
   //--------
   // Inputs
   //--------

   // Clocks and Reset
   input                  wr_clk;
   input                  rd_clk;
   input                  clk;
   input                  rst;
   input                  wr_en;
   input                  rd_en;
   output                 fifo_rd_en;
   input [RWIDTH-1 : 0]   fifo_dout;
   input                  fifo_empty;
   input                  fifo_aempty;
   input [WWIDTH - 1 : 0] din;
   input [RDEPTH_CAL : 0] fifo_MEMRADDR;

   //---------
   // Outputs
   //---------
   output                  empty;
   output                  aempty;
   output [RWIDTH-1 : 0]   dout;
   output                  fwft_dvld;
   output                  reg_valid;   
   output [RDEPTH_CAL : 0] fwft_MEMRADDR;
   
   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------
   reg                     fifo_valid, dout_valid, middle_valid ;
   reg [RWIDTH - 1 : 0]    middle_dout;
   reg [RWIDTH - 1 : 0]    dout;
   wire [RWIDTH - 1 : 0]   fifo_dout;
   wire                    fifo_rd_en, fifo_empty;
   wire                    update_dout, update_middle;
   wire [RDEPTH_CAL : 0]   fwft_MEMRADDR;
   reg                     fifo_empty_r;

   wire                    fwft_dvld;  
   reg                     wr_p_r;
   reg                     reg_valid;
   wire                    we_p;
   reg                     we_p_r;
   wire                    re_p;
   wire                    aresetn;
   wire                    sresetn;
   wire                    pos_rclk;
   wire                    pos_wclk;   

   reg                     empty_r;
   reg                     reg_valid_r;
   wire                    empty1;
   wire                    empty;
   reg                     update_dout_r;
   
   
   // --------------------------------------------------------------------------
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // ||                                                                      ||
   // ||                     Start - of - Code                                ||
   // ||                                                                      ||
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // --------------------------------------------------------------------------

   // --------------------------------------------------------------------------
   // Clocks, resets and enables
   // --------------------------------------------------------------------------
   generate
      if(SYNC == 1) begin
         assign pos_rclk  = RCLK_HIGH ? clk  : ~clk;
         assign pos_wclk  = WCLK_HIGH ? clk  : ~clk;
      end
   endgenerate

   generate
      if(SYNC == 0) begin
         assign pos_rclk  = RCLK_HIGH ? rd_clk  : ~rd_clk;
         assign pos_wclk  = WCLK_HIGH ? wr_clk  : ~wr_clk;
      end
   endgenerate

   assign we_p  = WRITE_LOW ? (~wr_en) : (wr_en);
   assign re_p  = READ_LOW  ? (~rd_en) : (rd_en); 

   assign neg_reset = (RESET_LOW  == 1) ? ~rst : rst;         
   assign aresetn   = (SYNC_RESET == 1) ? 1'b1  : neg_reset;
   assign sresetn   = (SYNC_RESET == 1) ? neg_reset : 1'b1;

   // --------------------------------------------------------------------------
   // Generate addresses to the memory
   // --------------------------------------------------------------------------
   assign fwft_MEMRADDR = fifo_MEMRADDR;

   assign update_middle = fifo_valid & (middle_valid == update_dout);
   assign update_dout   = (fifo_valid || middle_valid) && (re_p || !dout_valid);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = !(fifo_empty) && !(middle_valid && dout_valid && fifo_valid); 

   // --------------------------------------------------------------------------
   // Generate empty/almost empty signal
   // --------------------------------------------------------------------------
   assign empty   = !dout_valid | (!fifo_valid && !middle_valid && dout_valid & !update_dout & re_p);   

   assign aempty  = fifo_aempty | empty;  

   // --------------------------------------------------------------------------
   // Register empty signal
   // --------------------------------------------------------------------------
   always @(posedge pos_rclk or negedge aresetn) begin
      if((!aresetn) || (!sresetn)) begin
         fifo_empty_r   <= 1'b0;
         update_dout_r   <= 'h0;
      end
      else begin
         fifo_empty_r   <= fifo_empty;
         update_dout_r   <= update_dout;
      end
   end
  
   // --------------------------------------------------------------------------
   // FWFT logic
   // --------------------------------------------------------------------------
   always @(posedge pos_rclk or negedge aresetn) begin
      if((!aresetn) || (!sresetn)) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 'h0;
         middle_dout  <= 'h0;
      end
      else begin
         if(update_middle) begin
            middle_dout  <= fifo_dout;
         end
         if(update_dout) begin
            dout  <= middle_valid ? middle_dout : fifo_dout;  
         end
         
         if(fifo_rd_en) begin
            fifo_valid  <= 1'b1;
         end
         else if(update_middle || update_dout) begin
            fifo_valid  <= 1'b0;
         end
         
         if(update_middle) begin
            middle_valid  <= 1'b1;
         end
         else if(update_dout) begin
            middle_valid  <= 1'b0;
         end

         if(update_dout) begin
            dout_valid  <= 1'b1;
         end
         else if(re_p) begin
            dout_valid  <= 1'b0;
         end

      end
   end      

   // --------------------------------------------------------------------------
   // Generate the data valid signal
   // --------------------------------------------------------------------------
   generate
      if(FWFT == 1) begin
         assign fwft_dvld = reg_valid | (re_p & !empty_r);         
      end
   endgenerate

   generate
      if(PREFETCH == 1) begin
         assign fwft_dvld = (re_p) & !empty_r;  
      end
   endgenerate
            
   // --------------------------------------------------------------------------
   // Generate the qualifying signal to sample the read data. It is also used
   // to generate the read data valid signal
   // --------------------------------------------------------------------------
   always @(*) begin
      if(re_p == 1'b1) begin 
         reg_valid  = 1'b0;
      end
      else if(empty == 1'b0 && empty_r == 1'b1) begin
         reg_valid  = 1'b1;
      end
      else begin
         reg_valid  = reg_valid_r;
      end
   end      
   
   always @(posedge pos_rclk or negedge aresetn) begin
      if((!aresetn) || (!sresetn)) begin
         empty_r   <= 1'b0;         
         reg_valid_r   <= 1'b0;         
      end
      else begin
         empty_r   <= empty;         
         reg_valid_r   <= reg_valid;         
      end
   end

   always @(posedge pos_wclk or negedge aresetn) begin
      if((!aresetn) || (!sresetn)) begin
         we_p_r   <= 1'b0;         
      end
      else begin
         we_p_r   <= we_p;         
      end
   end

endmodule // corefifo_fwft

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
