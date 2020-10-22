
`timescale 1ns / 100ps

module fifo_monitor (
                       clk,
                       rclk,
                       wclk,
                       reset,
                       we,
                       re,

                       wcnt,
                       rcnt,

                       full,
                       afull,
                       empty,
                       aempty,
                       underflow,
                       overflow, 
                       dvld,
                       wack

                       );


   parameter SYNC             = 0;
   parameter PIPE             = 1;
   parameter PREFETCH         = 1;
   parameter FWFT             = 1;
   parameter WRITE_WIDTH      = 18;
   parameter WRITE_DEPTH      = 10;
   parameter FULL_WRITE_DEPTH = 1024;
   parameter READ_WIDTH       = 18;
   parameter READ_DEPTH       = 10;
   parameter FULL_READ_DEPTH  = 1024;
   parameter AFVAL            = 508;
   parameter AEVAL            = 4;
   parameter AE_STATIC_EN     = 1;
   parameter AF_STATIC_EN     = 1;
   parameter ESTOP            = 1;
   parameter FSTOP            = 1;
   parameter OVERFLOW_EN      = 1;
   parameter UNDERFLOW_EN     = 1;
   parameter WRCNT_EN         = 1;
   parameter RDCNT_EN         = 1;
   parameter RCLK_EDGE        = 1;
   parameter WCLK_EDGE        = 1;
   parameter RE_POLARITY      = 0;
   parameter WE_POLARITY      = 0;
   parameter READ_DVALID      = 0;
   parameter WRITE_ACK        = 0;
   parameter RESET_POLARITY   = 0;



   input                       clk;                   
   input                       rclk;                   
   input                       wclk;                   
   input                       reset;                  
                                                        
   input                       we;                    
   input                       re;                     

   input [WRITE_DEPTH:0]      wcnt;                 
   input [READ_DEPTH:0]       rcnt;                 

   input                      full;                   
   input                      afull;                 
                                                        
   input                      empty;                  
   input                      aempty;                 
                                                        
   input                      underflow;              
   input                      overflow;               
   input                      dvld;               
   input                      wack;               
   

   reg [WRITE_DEPTH:0]            wptr;
   reg [READ_DEPTH:0]             rptr;
   reg [WRITE_DEPTH:0]            wptr_r;
   reg [READ_DEPTH:0]             rptr_r;
   reg                            full_r, full_reg;
   reg                            afull_r;
   reg                            empty_r,empty_rt,empty_reg;
   reg                            empty_r_fwft1;
   reg                            empty_r_fwft2;
   reg                            empty_r_fwft3;
   reg                            aempty_r;
   reg                            underflow_r;
   reg                            overflow_r;
   reg                            underflow_w;
   reg                            overflow_w;
   reg                            DVLD_d0,DVLD_d1,DVLD_d2;
   reg                            wack_r;
   reg [WRITE_DEPTH : 0]          wptr_d1sync;
   reg [WRITE_DEPTH : 0]          wptr_d2sync;
   reg [WRITE_DEPTH : 0]          wptr_d3sync;
   reg [WRITE_DEPTH : 0]          wptr_d4sync;
   reg [READ_DEPTH  : 0]          rptr_d1sync;
   reg [READ_DEPTH  : 0]          rptr_d2sync;
   reg [READ_DEPTH  : 0]          rptr_d3sync;
   reg [READ_DEPTH  : 0]          rptr_d4sync;

   wire                           f_wclk;
   wire                           f_rclk;
   wire                           fifo_wclk;
   wire                           fifo_rclk;

   wire                           fifo_we;
   wire                           fifo_re;
   wire                           fifo_reset;

   wire [WRITE_DEPTH:0]           tb_wcnt;
   wire [READ_DEPTH:0]            tb_rcnt;

   wire                           tb_full;
   wire                           tb_afull;

   wire                           tb_empty;
   wire                           tb_empty_int;
   wire                           tb_aempty;

   wire                           tb_underflow;
   wire                           tb_overflow;

   wire                           tb_dvld;
   wire                           tb_wack;

   wire [WRITE_DEPTH:0]           wdiff_bus;
   wire [READ_DEPTH:0]            rdiff_bus;
   wire                           full_w;
   wire                           afull_w;
   wire                           empty_w;
   wire                           aempty_w;
   wire                           aempty_w_assert;
   wire                           aempty_w_deassert;
   wire                           aempty_w_int;
   wire                           temp;
   wire                           dvld;

   event                          check_wcnt;
   event                          check_rcnt;
   event                          check_full;
   event                          check_afull;
   event                          check_empty;
   event                          check_aempty;
   event                          check_overflow;
   event                          check_underflow;
   event                          check_dvld;
   event                          check_wack;

   integer                        err_cnt;
   reg                            observe;
   wire                           full_w_async;
   wire                           full_w_sync; 
   reg    [READ_DEPTH:0]          sc_r;

  initial 
  begin
    err_cnt = 0;
  end
   
   assign f_wclk  = SYNC ? clk : wclk;     
   assign f_rclk  = SYNC ? clk : rclk;     

   assign fifo_wclk  = WCLK_EDGE ? f_wclk : ~f_wclk;     
   assign fifo_rclk  = SYNC ? WCLK_EDGE ? f_rclk : ~f_rclk : RCLK_EDGE ? f_rclk : ~f_rclk;     


   assign fifo_we    = WE_POLARITY ? ~we : we;     
   assign fifo_re    = RE_POLARITY ? ~re : re;     

   assign fifo_reset = RESET_POLARITY ? ~reset : reset;    
   assign wdiff_bus = SYNC ? (wptr - rptr) : (wptr - rptr_d4sync);
   assign rdiff_bus = SYNC ? (wptr - rptr) : (wptr_d4sync- rptr);

//************************ Final output and flag assignments *******************************************/
   assign tb_wcnt      = ((SYNC == 1) && (WRITE_WIDTH == READ_WIDTH) && (ESTOP == 1) && (FSTOP ==  1)) ? wdiff_bus : wptr_r ;
   assign tb_rcnt      = ((SYNC == 1) && (WRITE_WIDTH == READ_WIDTH) && (ESTOP == 1) && (FSTOP ==  1)) ? rdiff_bus : rptr_r;

   assign tb_full     =  SYNC ? full_w_sync : full_r;
   assign tb_afull    =  SYNC ? (fifo_we ? afull_w : afull_r) : afull_r;

   assign tb_empty_int    = ((SYNC == 1) && (WRITE_WIDTH == READ_WIDTH) && (ESTOP == 1) && (FSTOP ==  1)) ? empty_w: empty_r ;
   assign tb_empty    = ((FWFT == 1) || (PREFETCH ==  1)) ? (tb_empty_int | empty_r_fwft3) : tb_empty_int ;

   assign tb_aempty   = aempty_r;

   assign tb_underflow = (SYNC == 1) ? underflow_w : underflow_r;
   assign tb_overflow  =  overflow_r;

   assign tb_dvld = (PIPE == 1) ? DVLD_d0 : (PIPE == 2) ? DVLD_d1 : (fifo_re && !empty);
   assign tb_wack = wack_r;

//******************************************************************************************************/
//june 13
//  assign full_w  = (wdiff_bus >= (FULL_WRITE_DEPTH)) ; 
  assign full_w        =  SYNC ? full_w_sync : full_w_async;
  assign full_w_sync   =  ( sc_r == (FULL_WRITE_DEPTH))  ;
  assign full_w_async  = we ? (wdiff_bus >= (FULL_WRITE_DEPTH-1)) : (wdiff_bus >= (FULL_WRITE_DEPTH)) ; // june 13

  assign afull_w  = SYNC ? (wdiff_bus >= AFVAL)  :  (wdiff_bus >= AFVAL-1);

  assign empty_w =  SYNC ? 0>= rdiff_bus : fifo_re ? (rdiff_bus<=1) : (rdiff_bus == 0) ;
  assign aempty_w_assert   =  AEVAL >= rdiff_bus;
  assign aempty_w_deassert =  (AEVAL-1) >= rdiff_bus;
  assign aempty_w_int = fifo_re ? aempty_w_assert : aempty_w_deassert;
  assign aempty_w =  aempty_w_int;

   assign temp = (wptr >= FULL_WRITE_DEPTH-1 && rptr >= (FULL_READ_DEPTH -1)) ? 1 : 0;

   always @(posedge fifo_wclk or negedge fifo_reset) 
   begin
      if (!fifo_reset) begin
         wptr <= 0;
         observe = 0;
      end
      else if(fifo_we == 1'b1 && full_r == 1'b0)  begin
             wptr <= wptr + 1;
      end
   end

   // june 13
    always @(negedge fifo_reset or posedge fifo_wclk)
    begin
       if (!fifo_reset) begin
           sc_r <= 0;
       end
       else if ( fifo_we ^ fifo_re) begin
	   if(fifo_we == 1'b1) begin
             sc_r <= (sc_r + 1); 
           end
	   else if(fifo_re == 1'b1) begin
             sc_r <= (sc_r - 1); 
	   end
       end
    end
   always @(posedge fifo_rclk or negedge fifo_reset ) 
   begin
      if (!fifo_reset) begin
         rptr <= 0;
         observe = 0;
      end
      else if (fifo_re == 1'b1 && empty_reg == 1'b0 ) begin
            rptr <= rptr + 1;
      end
    end

if (SYNC == 0) begin
    if (WRITE_WIDTH > READ_WIDTH) begin
   always @(posedge fifo_rclk or negedge fifo_reset)
     begin
      if (!fifo_reset) begin
        wptr_d1sync<= 0;
        wptr_d2sync<= 0;
        wptr_d3sync<= 0;
        wptr_d4sync<= 0;
      end
      else begin
        wptr_d1sync<= wptr;
        wptr_d2sync<= wptr_d1sync;
        wptr_d3sync<= wptr_d2sync;
        if (wptr_d3sync < WRITE_WIDTH) begin
        wptr_d4sync<= ((wptr_d3sync)*(WRITE_WIDTH/READ_WIDTH));
        end
     end
    end

   always @(posedge fifo_wclk or negedge fifo_reset)
     begin
      if (!fifo_reset) begin
        rptr_d1sync<= 0;
        rptr_d2sync<= 0;
        rptr_d3sync<= 0;
        rptr_d4sync<= 0;
      end
      else begin

        rptr_d1sync<= rptr;
        rptr_d2sync<= rptr_d1sync;
        rptr_d3sync<= rptr_d2sync;
       if (rptr_d3sync < FULL_READ_DEPTH) begin
        rptr_d4sync<= ((rptr_d3sync) /(WRITE_WIDTH/READ_WIDTH));
       end
     end
    end
  end
/*******************************************/
  else if (WRITE_WIDTH < READ_WIDTH) begin 
   always @(posedge fifo_rclk or negedge fifo_reset)
     begin
      if (!fifo_reset) begin
        wptr_d1sync<= 0;
        wptr_d2sync<= 0;
        wptr_d3sync<= 0;
        wptr_d4sync<= 0;
      end
      else begin
        wptr_d1sync<= wptr;
        wptr_d2sync<= wptr_d1sync;
        wptr_d3sync<= wptr_d2sync;
        if (wptr_d3sync <= FULL_WRITE_DEPTH) begin
        wptr_d4sync<= ((wptr_d3sync)/(READ_WIDTH/WRITE_WIDTH));
        end
     end
    end

   always @(posedge fifo_rclk or negedge fifo_reset)
     begin
      if (!fifo_reset) begin
        rptr_d1sync<= 0;
        rptr_d2sync<= 0;
        rptr_d3sync<= 0;
        rptr_d4sync<= 0;
      end
      else begin

        rptr_d1sync<= rptr;
        rptr_d2sync<= rptr_d1sync;
        rptr_d3sync<= rptr_d2sync;
       if (rptr_d3sync < READ_WIDTH) begin
        rptr_d4sync<= ((rptr_d3sync)*(READ_WIDTH/WRITE_WIDTH));
       end
     end
    end
  end
/*******************************************/
  else begin                                       //(WRITE_WIDTH == READ_WIDTH) 
   always @(posedge fifo_rclk or negedge fifo_reset)
     begin
      if (!fifo_reset) begin
        wptr_d1sync<= 0;
        wptr_d2sync<= 0;
        wptr_d3sync<= 0;
        wptr_d4sync<= 0;
      end
      else begin
        wptr_d1sync<= wptr;
        wptr_d2sync<= wptr_d1sync;
        wptr_d3sync<= wptr_d2sync;
        wptr_d4sync<= wptr_d3sync;
     end
    end
   always @(posedge fifo_wclk or negedge fifo_reset)
     begin
      if (!fifo_reset) begin
        rptr_d1sync<= 0;
        rptr_d2sync<= 0;
        rptr_d3sync<= 0;
        rptr_d4sync<= 0;
      end
      else begin
       
        rptr_d1sync<= rptr;
        rptr_d2sync<= rptr_d1sync;
        rptr_d3sync<= rptr_d2sync;
        rptr_d4sync<= rptr_d3sync;
     end
    end
 end
 end

  always @(posedge fifo_wclk or negedge fifo_reset)
  begin
    if(!fifo_reset) begin
        full_reg <= 0;
    end
    else
        full_reg <= full_r;
  end

  always @(posedge fifo_rclk or negedge fifo_reset)
  begin
    if(!fifo_reset) begin
        empty_reg <= 0;
    end
    else
        empty_reg <= empty_r;
  end

  always @(posedge fifo_wclk or negedge fifo_reset)
  begin
    if(!fifo_reset) begin
      full_r   <= 1'b0;
      afull_r  <= 1'b0;
      wptr_r   <= 0;                    
      overflow_r <= 1'b0;
    end
    else begin
      full_r   <= full_w;
      afull_r  <= afull_w;
      wptr_r  <= wdiff_bus;

      if(fifo_we == 1'b1 && full_reg == 1'b1 && OVERFLOW_EN == 1) begin
        overflow_r <= 1'b1;
      end
      else begin
        overflow_r <= 1'b0;
       end
      if(fifo_we == 1'b1 && full_w == 1'b1 && OVERFLOW_EN == 1) begin
        overflow_w <= 1'b1;
      end
      else begin
        overflow_w <= 1'b0;
       end

     end
  end 

  always @(posedge fifo_rclk or negedge fifo_reset)
   begin
     if(!fifo_reset) begin
       empty_r   <= 1'b1;
       empty_r_fwft1   <= 1'b1;
       empty_r_fwft2   <= 1'b1;
       empty_r_fwft3   <= 1'b1;
       empty_rt  <= 1'b1;
       aempty_r  <= 1'b1;
       rptr_r   <= 0;
     end
     else begin
       empty_r   <= empty_w;
       empty_r_fwft1   <= empty_r;
       empty_r_fwft2   <= empty_r_fwft1;
       empty_r_fwft3   <= empty_r_fwft2;
       empty_rt  <= empty_w;
       aempty_r  <= aempty_w;
       rptr_r   <= rdiff_bus;
     end
  end

  always @(posedge fifo_rclk or negedge fifo_reset)
   begin
     if(!fifo_reset) begin
       underflow_r <= 1'b0;
       underflow_w <= 1'b0;
     end  
     else begin
        if(fifo_re == 1'b1 && empty_r == 1'b1 && UNDERFLOW_EN == 1 && SYNC == 0) begin
          underflow_r <= 1'b1;
        end
        else begin
          underflow_r <= 1'b0;
        end
        if(fifo_re == 1'b1 && empty_w == 1'b1 && UNDERFLOW_EN == 1 && SYNC == 1) begin
          underflow_w <= 1'b1;
        end
        else begin
          underflow_w <= 1'b0;
        end
     end
   end

    reg underflow_start, overflow_start;
   always @(posedge underflow_w or underflow_r or negedge fifo_reset)
   begin
     if(!fifo_reset) begin
       underflow_start <=0;
     end
     else begin
            underflow_start <=1;
     end
   end

   always @(posedge overflow_w  or underflow_r or negedge fifo_reset)
   begin
     if(!fifo_reset) begin
       overflow_start <=0;
     end
     else begin
            overflow_start <=1;
     end
 end

   always @(posedge fifo_rclk or negedge fifo_reset)
   begin
     if(!fifo_reset) begin
       DVLD_d0 <=0;
       DVLD_d1 <=0;
       DVLD_d2 <=0;
     end
     else begin
            DVLD_d0 <=(fifo_re && !empty);
            DVLD_d1 <=DVLD_d0;
            DVLD_d2 <=DVLD_d1;
     end
 end

  always @(posedge fifo_wclk or negedge fifo_reset)
   begin
     if(!fifo_reset) begin
       wack_r <=0;
     end
     else begin
         wack_r <=(fifo_we && !full_r);
     end
 end


/**************** EVENT geneartion whenever flag asserted ************************************/

  always @(tb_dvld or dvld) 
  begin
      if ((fifo_reset ==1) && READ_DVALID == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH)) 
          #1
      -> check_dvld;
  end

  always @(tb_wack or wack) 
  begin
      if ((fifo_reset ==1) && WRITE_ACK == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH)) 
          #1
      -> check_wack;
  end

  always @(tb_wcnt or wcnt) 
  begin
      if ((fifo_reset ==1) && WRCNT_EN == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH)  && FWFT == 0 && PREFETCH == 0) 
          #1
      -> check_wcnt;
  end

  always @(tb_rcnt or rcnt) 
  begin
      if ((fifo_reset == 1)  && RDCNT_EN == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH) && FWFT == 0 && PREFETCH == 0)
          #1
      -> check_rcnt;
  end

  always @(tb_full or full)  
  begin
      if ((fifo_reset == 1) && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH)  && FWFT == 0 && PREFETCH == 0)
          #1
      -> check_full;
  end

  always @(tb_afull or afull)
     begin
       if ((fifo_reset == 1) && AF_STATIC_EN == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH) && FWFT == 0 && PREFETCH == 0)
          #1
         -> check_afull;
     end

  always @(tb_empty or empty )
  begin
      if (fifo_reset == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH) && FWFT == 0 && PREFETCH == 0)
          #1
      -> check_empty;
  end

    always @(tb_aempty or aempty)
    begin
      if ((fifo_reset == 1) && AE_STATIC_EN == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH)  && FWFT == 0 && PREFETCH == 0)
          #1
        -> check_aempty;
    end

  always @(tb_overflow or overflow)
  begin
     if ((fifo_reset == 1) && OVERFLOW_EN == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH)  && FWFT == 0 && PREFETCH == 0) 
          #1
        -> check_overflow;
  end

  always @(tb_underflow or underflow)
  begin
     if ((fifo_reset == 1) && UNDERFLOW_EN == 1 && FSTOP == 1 && ESTOP == 1 && (READ_DEPTH == WRITE_DEPTH) && FWFT == 0 && PREFETCH == 0)
          #1
      -> check_underflow;
  end


  

/************************** Checker placed to compare with DUT signal status v/s expected signal status *********************/
  always @(check_wack)
  begin

     //check_wack_out(tb_wack);

  end

  always @(check_dvld)
  begin

     //check_dvld_out(tb_dvld);

  end

  always @(check_wcnt)
  begin

     //check_wcnt_out(tb_wcnt);

  end

  always @(check_rcnt)
  begin

     //check_rcnt_out(tb_rcnt);

  end

  always @(check_full)
  begin
  
     check_full_flag(tb_full);

  end

  always @(check_afull)
  begin

    check_afull_flag(tb_afull);

  end

  always @(check_empty)
  begin

    check_empty_flag(tb_empty);

  end

  always @(check_aempty)
  begin

    check_aempty_flag(tb_aempty);

  end

  always @(check_overflow)
  begin

    check_overflow_flag(tb_overflow);

  end

  always @(check_underflow)
  begin

    check_underflow_flag(tb_underflow);

  end

/*******************************  TASKS ********************************************************/

task check_reset;
input expected_value;
begin
 #1
  $display("fifo reset = %b", fifo_reset);
  if (fifo_reset != expected_value)
  begin
    $display("ERROR: fifo reset = %b - expected value=  %b", fifo_reset, expected_value);
  end
end
endtask

task check_wack_out;
input expected_value;

begin
 #1
    if ((wack !== expected_value ) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo wack = %d - expected value= %d ",$time, wack , expected_value);
    err_cnt = err_cnt +1;
  end
  else
    $display ( "At", $time, " PASS: WACK match \n");

end
endtask


task check_dvld_out;
input expected_value;

begin
 #1
    if ((dvld !== expected_value ) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo dvld = %d - expected value= %d ",$time, dvld , expected_value);
    err_cnt = err_cnt +1;
  end
  else
    $display ( "At", $time, " PASS: DVLD match \n");

end
endtask


task check_wcnt_out;
input[WRITE_DEPTH:0] expected_value;

begin
 #1
    if ((wcnt !== expected_value ) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo write_count = %d - expected value= %d ",$time, wcnt , expected_value);
    err_cnt = err_cnt +1;
  end
  else
    $display ( "At", $time, " PASS: write_count match \n");

end
endtask

task check_rcnt_out;
input[READ_DEPTH:0] expected_value;

begin
 #1
    if ((rcnt !== expected_value ) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo read_count = %d - expected value= %d ",$time, rcnt , expected_value);
    err_cnt = err_cnt +1;
  end
  else
    $display ( "At", $time, " PASS: read_count match \n");

end
endtask
task check_full_flag;
input expected_value;

begin
 #1
    if ((full !== expected_value ) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo full flag = %b - expected value= %b ",$time, full , expected_value);
    err_cnt = err_cnt +1;
    observe = ~observe;
  end
  else
    $display ( "At", $time, " PASS: FULL flag match \n");

end
endtask

task check_afull_flag;
input expected_value;

begin
 #1
  if ((afull !== expected_value) && (underflow_start ==0 && overflow_start == 0) ) begin
    $display("ERROR: At %t fifo afull flag = %b - expected value = %b ",$time ,afull, expected_value);
    err_cnt = err_cnt +1;
    observe = ~observe;
  end
  else
    $display ( "At", $time, " PASS: AFULL flag match \n");

end
endtask

task check_empty_flag;
input expected_value;

begin
 #2
  if ((empty !== expected_value) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo empty flag = %b - expected value = %b ",$time, empty, expected_value);
    err_cnt = err_cnt +1;
    observe = ~observe;
  end
  else 
    $display ( "At", $time, " PASS: EMPTY flag match \n");
end
endtask

task check_aempty_flag;
input expected_value;

begin
 #1
  if ((aempty !== expected_value) && (underflow_start ==0 && overflow_start == 0)) begin
    $display("ERROR: At %t fifo aempty flag = %b - expected value = %b",$time ,aempty, expected_value);
    err_cnt = err_cnt +1;
    observe = ~observe;
  end
  else
    $display ( "At", $time, " PASS: AEMPTY flag match \n");

end
endtask

task check_overflow_flag;
input expected_value;

begin
 #1
  if (overflow !== expected_value ) begin
    $display("ERROR: At %t fifo overflow flag = %b - expected value = %b", $time, overflow, expected_value);
    err_cnt = err_cnt +1;
    observe = ~observe;
  end
  else
    $display ( "At", $time, " PASS: OVERFLOW flag match \n");
end
endtask

task check_underflow_flag;
input expected_value;

begin
 #1
  if (underflow !== expected_value) begin
    $display("ERROR: At %t fifo underflow flag = %b - expected value = %b", $time, underflow, expected_value);
    err_cnt = err_cnt +1;
    observe = ~observe;
  end
  else
    $display ( "At", $time, " PASS: UNDERFLOW flag match \n");

end
endtask



endmodule 
