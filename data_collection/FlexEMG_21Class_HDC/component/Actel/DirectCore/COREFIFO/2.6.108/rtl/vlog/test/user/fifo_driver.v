`timescale 1 ns / 100 ps

module fifo_driver (
    // inputs
    clk,
    wclk,
    rclk,
    waddr,
    raddr,
    full,
    empty,
    dvld,
    q,

    // outputs
    reset,
    we,
    re,
    wdata


    );

parameter SYNC = 0;
parameter CTRL_TYPE = 1;
parameter WRITE_WIDTH = 18;
parameter WRITE_DEPTH = 1024;
parameter FULL_WRITE_DEPTH = 10;
parameter READ_WIDTH = 18;
parameter READ_DEPTH = 1024;
parameter FULL_READ_DEPTH = 10;
parameter WE_POLARITY = 1;
parameter RE_POLARITY = 1;
parameter RESET_POLARITY = 0;
parameter RCLK_EDGE   = 1;
parameter WCLK_EDGE   = 1;
parameter ESTOP     = 1;
parameter FSTOP     = 1;
parameter PIPE     = 1;
parameter ECC      = 0;
parameter PREFETCH = 1;
parameter FWFT     = 0;



input clk;
input wclk;
input rclk;
input full;
input empty;
input dvld;
input [FULL_WRITE_DEPTH-1 :0] waddr;
input [FULL_READ_DEPTH-1 :0] raddr;

input [READ_WIDTH-1 :0] q;

output reset;
output we;
output re;

output [WRITE_WIDTH-1:0] wdata;


reg check_q;
reg  reset;
reg  we;
reg  re;
reg [FULL_READ_DEPTH :0] rdepth;
reg [FULL_WRITE_DEPTH:0] wdepth;
reg [FULL_READ_DEPTH-1 :0] raddr_top;

integer i,j,k,m;
integer cnt, cnt_rd, cnt_eq, rderr_cnt;
    reg [WRITE_WIDTH-1:0] wdata;
    reg [WRITE_WIDTH-1:0] mem_arrayA [0:(2<<FULL_WRITE_DEPTH)];
    reg [READ_WIDTH-1:0] mem_arrayB [0:(2<<FULL_READ_DEPTH)];

 wire f_wclk,f_rclk,fifo_wclk,fifo_rclk, fifo_reset;
 assign f_wclk  = SYNC ? clk : wclk;
 assign f_rclk  = SYNC ? clk : rclk;
 
 assign fifo_wclk  = WCLK_EDGE ? f_wclk : ~f_wclk;
 assign fifo_rclk  = SYNC ? RCLK_EDGE ? f_rclk : ~f_rclk : RCLK_EDGE ? f_rclk : ~f_rclk;

 assign fifo_reset = RESET_POLARITY ? ~reset : reset;

initial begin
  rderr_cnt = 0;
  if (RESET_POLARITY) begin
    reset = 1'b1;
  end else begin
    reset = 1'b0;
  end
  check_q = 1'b0;

  if (WE_POLARITY == 1'b1)  
 we <= 1'b1;
  else
 we <= 1'b0;

  if (RE_POLARITY == 1'b1)  
    re <= 1'b1;
  else
    re <= 1'b0;

end

initial begin
  if (WRITE_WIDTH > READ_WIDTH) begin
     for(cnt = 0; cnt < WRITE_DEPTH; cnt = cnt + 1) begin
        //mem_arrayA[cnt] = $random;
        mem_arrayA[cnt] = cnt;
        //$display("memory array A = %h", mem_arrayA[cnt]);
      end
  end
  else if (READ_WIDTH > WRITE_WIDTH ) begin
     for(cnt_rd = 0; cnt_rd < READ_DEPTH; cnt_rd = cnt_rd + 1) begin
        //mem_arrayA[cnt_rd] = $random;
        mem_arrayA[cnt_rd] = cnt_rd;
        //$display("memory array A = %h", mem_arrayA[cnt_rd]);
      end
  end
  else begin
    for(cnt_eq = 0; cnt_eq < WRITE_DEPTH; cnt_eq = cnt_eq + 1) begin
      //mem_arrayA[cnt_eq] = $random;
      mem_arrayA[cnt_eq] = cnt_eq;
      //$display("memory array A = %h", mem_arrayA[cnt_eq]);
    end
  end
end


task reset_asserted;
begin
  if (RESET_POLARITY)
    reset = 1'b1;
  else 
    reset = 1'b0;
end
endtask


task reset_negated;
begin
  if (RESET_POLARITY)
    reset = 1'b0;
  else 
    reset = 1'b1;
end
endtask

task initialize;
 begin

  if (WE_POLARITY == 1'b1)
    we <= 1'b1;
  else
    we <= 1'b0;

  if (RE_POLARITY == 1'b1)
    re <= 1'b1;
  else
    re <= 1'b0;

 end
endtask


task write_assert;
begin
    @ (posedge fifo_wclk);
  if (WE_POLARITY == 1'b1)
    we <= 1'b0;
  else
    we <= 1'b1;
end
endtask

task write_deassert;
begin
   // @ (posedge fifo_wclk);
  if (WE_POLARITY == 1'b1)
    we <= 1'b1;
  else
    we <= 1'b0;
end
endtask
reg active;
task push;
 input[(FULL_WRITE_DEPTH) :0] fifo_wdepth;
 begin
   wdepth = fifo_wdepth; 
   if (full == 1 && FSTOP == 0 )begin
     write_assert;
     #1;
      wdata = mem_arrayA[waddr];
      mem_arrayB[waddr] = mem_arrayA[waddr];

   end
   else begin
   for (i=0;i<=wdepth; i=i+1)
   begin
     write_assert;
     #1;
      //wdata = mem_arrayA[waddr];
      wdata = mem_arrayA[i];
      if (WRITE_WIDTH < READ_WIDTH) begin
         mem_arrayB[waddr] = {mem_arrayA[waddr*2+1],mem_arrayA[waddr*2]};
       end
       else if (WRITE_WIDTH > READ_WIDTH) begin
          //mem_arrayB[waddr*2]   = wdata[READ_WIDTH-1:0];
          //mem_arrayB[waddr*2+1] = wdata[WRITE_WIDTH-1:READ_WIDTH];
       end
       else 
           mem_arrayB[waddr] = mem_arrayA[waddr];
   end
   write_deassert;
  end
 end
endtask

task read_assert;
begin
    @ (posedge fifo_rclk);
  if (RE_POLARITY == 1'b1)
    re <= 1'b0;
  else
    re <= 1'b1;
end
endtask

reg  [FULL_READ_DEPTH-1 :0] raddr_t1,raddr_t2,raddr_t3,raddr_t4 ;

always @ (posedge fifo_rclk or negedge fifo_reset)
begin
    if (!fifo_reset) begin
     raddr_t1<=0;
     raddr_t2 <=0;
     raddr_t3 <=0;
     raddr_t4 <=0;
    end
    else begin
        if ((re == 1 && RE_POLARITY == 1'b0) || (re == 0 && RE_POLARITY == 1'b1)) begin
     raddr_t1 <=raddr;
     raddr_t2 <=raddr_t1;
     raddr_t3 <=raddr_t2;
     raddr_t4 <=raddr_t3;
    end
    end
end
always @ (posedge fifo_rclk or negedge fifo_reset)
begin
    if (!fifo_reset) begin
     raddr_top <=0;
    end
    else begin
     if ((re == 1 && RE_POLARITY == 1'b0) || (re == 0 && RE_POLARITY == 1'b1)) begin
       raddr_top <= raddr_top + 1;
    end
    end
end

task read_deassert;
begin
   // @ (posedge fifo_rclk);

  if (RE_POLARITY == 1'b1)
    re <= 1'b1;
  else
    re <= 1'b0;
end
endtask
  wire  [FULL_READ_DEPTH-1 :0] raddr_temp1,raddr_temp2 ;
assign raddr_temp1 = (raddr <=1) ?  0 : (raddr-1);
assign raddr_temp2 = (raddr <=2) ?  0 : (raddr-2);

 task pop;
 input[(FULL_READ_DEPTH) :0] fifo_rdepth;

  reg  [FULL_READ_DEPTH-1 :0] raddr_temp;
  begin
    rdepth = fifo_rdepth;  
    active =0;
    read_assert;

   repeat(PIPE) @ (posedge fifo_rclk); 
   if(ECC == 1) begin repeat(ECC)  @ (posedge fifo_rclk); end
    for (k=0 ;k<rdepth-1;k=k+1)
    begin
    if (empty == 0) begin
      @ (posedge fifo_rclk);
     if (WRITE_WIDTH < READ_WIDTH) begin
         if((mem_arrayB[raddr_temp] != q))
         begin
             check_q = ~check_q;
             $display ("ERROR: At Raddr = %d raddr_temp = %d fifo Q = %h - expected Q = %h ",raddr, raddr_temp, q , mem_arrayB[raddr_temp]);
	     rderr_cnt = rderr_cnt + 1;
         end
	 else begin
             //$display ("PASS: At TIME = %t Raddr = %d raddr_temp = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_temp, q , mem_arrayB[raddr_temp]);
         end	
      end
      else if (WRITE_WIDTH > READ_WIDTH) begin
          if (PREFETCH == 1)begin
            if (mem_arrayB[raddr_temp] != q)
             begin
             check_q = ~check_q;
             $display ("ERROR: At Raddr = %d fifo Q = %h - expected Q = %h ",raddr, q , mem_arrayB[raddr_temp]);
	     rderr_cnt = rderr_cnt + 1;
             end
             else begin
             //$display ("PASS: At TIME = %t Raddr = %d fifo Q = %h - expected Q = %h ",$time, raddr, q , mem_arrayB[raddr_temp]);
             end	
          end	
          else begin //if(PREFETCH == 0 && mem_arrayB[raddr_temp] != q)
            if (mem_arrayB[raddr_temp] != q)
            begin
             check_q = ~check_q;
             $display ("ERROR: At Raddr = %d raddr_temp = %d fifo Q = %h - expected Q = %h ",raddr, raddr_temp, q , mem_arrayB[raddr_temp]);
	     rderr_cnt = rderr_cnt + 1;
            end
            else begin
             //$display ("PASS: At TIME = %t Raddr = %d raddr_temp = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_temp, q , mem_arrayB[raddr_temp]);
            end	
          end
      end
      else begin // (WRITE_WIDTH == READ_WIDTH)
        if ((PREFETCH == 1 || FWFT == 1)  && CTRL_TYPE == 1)begin
         if((mem_arrayB[raddr_top] !== q))
         begin
             check_q = ~check_q;
             $display ("ERROR: TIME = %t At Raddr = %d fifo Q = %h - expected Q = %h ",$time, raddr_top, q , mem_arrayB[raddr_top]);
	     rderr_cnt = rderr_cnt + 1;
         end
	 else begin
             //$display ("PASS: At TIME = %t Raddr = %d fifo Q = %h - expected Q = %h ",$time, raddr, q , mem_arrayB[raddr_t1]);
         end	
        end
        else if ((PREFETCH == 1 || FWFT == 1) && CTRL_TYPE != 1)begin
         if((mem_arrayB[raddr] !== q))
         begin
             check_q = ~check_q;
             $display ("ERROR: At Raddr = %d fifo Q = %h - expected Q = %h ",raddr, q , mem_arrayB[raddr]);
	     rderr_cnt = rderr_cnt + 1;
         end
	 else begin
             //$display ("PASS: At TIME = %t Raddr = %d fifo Q = %h - expected Q = %h ",$time, raddr, q , mem_arrayB[raddr]);
         end	
        end
        else begin
          if (PIPE == 2 && ECC == 0 ) begin
              if((mem_arrayB[raddr_t2] !== q)) begin
                check_q = ~check_q;
                $display ("ERROR: At Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
	            rderr_cnt = rderr_cnt + 1;
              end
	          else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
              end	

          end
          else if (PIPE == 2 && ECC == 1 && CTRL_TYPE !==1) begin
              if((mem_arrayB[raddr_t3] !== q)) begin
                check_q = ~check_q;
                $display ("ERROR: At Raddr = %d raddr_t3 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t3, q , mem_arrayB[raddr_t3]);
	            rderr_cnt = rderr_cnt + 1;
              end
	          else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
              end	

          end
		  else if (PIPE == 2 && (ECC == 1 || ECC == 0) && CTRL_TYPE ==1) begin
              if((mem_arrayB[raddr_t2] !== q)) begin
                check_q = ~check_q;
                $display ("ERROR: At Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
	            rderr_cnt = rderr_cnt + 1;
              end
	          else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
              end	

          end
		  else if (PIPE == 2 && ECC == 2 ) begin
              if((mem_arrayB[raddr_t2] !== q)) begin
                check_q = ~check_q;
                $display ("ERROR: At Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
	            rderr_cnt = rderr_cnt + 1;
              end
	          else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t2, q , mem_arrayB[raddr_t2]);
              end	

          end
          else if (PIPE == 1 && ECC== 0 )  begin
               if((mem_arrayB[raddr_t1] !== q)) begin
                check_q = ~check_q;
                $display ($realtime, "ERROR: At Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t1 , q , mem_arrayB[raddr_t1]);
	             rderr_cnt = rderr_cnt + 1;
                end
	             else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t1, q , mem_arrayB[raddr_t1]);
                 end	

          end
         else if (PIPE == 1 && ECC== 1 && CTRL_TYPE!=1)  begin
               if((mem_arrayB[raddr_t2] !== q)) begin
                check_q = ~check_q;
                $display ($realtime, "ERROR: At Raddr = %d raddr_t2 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t2 , q , mem_arrayB[raddr_t2]);
	             rderr_cnt = rderr_cnt + 1;
                end
	             else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t1, q , mem_arrayB[raddr_t1]);
                 end	

          end
        else if (PIPE == 1 && ECC== 2)  begin
               if((mem_arrayB[raddr_t1] !== q)) begin
                check_q = ~check_q;
                $display ($realtime, "ERROR: At Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t1 , q , mem_arrayB[raddr_t1]);
	             rderr_cnt = rderr_cnt + 1;
                end
	             else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t1, q , mem_arrayB[raddr_t1]);
                 end	

          end
          else if (PIPE == 1 && (ECC== 1 || ECC ==0) && CTRL_TYPE==1)  begin
               if((mem_arrayB[raddr_t1] !== q)) begin
                check_q = ~check_q;
                $display ($realtime, "ERROR: Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",raddr, raddr_t1 , q , mem_arrayB[raddr_t1]);
	             rderr_cnt = rderr_cnt + 1;
                end
	             else begin
                //$display ("PASS: At TIME = %t Raddr = %d raddr_t1 = %d fifo Q = %h - expected Q = %h ",$time, raddr, raddr_t1, q , mem_arrayB[raddr_t1]);
                 end	

          end
          else begin
               if((mem_arrayB[raddr] !== q)) begin
                check_q = ~check_q;
                $display ("ERROR: else At Raddr = %d fifo Q = %h - expected Q = %h ",raddr, q , mem_arrayB[raddr]);
	        rderr_cnt = rderr_cnt + 1;
              end
	      else begin
                //$display ("PASS: At TIME = %t Raddr = %d fifo Q = %h - expected Q = %h ",$time, raddr, q , mem_arrayB[raddr]);
              end

          end
        end
      end
    end  
  end
    if (rderr_cnt == 0) 
         $display ( "At", $time, " PASS: FIFO Q output match \n");
end
endtask

endmodule // fifo_driver
