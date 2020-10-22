create_clock -name xtal_20MHz -period 50 [get_pins {OSC_0.XTLOSC_CCC}]

create_generated_clock -name clk_20_48 -divide_by 125 -multiply_by 128 -source [get_pins {OSC_0.XTLOSC_CCC}] [get_pins {FCCC_0.GL0}]

create_generated_clock -name clk_20_48_hdc -divide_by 125 -multiply_by 128 -source [get_pins {OSC_0.XTLOSC_CCC}] [get_pins {FCCC_0.GL1}]

# create_clock -period 50.000 -waveform {0.000 25.000} -name {xtal_20MHz} [get_pins {OSC_0/I_XTLOSC:CLKOUT}] 

# create_generated_clock -name {clk_20_48} -divide_by {125} -multiply_by {128} -source [get_pins {OSC_0/I_XTLOSC:CLKOUT}]  [get_pins {FCCC_0/GL0_INST:Y}] 
