module g4_dp_ext_mem  (
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

generate
if (RAM_RW > RAM_WW) begin

MEM_WltR #(
                                    .SYNC(SYNC),
                                    .RAM_WW(RAM_WW),
                                    .RAM_RW(RAM_RW),
                                    .RAM_WD(RAM_WD),
                                    .RAM_RD(RAM_RD),
                                    .READ_ADDRESS_END(READ_ADDRESS_END),
                                    .WRITE_ADDRESS_END(WRITE_ADDRESS_END),
                                    .WRITE_CLK(WRITE_CLK),
                                    .READ_CLK(READ_CLK),
                                    .WRITE_ENABLE(WRITE_ENABLE),
                                    .READ_ENABLE(READ_ENABLE),
                                    .RESET_POLARITY(RESET_POLARITY),
                                    .PIPE(PIPE)
         )
         inst0 (.clk(clk),.wclk(wclk),.rclk(rclk),.rst_n(rst_n),.waddr(waddr),.raddr(raddr),.data(data),.we(we),.re(re),.q(q));

end       
else if (RAM_RW < RAM_WW) begin

MEM_WgtR #(
                                    .SYNC(SYNC),
                                    .RAM_WW(RAM_WW),
                                    .RAM_RW(RAM_RW),
                                    .RAM_WD(RAM_WD),
                                    .RAM_RD(RAM_RD),
                                    .READ_ADDRESS_END(READ_ADDRESS_END),
                                    .WRITE_ADDRESS_END(WRITE_ADDRESS_END),
                                    .WRITE_CLK(WRITE_CLK),
                                    .READ_CLK(READ_CLK),
                                    .WRITE_ENABLE(WRITE_ENABLE),
                                    .READ_ENABLE(READ_ENABLE),
                                    .RESET_POLARITY(RESET_POLARITY),
                                    .PIPE(PIPE)
        )
         inst1 (.clk(clk),.wclk(wclk),.rclk(rclk),.rst_n(rst_n),.waddr(waddr),.raddr(raddr),.data(data),.we(we),.re(re),.q(q));

end       
else if (RAM_RW == RAM_WW) begin
MEM_WeqR # (
                                    .SYNC(SYNC),
                                    .RAM_WW(RAM_WW),
                                    .RAM_RW(RAM_RW),
                                    .RAM_WD(RAM_WD),
                                    .RAM_RD(RAM_RD),
                                    .READ_ADDRESS_END(READ_ADDRESS_END),
                                    .WRITE_ADDRESS_END(WRITE_ADDRESS_END),
                                    .WRITE_CLK(WRITE_CLK),
                                    .READ_CLK(READ_CLK),
                                    .WRITE_ENABLE(WRITE_ENABLE),
                                    .READ_ENABLE(READ_ENABLE),
                                    .RESET_POLARITY(RESET_POLARITY),
                                    .PIPE(PIPE)
          )
          inst2 (.clk(clk),.wclk(wclk),.rclk(rclk),.rst_n(rst_n),.waddr(waddr),.raddr(raddr),.data(data),.we(we),.re(re),.q(q));

end
endgenerate
endmodule



