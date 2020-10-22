onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {APB signals}
add wave -noupdate -format Literal /testbench/DUT/PADDR
add wave -noupdate -format Logic /testbench/DUT/PCLK
add wave -noupdate -format Logic /testbench/DUT/PSEL
add wave -noupdate -format Logic /testbench/DUT/PENABLE
add wave -noupdate -format Logic /testbench/DUT/PWRITE
add wave -noupdate -format Literal -radix hexadecimal /testbench/DUT/PRDATA
add wave -noupdate -format Literal -radix hexadecimal /testbench/DUT/PWDATA
add wave -noupdate -format Logic /testbench/DUT/PRESETN
add wave -noupdate -divider GPIO
add wave -noupdate -format Literal /testbench/DUT/GPIO_IN
add wave -noupdate -format Literal /testbench/DUT/GPIO_OE
add wave -noupdate -format Literal /testbench/DUT/GPIO_OUT
add wave -noupdate -format Literal /testbench/DUT/INT
add wave -noupdate -format Logic /testbench/DUT/INT_OR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48252200 ps} 0}
configure wave -namecolwidth 441
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {66731700 ps}
