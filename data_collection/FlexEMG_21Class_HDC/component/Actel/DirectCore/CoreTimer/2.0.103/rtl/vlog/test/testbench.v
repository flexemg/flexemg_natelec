`timescale 1ns/1ns
// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2015 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
//
// CoreTimer User Testbench
//
//
// SVN Revision Information:
// SVN $Revision: 23762 $
// SVN $Date: 2014-11-11 08:01:54 -0800 (Tue, 11 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
//
// *********************************************************************/ 
module testbench();

localparam APB_DWIDTH = 32;
localparam COUNTER_WIDTH = 32;
localparam INTERRUPT_LEVEL = 1;
localparam FAMILY = 19;
localparam APB_HALF_PERIOD = 10;    // Generates a 50 MHz clock

reg  SYSCLK;      
reg  SYSRSTN;     
wire PCLK;        
wire PRESETN;     
wire [31:0] PADDR;      
wire PENABLE;     
wire PWRITE;      
wire [APB_DWIDTH-1:0] PWDATA;     
wire [APB_DWIDTH-1:0] PRDATA;
wire [15:0] PSEL;
         
wire TIMINT;
wire [31:0]TIMINT_VEC = {31'd0,TIMINT};
wire [255:0] INTERRUPT; 
wire FINISHED;  
wire FAILED;
wire Logic0 = 1'b0;
wire Logic1 = 1'b1; 

// ********************************************************************************
// Clocks and Reset


initial
 begin
  SYSRSTN <= 1'b0;
  #100;
  SYSRSTN <= 1'b1;
 end

// Clock is 50MHz
always
 begin
   SYSCLK <= 1'b0;
   #APB_HALF_PERIOD;
   SYSCLK <= 1'b1;
   #APB_HALF_PERIOD;
 end
// ********************************************************************************
// APB Master  

BFM_APB  #(.VECTFILE     ("user_tb.vec") )
     UBFM (.SYSCLK       (SYSCLK), 
           .SYSRSTN      (SYSRSTN), 
           .PCLK         (PCLK), 
           .PRESETN      (PRESETN), 
           .PADDR        (PADDR), 
           .PENABLE      (PENABLE), 
           .PWRITE       (PWRITE), 
           .PWDATA       (PWDATA), 
           .PRDATA       (PRDATA), 
           .PREADY       (Logic1), 
           .PSLVERR      (Logic0), 
           .PSEL         (PSEL), 
           .INTERRUPT    (INTERRUPT),
           .GP_OUT       (), 
           .GP_IN        (TIMINT_VEC), 
           .EXT_WR       (), 
           .EXT_RD       (), 
           .EXT_ADDR     (), 
           .EXT_DATA     (), 
           .EXT_WAIT     (Logic0), 
           .FINISHED     (FINISHED), 
           .FAILED       (FAILED)
        );    
// ********************************************************************************
// CoreTimer Instantiation
  
CoreTimer #(
    .WIDTH              (COUNTER_WIDTH),
    .INTACTIVEH         (INTERRUPT_LEVEL),
    .FAMILY             (FAMILY)
)UTIM(
        .PCLK           (PCLK),
        .PRESETn        (PRESETN),
        .PENABLE        (PENABLE),
        .PSEL           (PSEL[0]),
        .PADDR          (PADDR[4:2]),
        .PWRITE         (PWRITE),
        .PWDATA         (PWDATA),
        .PRDATA         (PRDATA),
        .TIMINT         (TIMINT)
    );        
    
endmodule