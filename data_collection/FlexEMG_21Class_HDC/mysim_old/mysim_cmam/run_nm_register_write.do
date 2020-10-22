##
## NM register write (NM1 is identical)
##

wave cursor add -lock 1 -name nm_register_write

# Set operation bits for write (PWDATA[1:0] == b01)
force sim:/cm_tb/PADDR 16#0010
force sim:/cm_tb/PWDATA 16#00000001
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set LS 32 bits to addr[31:16],data[15:0]
force sim:/cm_tb/PADDR 16#0014
force sim:/cm_tb/PWDATA 16#000c5678
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Send register write to NM0
force sim:/cm_tb/PADDR 16#0000
force sim:/cm_tb/PWDATA 16#00001000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Make sure to wait long enough here for the NM to respond.
# If he NM is sending data the ACK will wait until the ADC channel is clear.
run 120us

