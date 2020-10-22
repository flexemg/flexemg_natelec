// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
//
// SPI Top level control.
//
// SVN Revision Information:
// SVN $Revision: 23983 $
// SVN $Date: 2014-11-28 23:42:46 +0530 (Fri, 28 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes: 
//
//
// *********************************************************************/ 

module spi_control # (
  parameter     CFG_FRAME_SIZE    = 4
)(  
                     input         aresetn,
                     input         sresetn,
                     input         psel,
                     input         penable,
                     input         pwrite,
                     input  [6:0]  paddr,
                     input  [CFG_FRAME_SIZE-1:0] wr_data_in,
                     input         cfg_master,
                     input         rx_fifo_empty,
                     input         tx_fifo_empty,

                     output [CFG_FRAME_SIZE-1:0] tx_fifo_data,            
                     output        tx_fifo_write,           
                     output        tx_fifo_last,             
                     output        rx_fifo_read            
                );



//######################################################################################################

reg tx_fifo_write_sig;
reg rx_fifo_read_sig;
reg tx_last_frame_sig;

// Output assignments.
assign tx_fifo_last   = tx_last_frame_sig;      
assign tx_fifo_data   = wr_data_in;
assign tx_fifo_write  = tx_fifo_write_sig;     
assign rx_fifo_read   = rx_fifo_read_sig;     

// Note combinational generation of FIFO read and write signals

always @(*)
   begin
   //defaults
   rx_fifo_read_sig  = 1'b0;      //default no read on rx fifo
   tx_fifo_write_sig = 1'b0;      //default no write on tx fifo
   tx_last_frame_sig = 1'b0;      //default not last frame

   if (penable && psel)
      begin
      case (paddr) //synthesis parallel_case
      6'h0C:	  //write to transmit fifo
         begin
            if (pwrite)
               begin
                 tx_fifo_write_sig  = 1'b1;   //write to the fifo                 
               end            
         end
      6'h08:    //read from receive fifo
         begin 
            if (~pwrite) 
            begin
                rx_fifo_read_sig = 1'b1;
            end
         end
      6'h28:    // aliased transmit data, sets last frame bit
        begin
          if(pwrite)
          begin
            tx_fifo_write_sig  = 1'b1;   //write to the fifo
            tx_last_frame_sig  = 1'b1;   //last frame
          end
        end
      default:
         begin
         end
      endcase     
   end
end

endmodule
   