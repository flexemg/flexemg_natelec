# Written by Synplify Pro version map201609actrcp1, Build 005R. Synopsys Run ID: sid1554497666 
# Top Level Design Parameters 

# Clocks 
create_clock -period 50.000 -waveform {0.000 25.000} -name {xtal_20MHz} [get_pins {OSC_0/I_XTLOSC:CLKOUT}] 

# Virtual Clocks 

# Generated Clocks 
create_generated_clock -name {clk_20_48} -divide_by {125} -multiply_by {128} -source [get_pins {OSC_0/I_XTLOSC:CLKOUT}]  [get_pins {FCCC_0/GL0_INST:Y}] 
create_generated_clock -name {clk_20_48_hdc} -divide_by {125} -multiply_by {128} -source [get_pins {OSC_0/I_XTLOSC:CLKOUT}]  [get_pins {FCCC_0/GL1_INST:Y}] 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 

# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

