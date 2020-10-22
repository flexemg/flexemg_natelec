// ****************************************************************************
// GENERIC TEST BENCH TO TEST FIFO
// ****************************************************************************
`timescale 1 ns / 100 ps

module testbench();

`include "coreparameters.v"
`include "top_define.v"
parameter  CLKPERIOD  = 15;
parameter  WCLKPERIOD = 15;
parameter  RCLKPERIOD = 15;
parameter  WDEPTH_TB  = (CTRL_TYPE == 2 || CTRL_TYPE == 1) ? 1024 : 64;
parameter  RDEPTH_TB  = (CTRL_TYPE == 2 || CTRL_TYPE == 1) ? 1024 : 64;
parameter  WWIDTH_TB  = 18;
parameter  RWIDTH_TB  = 18;
parameter  CTRL_TYPE_TB  = 1;

 `define  DLY 1
 `define  MAXDEPTH 18

  function [31:0] logb2;
      input integer x;
      integer tmp, res;
      begin
         tmp = 1;
         res = 0;
	 if(x == 1) begin
           logb2 = 1;
	 end
	 else begin
           while(tmp < x) begin
              tmp = tmp * 2;
              res = res + 1;
           end
	   logb2 = res;
         end
      end
   endfunction // logb2

/******************* TESTBENCH VARIABLES FOR DRIVING THE DESIGN INSTANTIATION *****************/ 

 wire [17:0] wdata;
 wire we, re;
 reg  err_cnt;
 wire  wclk, rclk,reset;
 wire clk;
 wire [10 : 0] rdcount;
 wire [10 : 0] wrcount;
 wire [17:0] rdata;
 wire [17:0] fifo_rdata;
/******************* External memory ****************************************/

 wire [(logb2(1024)-1) : 0] ext_waddr;
 wire [(logb2(1024)-1) : 0]  ext_raddr;
 wire [17:0] ext_data;
 wire [17:0] ext_rd;
 wire ext_we, ext_re;
 
/******************* Internal memory ****************************************/

 wire [9 : 0] int_waddr;
 wire [9 : 0]  int_raddr;
 wire int_we, int_re;
 
/******************* Internal memory ****************************************/

 wire [9 : 0] fifo_waddr;
 wire [9 : 0] fifo_raddr;
 wire [17: 0] fifo_rd;

// integer      total_error;

// ****************************************************************************
// DIFFERENCE FUNCTION
// ****************************************************************************

function integer diff;
   input integer a;
   input integer b;
   input integer addrwidth;
   begin
       if ( a > 0 || b==0 )
           diff = a - b;
       else 
           diff = ((2<<addrwidth)) - b;
   end
endfunction
initial
begin
  err_cnt = 0;
end

assign int_waddr = (CTRL_TYPE != 1) ? `DUT.fifo_MEMWADDR : 0; 
assign int_raddr = (CTRL_TYPE != 1) ? `DUT.fifo_MEMRADDR : 0; 
assign int_we = (CTRL_TYPE != 1) ? `DUT.fifo_MEMWE : 0; 
assign int_re = (CTRL_TYPE != 1) ? `DUT.fifo_MEMRE : 0; 

assign fifo_waddr = ext_waddr; 
assign fifo_raddr = ext_raddr; 
assign fifo_rd    = ext_rd; 

//`include "fifo_inst.v" 
clock_driver #(
              .CLKPERIOD(CLKPERIOD),
              .WCLKPERIOD(WCLKPERIOD),
              .RCLKPERIOD(RCLKPERIOD)
            )


clk_driver (
    .clk1(clk),
    .wclk1(wclk),
    .rclk1(rclk)
  );

fifo_driver #( 
               .WRITE_DEPTH(1024),
               .WRITE_WIDTH(18),
               .FULL_WRITE_DEPTH(logb2(1024)),
               .READ_DEPTH(1024),
               .READ_WIDTH(18),
               .FULL_READ_DEPTH(logb2(1024)),
               .WE_POLARITY(0),
               .RE_POLARITY(0),
               .RESET_POLARITY(0),
               .RCLK_EDGE(1),
               .WCLK_EDGE(1),
               .PIPE(1),
               .PREFETCH(PREFETCH),
	       .FWFT(FWFT),
	       .ESTOP(1),
	       .FSTOP(1),
	       .SYNC(SYNC)
             )

     driver (
             
    .clk (clk),
    .wclk(wclk),
    .rclk(rclk),
    .waddr(fifo_waddr), //ext_waddr),
    .raddr(fifo_raddr),//ext_raddr),
    .full(full),
    .empty(empty),
    .q(fifo_rdata),
    .dvld(dvld),
    .reset(reset),
    .we(we),
    .re(re),
    .wdata(wdata)

  );

  assign fifo_rdata = (PREFETCH == 1 || FWFT == 1) ? rdata : fifo_rd;

fifo_monitor #(
                  .SYNC(SYNC),
                  .WRITE_WIDTH(18),    
                  .WRITE_DEPTH(logb2(1024)),
                  .FULL_WRITE_DEPTH(1024),
                  .READ_WIDTH(18),      
                  .READ_DEPTH(logb2(1024)),
                  .FULL_READ_DEPTH(1024), 
                  .AFVAL(1020),           
                  .AEVAL(4),
                  .AE_STATIC_EN(1),
                  .AF_STATIC_EN(1),	  
                  .PIPE(1),           
                  .PREFETCH(PREFETCH),           
                  .FWFT(FWFT),           
                  .ESTOP(1),           
                  .FSTOP(1),
                  .OVERFLOW_EN      (0    ),
                  .UNDERFLOW_EN     (0   ),
                  .WRCNT_EN         (0       ),
                  .RDCNT_EN         (0       ),
                  .RCLK_EDGE(1),
                  .WCLK_EDGE(1),
                  .RESET_POLARITY(0),
                  .READ_DVALID(0),      
                  .RE_POLARITY(0),
                  .WE_POLARITY(0)
                  )

          monitor    (
                      .clk(clk),
                      .rclk(rclk),
                      .wclk(wclk),
                      .reset(reset),
                      .we(we),
                      .re(re),

                      .wcnt(wrcount),
                      .rcnt(rdcount),

                      .full(full),
                      .afull(afull),
                      .empty(empty),
                      .aempty(aempty),
                      .underflow(underflow),
                      .overflow(overflow),
		      .wack(wack),
		      .dvld(dvld)
                       );


//`include "design_instance.v"
ACKFIFO_ACKFIFO_0_COREFIFO #(

     .FAMILY(19),
     .SYNC(SYNC),
     .RCLK_EDGE(1'b1),
     .WCLK_EDGE(1'b1),
     .RE_POLARITY(1'b0),
     .RESET_POLARITY(1'b0),
     .WE_POLARITY(1'b0),
     .RWIDTH(18),
     .WWIDTH(18),
     .RDEPTH(1024),
     .WDEPTH(1024),
     .READ_DVALID(1'b1),
     .WRITE_ACK(1'b1),
     .CTRL_TYPE(1'b1),
     .ESTOP(1'b1),
     .FSTOP(1'b1),
     .AE_STATIC_EN(1'b1),
     .AF_STATIC_EN(1'b1),
     .AEVAL(4    ),
     .AFVAL(1020 ),
     .PIPE (1'b1 ),
     .PREFETCH(PREFETCH),
     .FWFT(FWFT),
     .OVERFLOW_EN      (1'b0       ),
     .UNDERFLOW_EN     (1'b0       ),
     .WRCNT_EN         (1'b0       ),
     .RDCNT_EN         (1'b0       )
      )

 uut_fifo (

       .CLK(clk )
      ,.WCLOCK(wclk)
      ,.RCLOCK(rclk)

     ,.RESET(reset)

      ,.DATA(wdata)
      ,.Q(rdata)
      ,.WE(we)
      ,.RE(re)
     ,.FULL(full)
     ,.EMPTY(empty)
     ,.AFULL(afull)
     ,.AEMPTY(aempty)
     ,.OVERFLOW(overflow)
     ,.UNDERFLOW(underflow)
     ,.WACK(wack)
     ,.DVLD(dvld)
     ,.WRCNT(wrcount)
     ,.RDCNT(rdcount)
     ,.MEMWE(ext_we)
     ,.MEMRE(ext_re)
     ,.MEMWADDR(ext_waddr)
     ,.MEMRADDR(ext_raddr)
     ,.MEMWD(ext_data)
     ,.MEMRD(ext_rd)

 );

 generate
//  if (CTRL_TYPE == 1) begin

g4_dp_ext_mem  #(
                 .SYNC(SYNC),
                 .RAM_WW(18),
                 .RAM_RW(18),
                 .RAM_WD(logb2(1024)),
                 .RAM_RD(logb2(1024)),
                 .READ_ADDRESS_END(1024),
                 .WRITE_ADDRESS_END(1024),
                 .WRITE_CLK(1),
                 .READ_CLK(1),
                 .WRITE_ENABLE(0),
                 .READ_ENABLE(0),
                 .PIPE(1),
                 .RESET_POLARITY(0)
                )

     ext_mem (
                .clk(clk),
                .wclk(wclk),
                .rclk(rclk),
                .rst_n(reset),
                .waddr(ext_waddr),
                .raddr(ext_raddr),
                .data(ext_data),
                .we(ext_we),
                .re(ext_re),
                .q(ext_rd)
             );

endgenerate

//`include "fifo_POR.v"
task fifo_POR;
begin
  
   `RESET_ASSERTED;
   `FIFO_MONITOR.check_full_flag(1'b0);
   `FIFO_MONITOR.check_afull_flag(1'b0);
   `FIFO_MONITOR.check_empty_flag(1'b1);
   `FIFO_MONITOR.check_aempty_flag(1'b1);
   repeat(10) @(negedge `WCLK);

   `RESET_NEGATED;
$display ("--------------------End-POR-Testcase--------------------------------");

end
endtask

//`include "fifo_basic_RW_test.v"
task fifo_basic_RW_test;

begin

$display (" ");
$display ("-------------------------------------- ");
$display ("Microsemi CoreFIFO Testbench v2.2 ");
$display ("-------------------------------------- ");
$display (" ");
$display ("Test Seq:1: WRITE OP in FIFO ");

   repeat(2) @(negedge `WCLK);
   `FIFO_DRIVER.push(1023);
   `FIFO_DRIVER.write_deassert;

   repeat(10) @(negedge `WCLK);
   repeat(10) @(negedge `WCLK);  // Jun13


$display ("Test Seq:1: READ OP in FIFO ");

   repeat(2) @(negedge `RCLK);

    `FIFO_DRIVER.pop(1023);
    `FIFO_DRIVER.read_deassert;
   repeat(20) @(negedge `RCLK);


   repeat(20) @(negedge `RCLK);

$display (" RESET FIFO ");

   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;

    repeat (10)@(posedge `WCLK);

$display ("--------------------End-Basic RW-Testcase--------------------------------");
end

endtask

task async_fifo_basic_RW_test;
begin
  
$display ("************ RESET FIFO  ************* \n\n");
   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;
   repeat(10) @(negedge `RCLK);

$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2: FULL WRITE AND READ FIFO  \n");
$display ("//////////////////////////////////////////////// \n");

   repeat(5) @(negedge `WCLK);
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2.1: FULL WRITE IN FIFO  \n");
$display ("//////////////////////////////////////////////// \n");

   `FIFO_DRIVER.push(1023);
   `FIFO_DRIVER.write_deassert;

   repeat(10) @(negedge `WCLK);
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2.2:FULL READ from FIFO \n");
$display ("//////////////////////////////////////////////// \n");

   repeat(2) @(negedge `RCLK);

   if (PIPE == 2) begin
    `FIFO_DRIVER.pop(1021);
   end
   else begin
    `FIFO_DRIVER.pop(1023);
   end
    `FIFO_DRIVER.read_deassert;
   repeat(10) @(negedge `RCLK);

$display ("*****************   RESET FIFO  ****************** \n\n");

   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;

end

endtask


task sync_fifo_basic_RW_test;
begin
  
$display ("************ RESET FIFO  ************* \n\n");
   `RESET_ASSERTED;
   repeat(2) @(negedge `CLK);
   `RESET_NEGATED;
   repeat(10) @(negedge `CLK);
 
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2: FULL WRITE AND READ FIFO  \n");
$display ("//////////////////////////////////////////////// \n");

   repeat(5) @(negedge `CLK);
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2.1: FULL WRITE IN FIFO  \n");
$display ("//////////////////////////////////////////////// \n");

   `FIFO_DRIVER.push(1023);
   `FIFO_DRIVER.write_deassert;

   repeat(10) @(negedge `CLK);
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2.2:FULL READ from FIFO \n");
$display ("//////////////////////////////////////////////// \n");

   repeat(2) @(negedge `CLK);

    `FIFO_DRIVER.pop(1023);
    `FIFO_DRIVER.read_deassert;
   repeat(10) @(negedge `CLK);

$display ("*****************   RESET FIFO  ****************** \n\n");

   `RESET_ASSERTED;
   repeat(2) @(negedge `CLK);
   `RESET_NEGATED;

$display ("*****************   RESET FIFO  ****************** \n\n");
   `RESET_ASSERTED;
   repeat(2) @(negedge `CLK);
   `RESET_NEGATED;

end

endtask


//`include "regression.v"

initial begin

$display (" Flag status during RESET condition \n");
#100

fifo_POR;
$display ("\n\n");
$display ("----------------------------------------------------");
$display ("         Testcase 1 :FIFO_POR_TEST                  ");
$display ("----------------------------------------------------");


if(SYNC == 0) begin
$display ("\n\n");
$display ("----------------------------------------------------");
$display ("        Testcase 2 : ASYNC FIFO_BASIC_RW_TEST             ");
$display ("----------------------------------------------------\n");
async_fifo_basic_RW_test;
end
else if(SYNC == 1) begin
$display ("\n\n");
$display ("----------------------------------------------------");
$display ("        Testcase 2 : SYNC FIFO_BASIC_RW_TEST             ");
$display ("----------------------------------------------------\n");
sync_fifo_basic_RW_test;
end

if (`FIFO_MONITOR.err_cnt >0 || `FIFO_DRIVER.rderr_cnt >0) begin
 //total_error = (`FIFO_MONITOR.err_cnt + `FIFO_DRIVER.rderr_cnt);
  $display ("----------------------------------------------------");
  $display ("        REGRESSION FAIL!!                           ");
  $display ("----------------------------------------------------");
end
else begin
  $display ("----------------------------------------------------");
  $display ("        REGRESSION PASS!!                           ");
  $display ("        All Tests PASSED!!                          ");
  $display ("----------------------------------------------------\n");
end

   repeat(10) @(negedge `WCLK);

$finish;

end


endmodule


