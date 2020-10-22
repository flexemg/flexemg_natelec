##
## Read some data from the NM0 ADC FIFO
##

wave cursor add -lock 1 -name read_ADC_FIFO


OBSOLETE!!!


# Read data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

# Read next data from NM0 ADC FIFO
force sim:/cm_tb/PADDR 16#001C
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 1
run 50ns
force sim:/cm_tb/cm_top_0/cm_if_apb_0/rd_enable 0
run 50ns

