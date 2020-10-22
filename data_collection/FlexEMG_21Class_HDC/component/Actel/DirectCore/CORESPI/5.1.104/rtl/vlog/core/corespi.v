// ********************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
 //
//
// corespi.v
//
//
// SVN Revision Information:
// SVN $Revision: 23983 $
// SVN $Date: 2014-11-28 23:42:46 +0530 (Fri, 28 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
// Notes:
//
//
// *********************************************************************/

module
CORESPI 
(	 //inputs
             PCLK,       //system clock
             PRESETN,    //system reset
             PADDR,      //address line
             PSEL,       //device select
             PENABLE,    //enable
             PWRITE,     //write
             PWDATA,     //write data
             SPISSI,     //slave select
             SPISDI,     //serial data in
             SPICLKI,    //serial clock in

             //outputs
             PRDATA,     //data read
             SPIINT,     //interrupt
             SPISS,      //slave select
             SPISCLKO,   //serial clock out
             SPIRXAVAIL, //data ready to be read (dma mode)
             SPITXRFM,   //room for more (dma mode)
             SPIOEN,     //output enable
             SPISDO,     //serial data out
             SPIMODE,     //1 -> master, 0 -> slave,
             PREADY,
             PSLVERR
             );

parameter   FAMILY              = 15;
parameter   APB_DWIDTH          = 8;
parameter   CFG_FRAME_SIZE      = 4;
parameter   CFG_FIFO_DEPTH      = 4;
parameter   CFG_CLK             = 3;
parameter   CFG_MODE            = 0;
parameter   CFG_MOT_MODE        = 2;
parameter   CFG_MOT_SSEL        = 0;
parameter   CFG_TI_NSC_CUSTOM   = 0;
parameter   CFG_TI_NSC_FRC      = 0;
parameter   CFG_TI_JMB_FRAMES   = 0;
parameter   CFG_NSC_OPERATION   = 0;

parameter SYNC_RESET = (FAMILY  == 25) ? 1 : 0;
localparam SPS = ((CFG_MODE == 2'd0) && (CFG_MOT_SSEL == 1'b1)) ? 1'b1 :
                 ((CFG_MODE == 2'd2) && (CFG_TI_NSC_CUSTOM == 1'b1) && (CFG_NSC_OPERATION == 2'd2)) ? 1'b1 :
                 1'b0;

localparam SPO = (CFG_MODE == 2'd0) ? CFG_MOT_MODE[1] :
                 (((CFG_MODE == 2'd1) || (CFG_MODE == 2'd2)) && (CFG_TI_NSC_CUSTOM == 1'b1) && (CFG_TI_NSC_FRC == 1'b1)) ? 1'b1 :
                 1'b0;

localparam SPH = (CFG_MODE == 2'd0) ? CFG_MOT_MODE[0] :
                 ((CFG_MODE == 2'd1) && (CFG_TI_NSC_CUSTOM == 1'b1) && (CFG_TI_JMB_FRAMES == 1'b1)) ? 1'b1 :
                 ((CFG_MODE == 2'd2) && (CFG_TI_NSC_CUSTOM == 1'b1) && (CFG_NSC_OPERATION == 2'd1)) ? 1'b1 :
                 1'b0;

//input TESTMODE;
input PCLK;
input PRESETN;
input [6:0] PADDR;
input PSEL;
input PENABLE;
input PWRITE;
input [APB_DWIDTH-1:0] PWDATA;
input SPISSI;
input SPISDI;
input SPICLKI;


output [APB_DWIDTH-1:0] PRDATA;
output SPIINT;
output [7:0] SPISS;
output SPISCLKO;
output SPIRXAVAIL;
output SPITXRFM;
output SPIOEN;
output SPIMODE;
output SPISDO;

// AP3
output PSLVERR;
output PREADY;

wire aresetn;
wire sresetn;

assign aresetn = (SYNC_RESET == 1) ? 1'b1 : PRESETN;
assign sresetn = (SYNC_RESET == 1) ? PRESETN : 1'b1;

// tie off AP3 signals
assign PSLVERR = 1'b0;
assign PREADY = 1'b1;

spi # (
          .APB_DWIDTH     (APB_DWIDTH),
          .CFG_FRAME_SIZE (CFG_FRAME_SIZE),
          .CFG_FIFO_DEPTH (CFG_FIFO_DEPTH),
          .CFG_CLK        (CFG_CLK),
          .SPO            (SPO),
          .SPH            (SPH),
          .SPS            (SPS),
          .CFG_MODE       (CFG_MODE),
          .SYNC_RESET     (SYNC_RESET)
) USPI( //inputs
         .PCLK(PCLK),      
         .PRESETN(PRESETN),
         .aresetn(aresetn),
         .sresetn(sresetn),
         .PADDR(PADDR),    
         .PSEL(PSEL),      
         .PENABLE(PENABLE),
         .PWRITE(PWRITE),  
         .PWDATA(PWDATA),  
         .SPISSI(SPISSI),  
         .SPISDI(SPISDI),  
         .SPICLKI(SPICLKI),
          
         //outputs
         .PRDDATA(PRDATA), 
         .SPIINT(SPIINT),  
         .SPISS(SPISS),    
         .SPISCLKO(SPISCLKO), 
         .SPIRXAVAIL(SPIRXAVAIL),
         .SPITXRFM(SPITXRFM), 
         .SPIOEN(SPIOEN), 
         .SPISDO(SPISDO), 
         .SPIMODE(SPIMODE)
         );

endmodule
