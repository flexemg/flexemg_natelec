// This is automatically generated file 

`timescale 1 ns/100 ps
module adc_fft_if_COREFIFO_0_ram_wrapper(
WDATA,  
WADDR,  
WEN,    
REN,    
RDATA,  
RADDR,  
RESET_N,
CLOCK,  
WCLOCK, 
A_SB_CORRECT, 
B_SB_CORRECT, 
A_DB_DETECT, 
B_DB_DETECT, 
RCLOCK  
);      
  

// --------------------------------------------------------------------------
// PARAMETER Declaration
// --------------------------------------------------------------------------
parameter                RWIDTH        = 32;  // Read  port Data Width
parameter                WWIDTH        = 32;  // Write port Data Width
parameter                RDEPTH        = 128; // Read  port Data Depth
parameter                WDEPTH        = 128; // Write port Data Depth
parameter                SYNC          = 0;   // Synchronous or Asynchronous operation | 1 - Single Clock, 0 - Dual clock
parameter                PIPE          = 1;   // Pipeline read data out
parameter                CTRL_TYPE     = 1;   // Controller only options | 1 - Controller Only, 2 - RAM1Kx18, 3 - RAM64x18
// --------------------------------------------------------------------------
// I/O Declaration
// --------------------------------------------------------------------------
input [WWIDTH - 1 : 0]   WDATA;  
input [(WDEPTH - 1) : 0] WADDR;  
input                    WEN;    
input                    REN;    
output [RWIDTH - 1 : 0]  RDATA;  
input [(RDEPTH - 1) : 0] RADDR;  
input                    RESET_N;
output                   A_SB_CORRECT; 
output                   B_SB_CORRECT; 
output                   A_DB_DETECT; 
output                   B_DB_DETECT; 
input                    WCLOCK; 
input                    RCLOCK; 
input                    CLOCK;  
  

adc_fft_if_COREFIFO_0_LSRAM_top L3_syncnonpipe (
.WD    (WDATA   ),
.WADDR (WADDR   ),
.WEN   (WEN     ),
.RD    (RDATA   ),
.RADDR (RADDR   ),
.REN   (REN     ),
.CLK   (CLOCK   ) 
);


endmodule
