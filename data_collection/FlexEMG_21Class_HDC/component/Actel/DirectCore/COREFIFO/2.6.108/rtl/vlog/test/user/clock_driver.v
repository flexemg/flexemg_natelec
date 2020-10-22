 `timescale 1 ns / 100 ps
module clock_driver ( clk1, wclk1, rclk1);

output clk1;
output wclk1,rclk1;

parameter  CLKPERIOD = 15;
parameter  WCLKPERIOD = 15;
parameter  RCLKPERIOD = 15;

reg clk1, wclk1, rclk1;
reg enable;

initial begin
  clk1 = 1'b0;
  wclk1 = 1'b0;
  rclk1 = 1'b0;
  enable = 1'b1;

end


always @(clk1 or enable)
begin
  if (enable)
    clk1 <= #(CLKPERIOD) ~clk1;
end

always @(wclk1 or enable)
begin
  if (enable)
    wclk1 <= #(WCLKPERIOD) ~wclk1;
end


always @(rclk1 or enable)
begin
  if (enable)
    rclk1 <= #(RCLKPERIOD) ~rclk1;
  
end



task clk_on;
begin
  enable = 1'b1;
end
endtask

task clk_off;
begin
  enable = 1'b0;
end
endtask


endmodule  // clock_driver
