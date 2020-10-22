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

 wire [WWIDTH-1:0] wdata;
 wire we, re;
 reg  err_cnt;
 wire  wclk, rclk,reset;
 wire clk;
 wire [(logb2(RDEPTH)) : 0] rdcount;
 wire [(logb2(WDEPTH)) : 0] wrcount;
 wire [RWIDTH-1:0] rdata,rdata1;
/******************* External memory ****************************************/

 wire [(logb2(WDEPTH)-1) : 0] ext_waddr;
 wire [(logb2(RDEPTH)-1) : 0]  ext_raddr;
 wire [WWIDTH-1:0] ext_data;
 wire [RWIDTH-1:0] ext_rd;
 wire ext_we, ext_re;
 
/******************* Internal memory ****************************************/

 wire [(logb2(WDEPTH)-1) : 0] int_waddr;
 wire [(logb2(RDEPTH)-1) : 0]  int_raddr;
 wire [WWIDTH-1:0] int_data;
 wire [RWIDTH-1:0] int_rd;
 wire int_we, int_re;
 
/******************* Internal memory ****************************************/

 wire [(logb2(WDEPTH)-1) : 0] fifo_waddr;
 wire [(logb2(RDEPTH)-1) : 0]  fifo_raddr;

 integer total_error;
 wire SB_CORRECT;
 wire DB_DETECT;

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

assign fifo_waddr = (CTRL_TYPE != 1) ? int_waddr : ext_waddr; 
assign fifo_raddr = (CTRL_TYPE != 1) ? int_raddr  : ext_raddr; 

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

fifo_driver #( .CTRL_TYPE(CTRL_TYPE),
               .WRITE_DEPTH(WDEPTH),
               .WRITE_WIDTH(WWIDTH),
               .FULL_WRITE_DEPTH(logb2(WDEPTH)),
               .READ_DEPTH(RDEPTH),
               .READ_WIDTH(RWIDTH),
               .FULL_READ_DEPTH(logb2(RDEPTH)),
               .WE_POLARITY(0),
               .RE_POLARITY(0),
               .RESET_POLARITY(0),
               .RCLK_EDGE(1),
               .WCLK_EDGE(1),
               .PIPE(1),
               .ECC(0),
               .PREFETCH(0),
	       .ESTOP(1),
	       .FSTOP(1),
	       .SYNC(SYNC)
             )

     driver (
             
    .clk (clk),
    .wclk(wclk),
    .rclk(rclk),
    .waddr(fifo_waddr),
    .raddr(fifo_raddr),
    .full(full),
    .empty(empty),
    .q(rdata),
    .dvld(dvld),
    .reset(reset),
    .we(we),
    .re(re),
    .wdata(wdata)

  );
assign rdata = (CTRL_TYPE == 1) ? ext_rd : int_rd ;
fifo_monitor #(
                  .SYNC(SYNC),
                  .WRITE_WIDTH(WWIDTH),    
                  .WRITE_DEPTH(logb2(WDEPTH)),
                  .FULL_WRITE_DEPTH(WDEPTH),
                  .READ_WIDTH(RWIDTH),      
                  .READ_DEPTH(logb2(RDEPTH)),
                  .FULL_READ_DEPTH(RDEPTH), 
                  .AFVAL(AFVAL),           
                  .AEVAL(AEVAL),
                  .AE_STATIC_EN(AE_STATIC_EN),
                  .AF_STATIC_EN(AF_STATIC_EN),	  
                  .PIPE(1),           
                  .ESTOP(1),           
                  .FSTOP(1),
                  .OVERFLOW_EN      (OVERFLOW_EN    ),
                  .UNDERFLOW_EN     (UNDERFLOW_EN   ),
                  .WRCNT_EN         (WRCNT_EN       ),
                  .RDCNT_EN         (RDCNT_EN       ),
                  .RCLK_EDGE(1),
                  .WCLK_EDGE(1),
                  .RESET_POLARITY(0),
                  .READ_DVALID(READ_DVALID),      
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
adc_fft_if_COREFIFO_0_COREFIFO #(

     .FAMILY(FAMILY),
     .SYNC(SYNC),
     .RCLK_EDGE(1),
     .WCLK_EDGE(1),
     .RE_POLARITY(0),
     .RESET_POLARITY(0),
     .WE_POLARITY(0),
     .RWIDTH(RWIDTH),
     .WWIDTH(WWIDTH),
     .RDEPTH(RDEPTH),
     .WDEPTH(WDEPTH),
     .READ_DVALID(READ_DVALID),
     .WRITE_ACK(WRITE_ACK),
     .CTRL_TYPE(CTRL_TYPE),
     .ESTOP(1),
     .FSTOP(1),
     .AE_STATIC_EN(AE_STATIC_EN),
     .AF_STATIC_EN(AF_STATIC_EN),
     .AEVAL(AEVAL),
     .AFVAL(AFVAL),
     .PIPE(1),
     .ECC(0),
     .PREFETCH(0),
     .OVERFLOW_EN      (OVERFLOW_EN    ),
     .UNDERFLOW_EN     (UNDERFLOW_EN   ),
     .WRCNT_EN         (WRCNT_EN       ),
     .RDCNT_EN         (RDCNT_EN       )
      )

 uut_fifo (

       .CLK(clk )
      ,.WCLOCK(wclk)
      ,.RCLOCK(rclk)

     ,.RESET(reset)

      ,.DATA(wdata)
      ,.Q(rdata1)
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
     ,.SB_CORRECT(SB_CORRECT)
     ,.DB_DETECT(DB_DETECT)

 );

 generate
  if (CTRL_TYPE == 1) begin

g4_dp_ext_mem  #(
                 .SYNC(SYNC),
                 .RAM_WW(WWIDTH),
                 .RAM_RW(RWIDTH),
                 .RAM_WD(logb2(WDEPTH)),
                 .RAM_RD(logb2(RDEPTH)),
                 .READ_ADDRESS_END(RDEPTH),
                 .WRITE_ADDRESS_END(WDEPTH),
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
end
else begin

g4_dp_ext_mem  #(
                 .SYNC(SYNC),
                 .RAM_WW(WWIDTH),
                 .RAM_RW(RWIDTH),
                 .RAM_WD(logb2(WDEPTH)),
                 .RAM_RD(logb2(RDEPTH)),
                 .READ_ADDRESS_END(RDEPTH),
                 .WRITE_ADDRESS_END(WDEPTH),
                 .WRITE_CLK(1),
                 .READ_CLK(1),
                 .WRITE_ENABLE(0),
                 .READ_ENABLE(0),
                 .RESET_POLARITY(0),
                 .PIPE(1)
                )

     int_mem (
                .clk(clk),
                .wclk(wclk),
                .rclk(rclk),
                .rst_n(reset),
                .waddr(int_waddr),
                .raddr(int_raddr),
                .data(wdata),
                .we(int_we),
                .re(int_re),
                .q(int_rd)
             );
end
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
  
$display ("Test Seq:1: WRITE OP in FIFO ");

   repeat(2) @(negedge `WCLK);
   `FIFO_DRIVER.push(WDEPTH-1);
   `FIFO_DRIVER.write_deassert;

   repeat(10) @(negedge `WCLK);


$display ("Test Seq:1: READ OP in FIFO ");

   repeat(2) @(negedge `RCLK);

    `FIFO_DRIVER.pop(RDEPTH-1);
    `FIFO_DRIVER.read_deassert;
   repeat(20) @(negedge `RCLK);


   repeat(20) @(negedge `RCLK);

$display (" RESET FIIFO ");

   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;

    repeat (10)@(posedge `WCLK);
/*$display (" Test Seq:3: All Flags check during WRITING FIFO ");

      `FIFO_DRIVER.push(WDEPTH-1);
      `FIFO_DRIVER.write_deassert;

    repeat (2)@(posedge `WCLK);
   `FIFO_DRIVER.push(1);
   `FIFO_DRIVER.write_deassert;

    repeat (2)@(posedge `WCLK);

$display (" Test Seq:4: All Flags check during READ FIFO ");

   repeat(2) @(negedge `RCLK);
     `FIFO_DRIVER.pop(RDEPTH-1);
      `FIFO_DRIVER.read_deassert;
       repeat(3) @(posedge `RCLK);

$display (" RESET FIFO ");

////////////////////////////////////////////////

   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;

////////////////////////////////////////////////
*/
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

   `FIFO_DRIVER.push(WDEPTH-1);
   `FIFO_DRIVER.write_deassert;

   repeat(10) @(negedge `WCLK);
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2.2:FULL READ from FIFO \n");
$display ("//////////////////////////////////////////////// \n");

   repeat(2) @(negedge `RCLK);

   if (PIPE == 2) begin
    `FIFO_DRIVER.pop(RDEPTH-2);
   end
   else begin
    `FIFO_DRIVER.pop(RDEPTH-2);
   end
    `FIFO_DRIVER.read_deassert;
   repeat(10) @(negedge `RCLK);

$display ("*****************   RESET FIFO  ****************** \n\n");

   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;

/*
 if(OVERFLOW_EN == 1) begin
 $display ("////////////////////////////////////////////////// \n");
$display (" Test Seq:2: WRITE wdepth-1 in FIFO  \n");
$display ("////////////////////////////////////////////////// \n");

      `FIFO_DRIVER.push(WDEPTH-2);
      `FIFO_DRIVER.write_deassert;

    repeat (10)@(posedge `WCLK);
$display ("////////////////////////////////////////////////// \n");
$display (" Test Seq:2.1: OVERFLOW DURING WRITE IN FIFO \n");
$display ("////////////////////////////////////////////////// \n");

      `FIFO_DRIVER.push(1);
      `FIFO_DRIVER.write_deassert;
    repeat (2)@(posedge `WCLK);

$display ("*****************   RESET FIFO  ****************** \n\n");
   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;
end



if(UNDERFLOW_EN == 1) begin

$display (" Test Seq:3: FULL WRITE IN FIFO  \n");
$display ("////////////////////////////////////////////////// \n");

      `FIFO_DRIVER.push(WDEPTH-1);
      `FIFO_DRIVER.write_deassert;

    repeat (10)@(posedge `WCLK);

$display ("////////////////////////////////////////////////// \n");
$display (" Test Seq:3: FULL READ FROM FIFO \n");
$display ("////////////////////////////////////////////////// \n");

   repeat(2) @(negedge `RCLK);
     `FIFO_DRIVER.pop(RDEPTH-2);
     `FIFO_DRIVER.read_deassert;

$display ("//////////////////////////////////////////////////// \n");
$display (" Test Seq:3: UNDERFLOW Flag DURING READ FROM FIFO \n");
$display ("//////////////////////////////////////////////////// \n");
       repeat(3) @(posedge `RCLK);
   if (PIPE !==2 ) begin
     `FIFO_DRIVER.pop(2);
     `FIFO_DRIVER.read_deassert;
       repeat(3) @(posedge `RCLK);

   end
  
$display ("*****************   RESET FIFO  ****************** \n\n");
   `RESET_ASSERTED;
   repeat(2) @(negedge `WCLK);
   `RESET_NEGATED;

end
*/
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

   `FIFO_DRIVER.push(WDEPTH-1);
   `FIFO_DRIVER.write_deassert;

   repeat(10) @(negedge `CLK);
$display ("//////////////////////////////////////////////// \n");
$display ("Test Seq:2.2:FULL READ from FIFO \n");
$display ("//////////////////////////////////////////////// \n");

   repeat(2) @(negedge `CLK);

    `FIFO_DRIVER.pop(RDEPTH-2);
    `FIFO_DRIVER.read_deassert;
   repeat(10) @(negedge `CLK);

$display ("*****************   RESET FIFO  ****************** \n\n");

   `RESET_ASSERTED;
   repeat(2) @(negedge `CLK);
   `RESET_NEGATED;

/*
 if(OVERFLOW_EN == 1) begin
 $display ("////////////////////////////////////////////////// \n");
$display (" Test Seq:2: WRITE wdepth-1 in FIFO  \n");
$display ("////////////////////////////////////////////////// \n");

      `FIFO_DRIVER.push(WDEPTH-2);
      `FIFO_DRIVER.write_deassert;

    repeat (10)@(posedge `CLK);

$display ("////////////////////////////////////////////////// \n");
$display (" Test Seq:2.1: OVERFLOW DURING WRITE IN FIFO \n");
$display ("////////////////////////////////////////////////// \n");

      `FIFO_DRIVER.push(1);
      `FIFO_DRIVER.write_deassert;
    repeat (2)@(posedge `CLK);

$display ("*****************   RESET FIFO  ****************** \n\n");
   `RESET_ASSERTED;
   repeat(2) @(negedge `CLK);
   `RESET_NEGATED;
end



if(UNDERFLOW_EN == 1) begin

$display (" Test Seq:3: FULL WRITE IN FIFO  \n");
$display ("////////////////////////////////////////////////// \n");

      `FIFO_DRIVER.push(WDEPTH-1);
      `FIFO_DRIVER.write_deassert;

    repeat (10)@(posedge `CLK);

$display ("////////////////////////////////////////////////// \n");
$display (" Test Seq:3.1: All Flags check during READ FIFO \n");
$display ("////////////////////////////////////////////////// \n");

   repeat(2) @(negedge `CLK);
     `FIFO_DRIVER.pop(RDEPTH-1);
     `FIFO_DRIVER.read_deassert;

$display ("//////////////////////////////////////////////////// \n");
$display (" Test Seq:3.2: UNDERFLOW Flag DURING READ FROM FIFO \n");
$display ("//////////////////////////////////////////////////// \n");
       repeat(3) @(posedge `CLK);
     `FIFO_DRIVER.pop(3);
     `FIFO_DRIVER.read_deassert;
       repeat(3) @(posedge `CLK);
*/
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
//`WCLK_ON;

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
 total_error = (`FIFO_MONITOR.err_cnt + `FIFO_DRIVER.rderr_cnt);
  $display ("----------------------------------------------------");
  $display ("        REGRESSION FAIL!!                           ");
  //$display ("        TOTAL NUMBER OF ERROR = %d                  ",`FIFO_MONITOR.total_error);
  $display ("----------------------------------------------------");
  $finish;
end
else
  $display ("----------------------------------------------------");
  $display ("        REGRESSION PASS!!                           ");
  $display ("        All Tests PASSED!!                          ");
  $display ("----------------------------------------------------\n");
   repeat(10) @(negedge `WCLK);

$finish;

end


endmodule


