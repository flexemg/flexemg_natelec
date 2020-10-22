# Global clocks
force -freeze sim:/cm_tb/PCLK 1 0, 0 {25 ns} -r 50ns
force -freeze sim:/cm_tb/ACC_CLK 1 0, 0 {500 ns} -r 1000ns

#force sim:/cm_tb/acc_data 16#aabbccddeeff

do init_dut.do

# Enable/disable emulation, PDMA or accelerometer IRQ
# bit 0 - PDMA enable
# bit 1 - accelerometer IRQ enable
# bit 2 - artifact cancellation enable
# bit 3 - FFT enable
# bit 4 - accelerometer emulation
# bit 5 - NM0 emulation
# bit 6 - NM1 emulation
# bit 7 - PDMA emulation
# bits 16-21 - FFT channel for NM0
# bits 22-27 - FFT channel for NM1

force sim:/cm_tb/PADDR 16#000c
force sim:/cm_tb/PWDATA 16#000900ff
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

do init_vectors.do

do run_reset.do

do run_nm_command.do

do run_nm_register_write.do

do run_nm_register_read.do

# Do the accelerometer sim here to get "real" data for pdma sim
do run_acc.do

run 8ms

# load stim count
wave cursor add -lock 1 -name stim
force sim:/cm_tb/PADDR 16#0100
force sim:/cm_tb/PWDATA 16#00000003
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

run 6ms

# Read status
force sim:/cm_tb/PADDR 16#0000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

run 20ms

do read_fft.do 

run 1ms