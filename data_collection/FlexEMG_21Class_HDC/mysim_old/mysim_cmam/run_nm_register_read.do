##
## NM register write (NM1 is identical)
##

wave cursor add -lock 1 -name nm_register_read

# Set operation bits for read (PWDATA[1:0] == b00)
force sim:/cm_tb/PADDR 16#0010
force sim:/cm_tb/PWDATA 16#00000000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Set LS 32 bits to addr[31:16],data[15:0]
force sim:/cm_tb/PADDR 16#0014
force sim:/cm_tb/PWDATA 16#000c0000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Send register read to NM0
force sim:/cm_tb/PADDR 16#0000
force sim:/cm_tb/PWDATA 16#00001000
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

# Make sure to wait long enough here for the NM to respond.
# If he NM is sending data the ACK will wait until the ADC channel is clear.
run 500us

# Read register content from ACK DP
force sim:/cm_tb/PADDR 16#0018
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

run 10us

