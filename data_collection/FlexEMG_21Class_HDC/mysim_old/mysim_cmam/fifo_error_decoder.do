force -freeze sim:/fifo_error_decoder/clk 1 0, 0 {250ns} -r 500ns
force rstb 0
force sim:/fifo_error_decoder/pdma_overflow 0
force sim:/fifo_error_decoder/nm1_adc_overflow 0
force sim:/fifo_error_decoder/nm0_adc_overflow 0
force sim:/fifo_error_decoder/pdma_underflow 0
force sim:/fifo_error_decoder/nm0_adc_underflow 0
force sim:/fifo_error_decoder/nm1_adc_underflow 0
run 1 ms
force rstb 1
run 1 sec

force sim:/fifo_error_decoder/pdma_overflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_overflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/nm1_adc_overflow 1
run 5 sec
force sim:/fifo_error_decoder/nm1_adc_overflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/nm0_adc_overflow 1
run 5 sec
force sim:/fifo_error_decoder/nm0_adc_overflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/pdma_overflow 1
force sim:/fifo_error_decoder/nm1_adc_overflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_overflow 0
force sim:/fifo_error_decoder/nm1_adc_overflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/pdma_overflow 1
force sim:/fifo_error_decoder/nm0_adc_overflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_overflow 0
force sim:/fifo_error_decoder/nm0_adc_overflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/nm1_adc_overflow 1
force sim:/fifo_error_decoder/nm0_adc_overflow 1
run 5 sec
force sim:/fifo_error_decoder/nm1_adc_overflow 0
force sim:/fifo_error_decoder/nm0_adc_overflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/pdma_overflow 1
force sim:/fifo_error_decoder/nm1_adc_overflow 1
force sim:/fifo_error_decoder/nm0_adc_overflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_overflow 0
force sim:/fifo_error_decoder/nm1_adc_overflow 0
force sim:/fifo_error_decoder/nm0_adc_overflow 0
force rstb 0
run 1ms
force rstb 1


force rstb 0
run 1 sec
force rstb 1
run 1 ms

force sim:/fifo_error_decoder/pdma_underflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_underflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/nm1_adc_underflow 1
run 5 sec
force sim:/fifo_error_decoder/nm1_adc_underflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/nm0_adc_underflow 1
run 5 sec
force sim:/fifo_error_decoder/nm0_adc_underflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/pdma_underflow 1
force sim:/fifo_error_decoder/nm1_adc_underflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_underflow 0
force sim:/fifo_error_decoder/nm1_adc_underflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/pdma_underflow 1
force sim:/fifo_error_decoder/nm0_adc_underflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_underflow 0
force sim:/fifo_error_decoder/nm0_adc_underflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/nm1_adc_underflow 1
force sim:/fifo_error_decoder/nm0_adc_underflow 1
run 5 sec
force sim:/fifo_error_decoder/nm1_adc_underflow 0
force sim:/fifo_error_decoder/nm0_adc_underflow 0
force rstb 0
run 1ms
force rstb 1

force sim:/fifo_error_decoder/pdma_underflow 1
force sim:/fifo_error_decoder/nm1_adc_underflow 1
force sim:/fifo_error_decoder/nm0_adc_underflow 1
run 5 sec
force sim:/fifo_error_decoder/pdma_underflow 0
force sim:/fifo_error_decoder/nm1_adc_underflow 0
force sim:/fifo_error_decoder/nm0_adc_underflow 0
force rstb 0
run 1ms
force rstb 1


