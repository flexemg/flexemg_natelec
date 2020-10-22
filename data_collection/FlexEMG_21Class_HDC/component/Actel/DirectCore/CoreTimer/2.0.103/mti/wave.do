onerror {resume}
quietly virtual signal -install /testbench/UTIM {/testbench/UTIM/CtrlReg[0]  } TIMER_ENABLE
quietly virtual signal -install /testbench/UTIM {/testbench/UTIM/CtrlReg[1]  } INTERRUPT_ENABLE
quietly virtual signal -install /testbench/UTIM {/testbench/UTIM/CtrlReg[2]  } TIMER_MODE
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {APB Signals}
add wave -noupdate -label PCLK /testbench/PCLK
add wave -noupdate -label PRESETN /testbench/PRESETN
add wave -noupdate -label PENABLE /testbench/PENABLE
add wave -noupdate -label PSEL -radix hexadecimal /testbench/PSEL
add wave -noupdate -label PADDR -radix hexadecimal /testbench/PADDR
add wave -noupdate -label PWRITE /testbench/PWRITE
add wave -noupdate -label PWDATA /testbench/PWDATA
add wave -noupdate -label PRDATA /testbench/PRDATA
add wave -noupdate -divider {CoreTimer Outputs & Registers}
add wave -noupdate -label TIMINT /testbench/TIMINT
add wave -noupdate -label Load_Register -radix hexadecimal /testbench/UTIM/Load
add wave -noupdate -label Clock_Prescale_Setting -radix hexadecimal /testbench/UTIM/TimerPre
add wave -noupdate -label Current_Value_Register -radix hexadecimal /testbench/UTIM/Count
add wave -noupdate -expand -group Timer_Control_Register -label Timer_Enable /testbench/UTIM/TIMER_ENABLE
add wave -noupdate -expand -group Timer_Control_Register -label Interrupt_Enable /testbench/UTIM/INTERRUPT_ENABLE
add wave -noupdate -expand -group Timer_Control_Register -label Timer_Mode /testbench/UTIM/TIMER_MODE
add wave -noupdate -divider {CoreTimer Internal Signals}
add wave -noupdate /testbench/UTIM/PreScale
add wave -noupdate /testbench/UTIM/CountPulse
add wave -noupdate /testbench/UTIM/OneShotClr
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 198
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
WaveRestoreZoom {0ps} {20000000 ps}
