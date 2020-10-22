// ********************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
//
// SPI Register file
//
//
// SVN Revision Information:
// SVN $Revision: 27727 $
// SVN $Date: 2016-11-01 18:17:41 +0530 (Tue, 01 Nov 2016) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
//
// *********************************************************************/





module spi_rf # (
  parameter APB_DWIDTH = 8
)(               //APB Access to registers
                 input             pclk,
                 input             aresetn,
                 input             sresetn,
                 input [6:0]       paddr,
                 input             psel,
                 input             pwrite,
                 input             penable,
                 input [APB_DWIDTH-1:0]      wrdata,
                 output [APB_DWIDTH-1:0]     prdata,
                 output            interrupt,

                 //Hardware Status
                 input             tx_channel_underflow,  
                 input             rx_channel_overflow,   
                 input             tx_done,               
                 input             rx_done,               
                 input             rx_fifo_read,
                 input             tx_fifo_read,
                 input             tx_fifo_write,

                 input             rx_fifo_full,
                 input             rx_fifo_full_next,
                 input             rx_fifo_empty,
                 input             rx_fifo_empty_next,

                 input             tx_fifo_full,
                 input             tx_fifo_full_next,
                 input             tx_fifo_empty,
                 input             tx_fifo_empty_next,
                 input             first_frame,
                 input             ssel,
                 input             active,
                 input             rx_pktend,
                 input             rx_cmdsize,
                 
                 //Static Configuration Outputs
                 output            cfg_enable,
                 output            cfg_master,
                 output reg [7:0]  cfg_ssel,
                 output      [2:0]  cfg_cmdsize,
                 output            cfg_oenoff,

                 //Strobe Outputs, will change during operation
                 output reg        clr_txfifo, 
                 output reg        clr_rxfifo,
                 output            cfg_frameurun
);


reg   [7:0] control1;        
reg   [7:0]  control2;       
wire  [5:0]  command;       
wire  [7:0]  int_masked;
reg   [7:0]  int_raw;
wire  [7:0]  status_byte;
reg   [1:0]  sticky;
reg   [APB_DWIDTH-1:0] rdata;

// -----------------------------------------------------------------------------------------------------------------------
// Registers with sticky bits (The interrupt register)

assign  int_masked =    { 
                          (int_raw[7] &&  control2[7]),         // !tx_fifo_full
                          (int_raw[6] &&  control2[6]),         // !rx_fifo_empty
                          (int_raw[5] &&  control2[5]),         // ssend
                          (int_raw[4] &&  control2[4]),         // cmdint         
                          (int_raw[3] &&  control1[5]),         // txunderrun
                          (int_raw[2] &&  control1[4]),         // rxoverflow
						  (1'b0),  
                          (int_raw[0] &&  control1[3])          // txdone
                        };
                                             
assign interrupt =   int_masked[7] || int_masked[6] || int_masked[5] || int_masked[4] || 
                     int_masked[3] || int_masked[2] || int_masked[1] || int_masked[0] ;
 

// ############################################################################################################
// Create Register Values 

   
assign status_byte = { active,
                       ssel,
                       int_raw[3],
                       int_raw[2],
                       tx_fifo_full,
                       rx_fifo_empty,					  
					  (sticky[0] && sticky[1]),
                       first_frame
                     };
assign command  = 8'h00;

   
// ############################################################################################################
// Writes. 

integer i;

always @(posedge pclk or negedge aresetn)
  begin
    if ((!aresetn) || (!sresetn))
      begin
       control1       <= 8'h00;
       cfg_ssel       <= 8'h00;
       control2       <= 8'h00;
       clr_rxfifo     <= 1'b0;  
       clr_txfifo     <= 1'b0;  
       int_raw        <= 8'h80; 
       sticky         <= 2'b00;
      end
    else
      begin

        //------------------------------------------------------------------------
        // Hardware Events lower priority than CPU activities
        
        clr_rxfifo   <= 1'b0;
        clr_txfifo   <= 1'b0;

        //-----------------------------------------------------------------------
        // CPU Writes
        if (psel & pwrite & penable)
          begin
             case (paddr) //synthesis parallel_case
             7'h00:  begin
                       control1[7:0] <= wrdata[7:0];    
                     end
             7'h04:  begin
                       for (i=0; i<8; i=i+1) if (wrdata[i]) int_raw[i] <= 1'b0;
                     end
             7'h18:  begin
                       control2      <= wrdata[7:0];
                     end
             7'h1c:  begin
                       clr_rxfifo  <= wrdata[0];
                       clr_txfifo  <= wrdata[1];
                     end
             7'h24:  cfg_ssel       <= wrdata[7:0];  
             default:  begin end
           endcase
           //if we were enabled don't allow various changes
          end
        
        //------------------------------------------------------------------------
        // Hardware Events higher priority than CPU activities 
        // Sticky Status Bits 
        if (tx_done)              sticky[0]  <= 1'b1;
		if (rx_done)              sticky[1]  <= 1'b1;
        if (tx_fifo_write)        sticky[0]  <= 1'b0; 
        if (rx_fifo_read)         sticky[1]  <= 1'b0;
       
        // Interrupt Settings
        if (tx_done)              int_raw[0]  <= 1'b1;
		if (rx_done)              int_raw[1]  <= 1'b1;
        if (rx_channel_overflow)  int_raw[2]  <= 1'b1;
        if (tx_channel_underflow) int_raw[3]  <= 1'b1;  
        if (rx_cmdsize)           int_raw[4]  <= 1'b1;                
        if (rx_pktend)            int_raw[5]  <= 1'b1;                
        if (!rx_fifo_empty)       int_raw[6]  <= 1'b1;                
        if (!tx_fifo_full)        int_raw[7]  <= 1'b1;                

        control2[3]    <= 1'b0;
      end
 end


// 5:2 are interrupt enables     
assign cfg_enable     = control1[0];        
assign cfg_master     = control1[1];       
assign cfg_frameurun  = control1[6];
assign cfg_oenoff     = control1[7];
assign cfg_cmdsize    = control2[2:0];

// ############################################################################################################
// Reads, purely combinational of the PADDR. 

localparam [APB_DWIDTH-1:0] ZEROS = {(APB_DWIDTH){1'b0}};

always @(*)
 begin
     if (psel)    
       begin
         rdata = ZEROS;
         case (paddr) //synthesis parallel_case
          7'h00:  rdata[7:0] = control1[7:0];     // control register 1
          7'h04:  rdata[7:0] = 8'h00;             // write-only
                                                  // 0x08 assigned elsewhere
          7'h0C:  rdata[7:0] = 8'h00;             // write-only
          7'h10:  rdata[7:0] = int_masked[7:0];   // masked interrupt register
          7'h14:  rdata[7:0] = int_raw[7:0];      // raw interrupt register
          7'h18:  rdata[7:0] = control2[7:0];     // control register 2
          7'h20:  rdata[7:0] = status_byte[7:0];  // status register
          7'h24:  rdata[7:0] = cfg_ssel[7:0];     // slave select register
         default: rdata = ZEROS;
         endcase
       end
     else
        rdata = ZEROS;    
 end

assign prdata = ( (psel && penable) ? rdata : ZEROS);



endmodule


