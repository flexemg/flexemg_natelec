##
## RESET
##

##
## Reset NM0 (NM1 is identical)
##

wave cursor add -lock 1 -name reset_NM0

# Enable reset for NM0
force sim:/cm_tb/PADDR 16#0004
force sim:/cm_tb/PWDATA 16#00000100
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set link reset type to NM (2) and assert start
force sim:/cm_tb/PADDR 16#0000
force sim:/cm_tb/PWDATA 16#000000102
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

run 2us

