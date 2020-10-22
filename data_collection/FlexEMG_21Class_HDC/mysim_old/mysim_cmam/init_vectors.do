##
## ADC VECTORS
##

wave cursor add -lock 1 -name init_vectors

##
## Set ADC vectors for NM 0
##

# High 16 bits
force sim:/cm_tb/PADDR 16#0018
force sim:/cm_tb/PWDATA 16#ffffffff
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Low 16 bits
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/PWDATA 16#ffffffff
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

##
## Set ADC vectors for NM 1
##

# High 16 bits
force sim:/cm_tb/PADDR 16#0028
force sim:/cm_tb/PWDATA 16#ffffffff
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Low 16 bits
force sim:/cm_tb/PADDR 16#002C
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns
