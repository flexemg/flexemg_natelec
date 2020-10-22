##
## This sequence is to get everything into a known state
##
## NOTE: cm_data_rd in cm_tb.v will be undefined at times during this sim
## because the write PADDResses are also read loopback PADDResses

wave cursor add -lock 1 -name init_dut

force PRESETN 0
run 100ns
force PRESETN 1
run 100ns

force sim:/cm_tb/cm_top_0/acc_if_0/acc_irq 0
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0

# Disable PDMA block
force sim:/cm_tb/PADDR 16#0200
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set up NM0 Tx MS 2 bit
force sim:/cm_tb/PADDR 16#0010
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set up NM0 Tx LS 32 bits
force sim:/cm_tb/PADDR 16#0014
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Init up NM1 Tx MS 2 bit
force sim:/cm_tb/PADDR 16#20
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set up NM1 Tx LS 32 bits
force sim:/cm_tb/PADDR 16#0024
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Init up NM2 Tx MS 2 bit
force sim:/cm_tb/PADDR 16#0030
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set up NM2 Tx LS 32 bits
force sim:/cm_tb/PADDR 16#0034
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Init up NM3 Tx MS 2 bit
force sim:/cm_tb/PADDR 16#0040
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set up NM3 Tx LS 32 bits
force sim:/cm_tb/PADDR 16#0044
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns


