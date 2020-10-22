##
## ACCELEROMETER
##

wave cursor add -lock 1 -name acc

force sim:/cm_tb/cm_top_0/acc_if_0/acc_irq 1'b0

# IRQ block enable is done in run.do

#
# simulate IRQ
#

force sim:/cm_tb/cm_top_0/acc_if_0/acc_irq 1'b1
run 500ns
force sim:/cm_tb/cm_top_0/acc_if_0/acc_irq 1'b0
run 500ns

run 300us

#
# Write some random data to MPU6050 config register 
#

force sim:/cm_tb/PADDR 16#011a
force sim:/cm_tb/PWDATA 16#000000d6
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/wr_enable 0
run 50ns

run 100us

#
# Read some random register
#

# access #1 starts read transfer
force sim:/cm_tb/PADDR 16#013b
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

run 150us

# access #2 retrieves value
force sim:/cm_tb/PADDR 16#013b
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

run 100us

#
# Read status
#

force sim:/cm_tb/PADDR 16#0100
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

#
# Read most recent XY data
#

force sim:/cm_tb/PADDR 16#0101
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

#
# Read most recent Z data
#

force sim:/cm_tb/PADDR 16#0102
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

run 10us


