// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
//
// SPI Synchronous Fifo
//
//
// SVN Revision Information:
// SVN $Revision: 23983 $
// SVN $Date: 2014-11-28 18:12:46 +0000 (Fri, 28 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
//
// *********************************************************************/ 



module spi_fifo(   pclk,           
                   aresetn,
                   sresetn,
                   fiforst,
                   data_in,       
                   flag_in,       
                   data_out,      
                   flag_out,      

                   read_in,       
                   write_in,      
                   
                   full_out,      
                   empty_out,     
                   full_next_out, 
                   empty_next_out,
                   overflow_out,  
                   fifo_count
                );

parameter CFG_FRAME_SIZE = 4;       // 4-32
parameter CFG_FIFO_DEPTH = 4;       // 2,4,8,16,32

                
input pclk;
input aresetn;
input sresetn;
input fiforst;
input [CFG_FRAME_SIZE-1:0] data_in;
input read_in;
input write_in;
input flag_in;


output [CFG_FRAME_SIZE-1:0] data_out;
output empty_out;
output full_out;
output empty_next_out;
output full_next_out;
output overflow_out;
output flag_out;
output [5:0] fifo_count;

   
reg [4:0] rd_pointer_d; 
reg [4:0] rd_pointer_q;        //read pointer address
reg [4:0] wr_pointer_d;
reg [4:0] wr_pointer_q;        //write pointer address
reg [5:0] counter_d;
reg [5:0] counter_q;           //counter 5 bits


reg [CFG_FRAME_SIZE:0] fifo_mem_d[0:CFG_FIFO_DEPTH-1];    //FIFO has extra flag bit (CFG_FRAME_SIZE + 1)
reg [CFG_FRAME_SIZE:0] fifo_mem_q[0:CFG_FIFO_DEPTH-1];
reg [CFG_FRAME_SIZE:0] data_out_dx;
reg [CFG_FRAME_SIZE:0] data_out_d;

reg full_out;       
reg empty_out;     
reg full_next_out;  
reg empty_next_out; 

wire [CFG_FRAME_SIZE-1:0]  data_out  = data_out_d[CFG_FRAME_SIZE-1:0];
wire                   flag_out  = data_out_d[CFG_FRAME_SIZE];


assign overflow_out = (write_in && (counter_q == CFG_FIFO_DEPTH));        /* write and fifo full */


integer i;

//------------------------------------------------------------------------------------------------------------
//infer the FIFO   - no reset required

always @(posedge pclk)
 begin  
   for (i=0; i<CFG_FIFO_DEPTH; i=i+1)
      begin
         fifo_mem_q[i] <= fifo_mem_d[i];
      end
 end


//infer the registers and register the flags 
always @(posedge pclk or negedge aresetn)
   begin
   if ((!aresetn) || (!sresetn))
     begin
       rd_pointer_q   <= 0;
       wr_pointer_q   <= 0;
       counter_q      <= 0;
       full_out       <= 0;
       empty_out      <= 1;
       full_next_out  <= 0;
       empty_next_out <= 0;
     end
   else
     begin
       rd_pointer_q   <= rd_pointer_d;
       wr_pointer_q   <= wr_pointer_d;
       counter_q      <= counter_d;
       full_out       <= (counter_d == CFG_FIFO_DEPTH); //is next pointer equal to fifo length
       empty_out      <= (counter_d == 0);
       full_next_out  <= (counter_q == CFG_FIFO_DEPTH-1);
       empty_next_out <= (counter_q == 1);
     end
   end


integer j;

always @(*)
begin  
   for (j=0; j<CFG_FIFO_DEPTH; j=j+1)    // Hold old values
      begin
         fifo_mem_d[j] = fifo_mem_q[j];
      end

   if (write_in)
      begin
        if (counter_q != CFG_FIFO_DEPTH)
          begin
          fifo_mem_d[wr_pointer_q[4:0]][CFG_FRAME_SIZE-1:0] = data_in[CFG_FRAME_SIZE-1:0];
          fifo_mem_d[wr_pointer_q[4:0]][CFG_FRAME_SIZE] = flag_in;
          end
      end

   //Read - data out always available
   data_out_dx = fifo_mem_q[rd_pointer_q[4:0]];
end


// Perform extra read mux on Byte/Half wide reads
always @(*)
  begin
     // flag bits are zero if count zero
     data_out_d = data_out_dx[CFG_FRAME_SIZE:0];
     
     if (counter_q == 0) data_out_d[CFG_FRAME_SIZE] = 1'b0;

  end
   


// Pointers and Flags

always @(*)
   begin
   
     if (fiforst==1'b1)
     begin
        wr_pointer_d  = 5'b00000;
        rd_pointer_d  = 5'b00000;
        counter_d     = 6'b000000;
     end 
     else
     begin
       //defaults
       counter_d    = counter_q;
       rd_pointer_d = rd_pointer_q;
       wr_pointer_d = wr_pointer_q;
    
      if (read_in)
      begin
         if (counter_q != 0)   // ignore read when empty
         begin
            if (~write_in) //if not writing decrement count of the number of objects in fifo else count stays the same
               begin 
                  counter_d = counter_q - 1'b1;
               end
            if (rd_pointer_q == CFG_FIFO_DEPTH - 1)
              rd_pointer_d = 5'b00000;
            else   
              rd_pointer_d = rd_pointer_q + 1'b1; 
         end
            
      end //~read_n

      if (write_in)
      begin
         if (counter_q != CFG_FIFO_DEPTH) // ignore write when full
         begin
           if (~read_in)
            begin
               counter_d =  counter_q + 1'b1;
            end
            if (wr_pointer_q == CFG_FIFO_DEPTH-1)
              wr_pointer_d = 5'b00000;
            else
              wr_pointer_d = wr_pointer_q + 1'b1;
              
           end //~write_n
         end
     end
   end
      
wire [5:0] fifo_count = counter_q;

endmodule
