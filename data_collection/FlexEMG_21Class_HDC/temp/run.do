

# Global clocks
force -freeze clk 1 0, 0 {25 ns} -r 50ns

add wave -position end  sim:/ADCMEM_DP/clk
add wave -position end  -radix hexadecimal sim:/ADCMEM_DP/data0
add wave -position end  -radix hexadecimal sim:/ADCMEM_DP/data1
add wave -position end  -radix hexadecimal sim:/ADCMEM_DP/waddr0
add wave -position end  -radix hexadecimal sim:/ADCMEM_DP/waddr1
add wave -position end  sim:/ADCMEM_DP/we0
add wave -position end  sim:/ADCMEM_DP/we1
add wave -position end  -radix hexadecimal sim:/ADCMEM_DP/q

force sim:/ADCMEM_DP/data0 16#0000
force sim:/ADCMEM_DP/data1 16#0000
force sim:/ADCMEM_DP/waddr0 16#000
force sim:/ADCMEM_DP/waddr1 16#000
force sim:/ADCMEM_DP/we0 0
force sim:/ADCMEM_DP/we1 0

run 1us

force sim:/ADCMEM_DP/data0 16#0000
force sim:/ADCMEM_DP/waddr0 16#000
force sim:/ADCMEM_DP/we0 1
run 1us
force sim:/ADCMEM_DP/we0 0
run 1us

force sim:/ADCMEM_DP/data1 16#0000
force sim:/ADCMEM_DP/waddr1 16#000
force sim:/ADCMEM_DP/we1 1
run 1us
force sim:/ADCMEM_DP/we1 0
run 1us


force sim:/ADCMEM_DP/data0 16#0011
force sim:/ADCMEM_DP/waddr0 16#001
force sim:/ADCMEM_DP/we0 1
run 1us
force sim:/ADCMEM_DP/we0 0
run 1us

force sim:/ADCMEM_DP/data0 16#0022
force sim:/ADCMEM_DP/waddr0 16#002
force sim:/ADCMEM_DP/we0 1
run 1us
force sim:/ADCMEM_DP/we0 0
run 1us

force sim:/ADCMEM_DP/data0 16#0033
force sim:/ADCMEM_DP/waddr0 16#003
force sim:/ADCMEM_DP/we0 1
run 1us
force sim:/ADCMEM_DP/we0 0
run 1us

force sim:/ADCMEM_DP/data0 16#0044
force sim:/ADCMEM_DP/waddr0 16#004
force sim:/ADCMEM_DP/we0 1
run 1us
force sim:/ADCMEM_DP/we0 0
run 1us

force sim:/ADCMEM_DP/waddr0 16#000

force sim:/ADCMEM_DP/data1 16#1111
force sim:/ADCMEM_DP/waddr1 16#001
force sim:/ADCMEM_DP/we1 1
run 1us
force sim:/ADCMEM_DP/we1 0
run 1us

force sim:/ADCMEM_DP/data1 16#1122
force sim:/ADCMEM_DP/waddr1 16#002
force sim:/ADCMEM_DP/we1 1
run 1us
force sim:/ADCMEM_DP/we1 0
run 1us

force sim:/ADCMEM_DP/data1 16#1133
force sim:/ADCMEM_DP/waddr1 16#003
force sim:/ADCMEM_DP/we1 1
run 1us
force sim:/ADCMEM_DP/we1 0
run 1us

force sim:/ADCMEM_DP/data1 16#1144
force sim:/ADCMEM_DP/waddr1 16#001
force sim:/ADCMEM_DP/we1 1
run 1us
force sim:/ADCMEM_DP/we1 0
run 1us

