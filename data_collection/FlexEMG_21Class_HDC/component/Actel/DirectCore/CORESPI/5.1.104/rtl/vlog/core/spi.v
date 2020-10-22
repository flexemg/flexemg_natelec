// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
//
// spi.v -- top level module for spi core
//
//
// SVN Revision Information:
// SVN $Revision: 23984 $
// SVN $Date: 2014-11-29 00:14:15 +0530 (Sat, 29 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes: 
//
//
// *********************************************************************/ 


module spi(   //inputs
              PCLK,       //system clock
              PRESETN,    //system reset
              aresetn,    //Async reset signal
              sresetn,    //Sync reset signal
              PADDR,      //address line
              PSEL,       //device select
              PENABLE,    //enable
              PWRITE,     //write
              PWDATA,     //write data
              SPISSI,     //slave select
              SPISDI,     //serial data in
              SPICLKI,    //serial clock in

              //outputs
              PRDDATA,    //data read
              SPIINT,     //interrupt
              SPISS,      //slave select
              SPISCLKO,   //serial clock out
              SPIRXAVAIL, //data ready to be read (dma mode)
              SPITXRFM,   //room for more (dma mode)
              SPIOEN,     //output enable
              SPISDO,     //serial data out
              SPIMODE     //1 -> master, 0 -> slave
              );

parameter               APB_DWIDTH      =   8;
parameter               CFG_FRAME_SIZE  =   4;
parameter               CFG_FIFO_DEPTH      =   4;
parameter               CFG_CLK         =   7;
parameter               SPO             =   0;
parameter               SPH             =   0;
parameter               SPS             =   0;
parameter               CFG_MODE        =   0;
parameter               SYNC_RESET      =   0;
              
//input TESTMODE;
input PCLK;
input PRESETN;
input aresetn;
input sresetn;
input [6:0] PADDR;
input PSEL;
input PENABLE;
input PWRITE;
input [APB_DWIDTH-1:0] PWDATA;
input SPISSI;
input SPISDI;
input SPICLKI;


output [APB_DWIDTH-1:0] PRDDATA;

output SPIINT;
output [7:0] SPISS;
output SPISCLKO;
output SPIRXAVAIL;
output SPITXRFM;
output SPIOEN;
output SPIMODE;
output SPISDO;




wire [APB_DWIDTH-1:0] prdata_regs; 
wire [7:0]  cfg_ssel;             
wire        cfg_master;
wire        cfg_enable;
wire [2:0]  cfg_cmdsize;

wire [CFG_FRAME_SIZE-1:0] tx_fifo_data_in;      
wire [CFG_FRAME_SIZE-1:0] tx_fifo_data_out;     
wire [CFG_FRAME_SIZE-1:0] rx_fifo_data_in;      
wire [CFG_FRAME_SIZE-1:0] rx_fifo_data_out;     

wire rx_fifo_empty;
wire tx_fifo_full;
wire master_ssel_out;
wire [5:0]   rx_fifo_count;
wire [5:0]   tx_fifo_count;


//##########################################################################################
//APB Signals 


wire  [6:0]  PADDR32 = { PADDR[6:2], 2'b00 };


//read data: either from the register file or the fifo.
assign PRDDATA = ~(PADDR32[6:0]==7'h08) ? prdata_regs :  rx_fifo_data_out;

assign SPIMODE    = cfg_master;
assign SPIRXAVAIL = ~rx_fifo_empty;
assign SPITXRFM   = ~tx_fifo_full;


// ----------------------------------------------------------------------------------
// Channel Outputs

//Pass the slave select to the selected devices. If no slave select asserted then everything off

reg [7:0]  master_ssel_all;
assign SPISS = master_ssel_all;

integer i;
always @(*)
   begin
      if (cfg_enable && cfg_master)
         begin
            for (i=0; i<8; i=i+1)
             begin
               if (cfg_ssel[i])
                  master_ssel_all[i] = master_ssel_out;
               else
                  master_ssel_all[i] = (CFG_MODE != 1);   //Send low in TIMODE to deselect
             end
         end
      else
         begin
            for (i =0; i<8; i=i+1)
                 master_ssel_all[i] = (CFG_MODE != 1);    //Send low in TIMODE to deselect
         end
   end      
      
wire  ssel_both = ( cfg_master ? master_ssel_out : SPISSI ); 


//-----------------------------------------------------------------------------------------


// The Register Set
spi_rf # (
          .APB_DWIDTH(APB_DWIDTH)
)
URF    (        .pclk                 (PCLK),                           
                .aresetn              (aresetn),
                .sresetn              (sresetn),                      
                .paddr                (PADDR32[6:0]),                   
                .psel                 (PSEL),
                .penable              (PENABLE),                             
                .pwrite               (PWRITE),                         
                .wrdata               (PWDATA),                         
                .prdata               (prdata_regs),                    
                .interrupt            (SPIINT),                         
              
                .tx_channel_underflow (tx_channel_underflow),           
                .rx_channel_overflow  (rx_channel_overflow),           
                .tx_done              (tx_done),                        
                .rx_done              (rx_done),                        
                .rx_fifo_read         (rx_fifo_read),                   
                .tx_fifo_write        (tx_fifo_write),                  
                .tx_fifo_read         (tx_fifo_read),                  
                .rx_fifo_full         (rx_fifo_full),                   
                .rx_fifo_full_next    (rx_fifo_full_next),              
                .rx_fifo_empty        (rx_fifo_empty),                  
                .rx_fifo_empty_next   (rx_fifo_empty_next),             
                .tx_fifo_full         (tx_fifo_full),                   
                .tx_fifo_full_next    (tx_fifo_full_next),              
                .tx_fifo_empty        (tx_fifo_empty), 
                .tx_fifo_empty_next   (tx_fifo_empty_next), 
                .first_frame          (first_frame_out),
                .ssel                 (ssel_both),                       
                .rx_pktend            (rx_pktend),
                .rx_cmdsize           (rx_cmdsize),
                .active               (active),

                .cfg_enable           (cfg_enable),                       
                .cfg_master           (cfg_master),               
                .cfg_ssel             (cfg_ssel),
                .cfg_cmdsize          (cfg_cmdsize),
                .clr_txfifo           (fiforsttx),                     
                .clr_rxfifo           (fiforstrx),
                .cfg_frameurun        (cfg_frameurun),
                .cfg_oenoff           (cfg_oenoff)
              );


// APB side of FIFOs Control    

spi_control # (
                   .CFG_FRAME_SIZE       (CFG_FRAME_SIZE)
)           UCON ( .aresetn              (aresetn),
                   .sresetn              (sresetn),
                   .psel                 (PSEL),
                   .penable              (PENABLE),
                   .pwrite               (PWRITE),
                   .paddr                (PADDR32[6:0]),
                   .wr_data_in           (PWDATA[CFG_FRAME_SIZE-1:0]),          // Use only FRAME_SIZE bits for data
                   .cfg_master           (cfg_master),
                   .tx_fifo_data         (tx_fifo_data_in),     
                   .tx_fifo_write        (tx_fifo_write),       
                   .tx_fifo_last         (tx_fifo_last_in),        
                   .tx_fifo_empty        (tx_fifo_empty),
                   .rx_fifo_read         (rx_fifo_read),
                   .rx_fifo_empty        (rx_fifo_empty)           
                   );


//Transmit Fifo

spi_fifo # (
                   .CFG_FRAME_SIZE  (CFG_FRAME_SIZE),
                   .CFG_FIFO_DEPTH      (CFG_FIFO_DEPTH)
) UTXF    (        .pclk            (PCLK), 
                   .aresetn         (aresetn),
                   .sresetn         (sresetn), 
                   .fiforst         (fiforsttx),
                   .data_in         (tx_fifo_data_in),               
                   .flag_in         (tx_fifo_last_in),                  
                   .data_out        (tx_fifo_data_out),              
                   .flag_out        (tx_fifo_last_out),              
                   .read_in         (tx_fifo_read),                  
                   .write_in        (tx_fifo_write),                 
                   .full_out        (tx_fifo_full),                  
                   .empty_out       (tx_fifo_empty),                 
                   .full_next_out   (tx_fifo_full_next),             
                   .empty_next_out  (tx_fifo_empty_next),            
                   .overflow_out    (not_used1),              
                   .fifo_count      (tx_fifo_count)
                   );



//Receive Fifo

spi_fifo # (
          .CFG_FRAME_SIZE(CFG_FRAME_SIZE),
          .CFG_FIFO_DEPTH(CFG_FIFO_DEPTH)
          
) URXF     (        .pclk            (PCLK), 
                    .aresetn         (aresetn),
                    .sresetn         (sresetn),
                    .fiforst         (fiforstrx),
                    //.fifosize        (cfg_fifosize),
                    .data_in         (rx_fifo_data_in),             
                    .write_in        (rx_fifo_write), 
                    .flag_in         (rx_fifo_first_in),             
                    .data_out        (rx_fifo_data_out),            
                    .read_in         (rx_fifo_read),                
                    .flag_out        (first_frame_out),             
                    .full_out        (rx_fifo_full),                
                    .empty_out       (rx_fifo_empty),               
                    .empty_next_out  (rx_fifo_empty_next),          
                    .full_next_out   (rx_fifo_full_next),           
                    .overflow_out    (rx_channel_overflow),         
                    .fifo_count      (rx_fifo_count)
                    );


//Channel controll

spi_chanctrl # (
  .SPH                (SPH),
  .SPO                (SPO),
  .SPS                (SPS),
  .CFG_MODE           (CFG_MODE),
  .CFG_CLKRATE        (CFG_CLK),
  .CFG_FRAME_SIZE     (CFG_FRAME_SIZE),
  .SYNC_RESET         (SYNC_RESET)
)UCC   (               .pclk               (PCLK),      
                       .presetn            (PRESETN), 
                       .aresetn            (aresetn),
                       .sresetn            (sresetn),      
                       .spi_clk_in         (SPICLKI),      
                       .spi_clk_out        (SPISCLKO),        
                       .spi_ssel_in        (SPISSI),
                       .spi_ssel_out       (master_ssel_out),    
                       .spi_data_in        (SPISDI),
                       .spi_data_out       (SPISDO), 
                       .spi_data_oen       (SPIOEN),
                       .txfifo_count       (tx_fifo_count),
                       .txfifo_empty       (tx_fifo_empty),       
                       .txfifo_read        (tx_fifo_read), 
                       .txfifo_data        (tx_fifo_data_out),
                       .txfifo_last        (tx_fifo_last_out),
                       .rxfifo_count       (rx_fifo_count),
                       .rxfifo_write       (rx_fifo_write),
                       .rxfifo_data        (rx_fifo_data_in),
                       .rxfifo_first       (rx_fifo_first_in), 
                       .cfg_enable         (cfg_enable), 
                       .cfg_master         (cfg_master), 
                       .cfg_frameurun      (cfg_frameurun),         
                       .cfg_cmdsize        (cfg_cmdsize),
                       .cfg_oenoff         (cfg_oenoff),
                       .tx_alldone         (tx_done), 
                       .rx_alldone         (rx_done), 
                       .rx_pktend          (rx_pktend),
                       .rx_cmdsize         (rx_cmdsize),
                       .tx_underrun        (tx_channel_underflow),
                       .active             (active) 
                     );                 



endmodule


   