##
## NM command (NM1 is identical)
##
## 25us

wave cursor add -lock 1 -name nm_command

# Set up command data
force sim:/cm_tb/PADDR 16#0014
force sim:/cm_tb/PWDATA 16#00000489
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Send command to NM0
force sim:/cm_tb/PADDR 16#0000
force sim:/cm_tb/PWDATA 16#00001010
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

run 15us

