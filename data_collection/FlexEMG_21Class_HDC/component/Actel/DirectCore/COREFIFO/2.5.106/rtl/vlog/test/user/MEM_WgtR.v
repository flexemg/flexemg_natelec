module MEM_WgtR  (
          clk,
          wclk,
          rclk,
          rst_n,
          waddr,
          raddr,
          data,
          we,
          re,
          q
          );
          
// Memory parameters
parameter SYNC   = 0;    
parameter RAM_RW = 18;    
parameter RAM_WW = 18;    
parameter RAM_WD = 10; 
parameter RAM_RD = 10; 
parameter WRITE_ADDRESS_END = 1024;   
parameter READ_ADDRESS_END = 1024;   

parameter WRITE_CLK    = 1;
parameter READ_CLK     = 1;
parameter WRITE_ENABLE = 1;
parameter READ_ENABLE  = 1;
parameter RESET_POLARITY  = 0;
parameter PIPE  = 1;

// local inputs
input clk;          
input wclk;          
input rclk;          
input rst_n;      

// local inputs - memory functional bus
input [RAM_WD-1:0] waddr;
input [RAM_WW-1:0] data;

input [RAM_RD-1:0] raddr;
input we;
input re;


//OUTPUTS
//======
output [RAM_RW-1:0] q;

wire wclk_int,rclk_int,we_int,re_int, rst_int;
wire f_wclk, f_rclk;
  
// ** MEM DECLARATION **
reg [RAM_WW-1:0] MEM [WRITE_ADDRESS_END-1:0];
reg [RAM_RW-1:0] MEMR [READ_ADDRESS_END-1:0];
integer i;
reg [RAM_RW-1:0] q;

assign f_wclk  = SYNC ? clk : wclk;
assign f_rclk  = SYNC ? clk : rclk;

assign wclk_int  = WRITE_CLK ? f_wclk  : ~f_wclk;
assign rclk_int  = READ_CLK ?  f_rclk  : ~f_rclk;

assign we_int  = we;
assign re_int  = re;

assign rst_int  = RESET_POLARITY  ? ~rst_n : rst_n;



/*
assign wclk_int  = wclk;
assign rclk_int  = rclk;

*/

initial
  begin
    q = {RAM_RW{1'b0}};
  end

always @ (posedge wclk_int or negedge rst_int)
  begin
    if (~rst_int) begin
    end
    else
    begin
       if (we_int=== 1'b1)
       begin
          MEM[waddr] = data;
          /*if (RAM_WW > RAM_RW) begin
             MEMR[waddr*2] = data[RAM_RW-1:0];
             MEMR[waddr*2+1] = data[RAM_WW-1:RAM_RW];
          end*/
       end
    end

  end

always @ (posedge rclk_int or negedge rst_int)
  begin
    if (~rst_int)
     begin
       q <= {RAM_RD{1'b0}};
     end
     else
     begin
       if (re_int === 1'b1)
       begin
          // if (RAM_WW > RAM_RW) begin
            //q <= MEMR[raddr];
              if (raddr%2 ==0)
                q <= MEM[raddr/2][RAM_RW-1 :0];
              else
                q <= MEM[raddr/2][(RAM_WW-1):RAM_RW];
            
       end
     end
  end
endmodule



