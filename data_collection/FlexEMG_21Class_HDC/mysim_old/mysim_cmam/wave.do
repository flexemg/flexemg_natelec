onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider TOP_LEVEL_IO
add wave -noupdate -label PCLK -radix binary /cm_tb/cm_top_0/PCLK
add wave -noupdate -label PRESETN -radix binary /cm_tb/cm_top_0/PRESETN
add wave -noupdate -label PENABLE -radix binary /cm_tb/cm_top_0/PENABLE
add wave -noupdate -label PSEL -radix binary /cm_tb/cm_top_0/PSEL
add wave -noupdate -label PWRITE -radix binary /cm_tb/cm_top_0/PWRITE
add wave -noupdate -label PADDR -radix hexadecimal /cm_tb/cm_top_0/PADDR
add wave -noupdate -label PWDATA -radix hexadecimal /cm_tb/cm_top_0/PWDATA
add wave -noupdate -label PRDATA -radix hexadecimal /cm_tb/cm_top_0/PRDATA
add wave -noupdate -label nmif_PRDATA -radix hexadecimal /cm_tb/cm_top_0/cm_if_apb_0/nmif_PRDATA
add wave -noupdate -label acc_PRDATA -radix hexadecimal /cm_tb/cm_top_0/cm_if_apb_0/acc_PRDATA
add wave -noupdate -label wr_enable -radix binary /cm_tb/cm_top_0/cm_if_apb_0/wr_enable
add wave -noupdate -label rd_enable -radix binary /cm_tb/cm_top_0/cm_if_apb_0/rd_enable
add wave -noupdate -label C2N_valid_0 -radix binary /cm_tb/cm_top_0/C2N_VALID_0
add wave -noupdate -label C2N_data_0 -radix binary /cm_tb/cm_top_0/C2N_DATA_0
add wave -noupdate -label N2C_data_0 -radix binary /cm_tb/cm_top_0/N2C_DATA_0
add wave -noupdate -label C2N_valid_1 -radix binary /cm_tb/cm_top_0/C2N_VALID_1
add wave -noupdate -label C2N_data_1 -radix binary /cm_tb/cm_top_0/C2N_DATA_1
add wave -noupdate -label N2C_data_1 -radix binary /cm_tb/cm_top_0/N2C_DATA_1
add wave -noupdate -label I2C_SCL -radix binary /cm_tb/cm_top_0/I2C_SCL
add wave -noupdate -label I2C_SDA_I -radix binary /cm_tb/cm_top_0/I2C_SDA_I
add wave -noupdate -label I2C_SDA_O -radix binary /cm_tb/cm_top_0/I2C_SDA_O
#add wave -noupdate -label SPI_0_CLK_0 -radix binary /cm_tb/cm_top_0/SPI_0_CLK_0
#add wave -noupdate -label SPI_0_DO -radix binary /cm_tb/cm_top_0/SPI_0_DO
#add wave -noupdate -label SPI_0_DI -radix binary /cm_tb/cm_top_0/SPI_0_DI
#add wave -noupdate -label SPI_0_SS0_0 -radix binary /cm_tb/cm_top_0/SPI_0_SS0_0

add wave -noupdate -divider ENABLE_FLAGS
add wave -noupdate -label fft_en -radix binary /cm_tb/cm_top_0/cm_if_apb_0/fft_en
add wave -noupdate -label pdma_en -radix binary /cm_tb/cm_top_0/cm_if_apb_0/pdma_en
add wave -noupdate -label acc_irq_en -radix binary /cm_tb/cm_top_0/cm_if_apb_0/acc_irq_en
add wave -noupdate -label artifact_en -radix binary /cm_tb/cm_top_0/cm_if_apb_0/artifact_en

add wave -noupdate -divider EMULATE_FLAGS
add wave -noupdate -label emulate_nm0 -radix hexadecimal /cm_tb/cm_top_0/cm_if_apb_0/emulate_nm_0
add wave -noupdate -label emulate_nm1 -radix hexadecimal /cm_tb/cm_top_0/cm_if_apb_0/emulate_nm_1
add wave -noupdate -label emulate_acc -radix hexadecimal /cm_tb/cm_top_0/cm_if_apb_0/emulate_acc
add wave -noupdate -label emulate_pdma -radix hexadecimal /cm_tb/cm_top_0/cm_if_apb_0/emulate_pdma

add wave -noupdate -divider NM_RESET
add wave -noupdate -label link_rst_type -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_if_apb_0/link_rst_type
add wave -noupdate -label rst_start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_if_apb_0/rst_start
add wave -noupdate -label rst_busy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_if_apb_0/rst_busy

add wave -noupdate -divider DEBUG
add wave -noupdate -label cm_apb_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/cm_apb_debug
add wave -noupdate -label nrx_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/nrx_debug
add wave -noupdate -label ntx_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/ntx_debug
add wave -noupdate -label adc_dp_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/adc_dp_debug
add wave -noupdate -label adc_dp_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/adc_vec_debug
add wave -noupdate -label ack_dp_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/adc_art_debug
add wave -noupdate -label adc_dp_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/adc_fft_debug
add wave -noupdate -label ack_dp_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/ack_dp_debug
add wave -noupdate -label pdma_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/pdma_debug
add wave -noupdate -label nm0_adc_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/nm0_adc_debug
add wave -noupdate -label acc_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/acc_debug
add wave -noupdate -label top_debug -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/top_debug
add wave -noupdate -label debug_out -radix hexadecimal /cm_tb/cm_top_0/debug_mux_0/debug_out
add wave -noupdate -label debug_sel -radix binary /cm_tb/cm_top_0/debug_mux_0/chan_sel

add wave -noupdate -divider NM_CHANNEL_0
add wave -noupdate -label clk_0 -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/clk
add wave -noupdate -label rstb_0 -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/rstb
add wave -noupdate -label clk_0 -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/c2n_data
add wave -noupdate -label clk_0 -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/c2n_valid
add wave -noupdate -label clk_0 -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/n2c_data
add wave -noupdate -label n2c_data -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/n2c_data
add wave -noupdate -label adc_fifo_empty -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_fifo_empty
add wave -noupdate -label adc_fifo_dout -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_fifo_dout
add wave -noupdate -label ack_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_rdy
add wave -noupdate -label ack_dout -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_dout
add wave -noupdate -label tx_start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/tx_start
add wave -noupdate -label tx_mode -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/tx_mode
add wave -noupdate -label tx_data -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/tx_data
add wave -noupdate -label tx_busy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/tx_busy
add wave -noupdate -label tx_data_rb -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/tx_data_rb
add wave -noupdate -label adc_vec_bits -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_vec_bits
add wave -noupdate -label adc_fifo_pop -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_fifo_pop

add wave -noupdate -divider nmic_tx
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/rstb
add wave -noupdate -label twoMHz_stb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/twoMHz_stb
add wave -noupdate -label tx_mode -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_mode
add wave -noupdate -label tx_start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_start
add wave -noupdate -label tx_start_reg -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_start_reg
add wave -noupdate -label tx_busy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_busy
add wave -noupdate -label tx_done -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_done
add wave -noupdate -label data -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_data_in
add wave -noupdate -label data_rb -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_data_in_rb
add wave -noupdate -label dbit -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/dbit
add wave -noupdate -label tx_crc -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_crc
add wave -noupdate -label tx_length -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/tx_length
add wave -noupdate -label rst_start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/rst_start
add wave -noupdate -label rst_start_reg -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/rst_start_reg
add wave -noupdate -label rst_busy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/rst_busy
add wave -noupdate -label rst_done -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/rst_done
add wave -noupdate -label c2n_valid -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/c2n_valid
add wave -noupdate -label c2n_data -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/c2n_data
add wave -noupdate -label cnt_en -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/bc_inc
add wave -noupdate -label cnt_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/bc_rst
add wave -noupdate -label bit_count -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/bit_count
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/next_state

add wave -noupdate -divider nmic_rx
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/rstb
add wave -noupdate -label twoMHz_stb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_tx_0/twoMHz_stb
add wave -noupdate -label rx_bit -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/rx_bit
add wave -noupdate -label rx_bit_sampled -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/rx_bit_sampled
add wave -noupdate -label adc_rx_start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/adc_rx_start
add wave -noupdate -label ack_rx_start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/ack_rx_start
add wave -noupdate -label pkt_done -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/pkt_done
add wave -noupdate -label bit_valid -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/bit_valid
add wave -noupdate -label sync_shift_reg -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/sync_shift_reg
add wave -noupdate -label sync -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/sync
add wave -noupdate -label bc_dec -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/bc_dec
add wave -noupdate -label bc_preset -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/bc_preset
add wave -noupdate -label bit_count -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/bit_count
add wave -noupdate -label pktType -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/pktType
add wave -noupdate -label crc_ok -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/crc_ok
add wave -noupdate -label crc_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/crc_rst
add wave -noupdate -label crc_init -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/crc_init
add wave -noupdate -label crc_compute -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/crc_compute
add wave -noupdate -label crc -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/crc
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/next_state

add wave -noupdate -divider ack_datapath
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/clk
add wave -noupdate -label start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/start
add wave -noupdate -label rx_bit -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/rx_bit
add wave -noupdate -label rx_bit_valid -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/rx_bit_valid
add wave -noupdate -label crc_ok -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/crc_ok
add wave -noupdate -label pkt_done -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/pkt_done
add wave -noupdate -label ack_read -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/ack_read
add wave -noupdate -label ack_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/ack_rdy
add wave -noupdate -label ack_dout -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/ack_dout
add wave -noupdate -label bc_preset -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/bc_preset
add wave -noupdate -label bc_dec -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/bc_dec
add wave -noupdate -label bit_ctr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/bit_ctr
add wave -noupdate -label bc_zero -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/bc_zero
add wave -noupdate -label sh_en -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/sh_en
add wave -noupdate -label sh_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/sh_rst
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/ack_datapath_0/next_state

add wave -noupdate -divider adc_datapath
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/rstb
add wave -noupdate -label artifact_en -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/artifact_en
add wave -noupdate -label start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/start
add wave -noupdate -label pkt_done -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/nmic_rx_0/pkt_done
add wave -noupdate -label frame_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/frame_rdy
add wave -noupdate -label vector_bits -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/vector_bits
add wave -noupdate -label rx_bit -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/rx_bit
add wave -noupdate -label rx_bit_valid -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/rx_bit_valid
add wave -noupdate -label fifo_push -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/ADCFIFO_0/WE
add wave -noupdate -label fifo_full -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/ADCFIFO_0/FULL
add wave -noupdate -label fifo_pop -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/ADCFIFO_0/RE
add wave -noupdate -label fifo_empty -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/ADCFIFO_0/EMPTY
add wave -noupdate -label fifo_dout -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/ADCFIFO_0/Q

add wave -noupdate -divider adc_vector_compressor_0
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/rstb
add wave -noupdate -label start -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/start
add wave -noupdate -label pkt_done -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/pkt_done
add wave -noupdate -label crc_ok -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/crc_ok
add wave -noupdate -label num_active_chans -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/num_active_chans
add wave -noupdate -label frame_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/frame_rdy
add wave -noupdate -label frame -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/frame
add wave -noupdate -label mem_addr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_addr
add wave -noupdate -label mem_wr_data -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_wr_data
add wave -noupdate -label mem_we -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_we
add wave -noupdate -label mem_re -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_re
add wave -noupdate -label fifo_full -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/fifo_full
add wave -noupdate -label fifo_push -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/fifo_push
add wave -noupdate -label fifo_pop -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/fifo_pop
add wave -noupdate -label vector_bits -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/vector_bits
add wave -noupdate -label chan_cnt_preset -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/chan_cnt_preset
add wave -noupdate -label chan_cnt_dec -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/chan_cnt_dec
add wave -noupdate -label chan_cnt -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/chan_cnt
add wave -noupdate -label mem_idx_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_idx_rst
add wave -noupdate -label mem_idx_inc -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_idx_inc
add wave -noupdate -label mem_idx -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_idx
add wave -noupdate -label mem_head_ptr_inc -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_head_ptr_inc
add wave -noupdate -label mem_head_ptr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_head_ptr
add wave -noupdate -label mem_tail_ptr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/mem_tail_ptr
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_vector_compressor_0/next_state

add wave -noupdate -divider adc_artifact_cancel_0
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/rstb
add wave -noupdate -label artifact_en -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/artifact_en
add wave -noupdate -label stim_flag -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/stim_flag
add wave -noupdate -label frame_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/frame_rdy
add wave -noupdate -label num_active_chans -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/num_active_chans
add wave -noupdate -label mem_addr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/mem_addr
add wave -noupdate -label mem_dout -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/mem_dout
add wave -noupdate -label mem_wr_data -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/mem_wr_data
add wave -noupdate -label mem_we -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/mem_we
add wave -noupdate -label mem_re -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/mem_re
add wave -noupdate -label active_chans -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/active_chans
add wave -noupdate -label frame_ptr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/frame_ptr
add wave -noupdate -label mem_head_ptr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/mem_head_ptr
add wave -noupdate -label pre_stim_frame_ptr -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/pre_stim_frame_ptr
add wave -noupdate -label rdata_head -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/rdata_head
add wave -noupdate -label rdata_pre_stim -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/rdata_pre_stim
add wave -noupdate -label frame_idx_preset -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/frame_idx_preset
add wave -noupdate -label frame_idx_inc -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/frame_idx_inc
add wave -noupdate -label frame_idx -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/frame_idx
add wave -noupdate -label chan_idx_inc -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/chan_idx_inc
add wave -noupdate -label chan_idx_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/chan_idx_rst
add wave -noupdate -label chan_idx -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/chan_idx
add wave -noupdate -label stim_count -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/stim_count
add wave -noupdate -label stim_count_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/stim_count_rst
add wave -noupdate -label stim_count_inc -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/stim_count_inc
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_artifact_cancel_0/next_state

add wave -noupdate -divider FFT
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/rstb
add wave -noupdate -label enable -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/enable
add wave -noupdate -label frame_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/frame_rdy
add wave -noupdate -label chan -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/chan
add wave -noupdate -label chan_cnt -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/chan_cnt
add wave -noupdate -label chan_cnt_inc -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/chan_cnt_inc
add wave -noupdate -label chan_cnt_rst -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/chan_cnt_rst
add wave -noupdate -label chan_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/chan_rdy
add wave -noupdate -label irq -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/irq
add wave -noupdate -label fft_datai_valid -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/fft_datai_valid
add wave -noupdate -label fft_datao_valid -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/fft_datao_valid
add wave -noupdate -label fft_buf_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/fft_buf_rdy
add wave -noupdate -label fft_outp_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/fft_outp_rdy
add wave -noupdate -label fft_read_outp -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/fft_read_outp
add wave -noupdate -label fft_re_in -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/fft_re_in
add wave -noupdate -label fft_out -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/fft_out
add wave -noupdate -label rd_strobe -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/rd_strobe
add wave -noupdate -label fft_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/fft_rdy
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/nm_channel_0/adc_datapath_0/adc_fft_if_0/adc_fft_cntl_0/next_state

add wave -noupdate -divider PDMA_IF
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/rstb
add wave -noupdate -label adc_fifo_dout_n0 -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_fifo_dout_n0
add wave -noupdate -label adc_data_rdy_n0 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_frame_rdy_n0
add wave -noupdate -label adc_fifo_empty_n0 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_fifo_empty_n0
add wave -noupdate -label adc_fifo_pop_n0 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_fifo_pop_n0
add wave -noupdate -label adc_fifo_dout_n1 -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_fifo_dout_n1
add wave -noupdate -label adc_data_rdy_n1 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_frame_rdy_n1
add wave -noupdate -label adc_fifo_empty_n1 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_fifo_empty_n1
add wave -noupdate -label adc_fifo_pop_n1 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/adc_fifo_pop_n1
add wave -noupdate -label acc_data -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/pdma_if_0/acc_data
add wave -noupdate -label pdma_data -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_data
add wave -noupdate -label pdma_irq_req -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_done_irq_req
add wave -noupdate -label pdma_data_rdy -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_data_rdy
add wave -noupdate -label pdma_ena -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_en
add wave -noupdate -label pdma_fifo_push -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_fifo_push
add wave -noupdate -label pdma_fifo_pop -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_fifo_pop
add wave -noupdate -label fifo_pop_int -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/fifo_pop_int
add wave -noupdate -label pdma_fifo_pop_emu -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_fifo_pop_emu
add wave -noupdate -label pdma_fifo_clr -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_fifo_clr
add wave -noupdate -label pdma_fifo_full -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_fifo_full
add wave -noupdate -label pdma_fifo_din -radix hexadecimal /cm_tb/cm_top_0/nm_if_0/pdma_if_0/pdma_fifo_din
add wave -noupdate -label data_rdy_n0 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/data_rdy_n0
add wave -noupdate -label data_rdy_n1 -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/data_rdy_n1
add wave -noupdate -label latch_clr -radix binary /cm_tb/cm_top_0/nm_if_0/pdma_if_0/latch_clr
add wave -noupdate -label mux_sel -radix unsigned /cm_tb/cm_top_0/nm_if_0/pdma_if_0/mux_sel
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/pdma_if_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_if_0/pdma_if_0/next_state

add wave -noupdate -divider PDMA_SIM
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/pdma_sim_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/pdma_sim_0/rstb
add wave -noupdate -label run -radix binary /cm_tb/cm_top_0/pdma_sim_0/run
add wave -noupdate -label pdma_irq_req -radix binary /cm_tb/cm_top_0/pdma_sim_0/pdma_irq_req
add wave -noupdate -label pdma_data_rdy -radix binary /cm_tb/cm_top_0/pdma_sim_0/pdma_data_rdy
add wave -noupdate -label pdma_fifo_pop -radix binary /cm_tb/cm_top_0/pdma_sim_0/pdma_fifo_pop
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/pdma_sim_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/pdma_sim_0/next_state

add wave -noupdate -divider NM0_SIM
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_sim_0/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_sim_0/rstb
add wave -noupdate -label run -radix binary /cm_tb/cm_top_0/nm_sim_0/run
add wave -noupdate -label clk_div -radix unsigned /cm_tb/cm_top_0/nm_sim_0/clk_div
add wave -noupdate -label c2n_valid -radix binary /cm_tb/cm_top_0/nm_sim_0/c2n_valid
add wave -noupdate -label c2n_data -radix binary /cm_tb/cm_top_0/nm_sim_0/c2n_data
add wave -noupdate -label n2c_data -radix binary /cm_tb/cm_top_0/nm_sim_0/n2c_data

add wave -noupdate -divider adc_nm0
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/rstb
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/clk
add wave -noupdate -label twoMHz_stb -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/twoMHz_stb
add wave -noupdate -label tx_wait -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/tx_wait
add wave -noupdate -label tx_idle -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/tx_idle
add wave -noupdate -label dout -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/dout
add wave -noupdate -label bc_rst -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/bc_rst
add wave -noupdate -label bit_count -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_adc/bit_cnt
add wave -noupdate -label next_word -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/next_word
#add wave -noupdate -label wc_rst -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/wc_rst
#add wave -noupdate -label wc_inc -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/wc_inc
add wave -noupdate -label word_count -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_adc/word_cnt
add wave -noupdate -label end_of_packet -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/end_of_packet
add wave -noupdate -label next_packet -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/next_packet
add wave -noupdate -label sr_input -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_adc/sr_input
add wave -noupdate -label sr_load -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/sr_load
add wave -noupdate -label shift_reg -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_adc/shift_reg
add wave -noupdate -label crc_init -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/crc_init
add wave -noupdate -label crc_compute -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_adc/crc_compute
add wave -noupdate -label crc -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_adc/crc
add wave -noupdate -label num_stims -radix unsigned sim:/cm_tb/cm_top_0/nm_sim_0/nm_adc/num_stims
add wave -noupdate -label stim_count -radix unsigned sim:/cm_tb/cm_top_0/nm_sim_0/nm_adc/stim_cnt
add wave -noupdate -label stim_dec -radix binary sim:/cm_tb/cm_top_0/nm_sim_0/nm_adc/stim_dec
add wave -noupdate -label stim_ld -radix binary sim:/cm_tb/cm_top_0/nm_sim_0/nm_adc/stim_ld
add wave -noupdate -label stim -radix binary sim:/cm_tb/cm_top_0/nm_sim_0/nm_adc/stim
#add wave -noupdate -label random_num -radix unsigned sim:/cm_tb/cm_top_0/nm_sim_0/nm_adc/random_num
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_adc/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_adc/next_state

add wave -noupdate -divider cnr_nm0
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/rstb
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/clk
add wave -noupdate -label run -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/run
add wave -noupdate -label clk_counter -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_cnr/clk_counter
add wave -noupdate -label twoMHz_stb -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/twoMHz_stb
add wave -noupdate -label rx_valid -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/rx_valid
add wave -noupdate -label rx_bit -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/rx_bit
add wave -noupdate -label cmd_bit -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/cmd_bit
add wave -noupdate -label tx_rdy -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_rdy
add wave -noupdate -label tx_ok -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_ok
add wave -noupdate -label dout -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/dout
add wave -noupdate -label bc_rst -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/bc_rst
add wave -noupdate -label bc_inc -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/bc_inc
add wave -noupdate -label bit_count -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_cnr/bit_cnt
add wave -noupdate -label rx_shift_reg -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_cnr/rx_shift_reg
add wave -noupdate -label rx_sr_shift -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/rx_sr_shift
add wave -noupdate -label tx_shift_reg -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_shift_reg
add wave -noupdate -label tx_sr_load -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_sr_load
add wave -noupdate -label tx_sr_crc_load -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_sr_crc_load
add wave -noupdate -label tx_sr_shift -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_sr_shift
add wave -noupdate -label tx_crc_init -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_crc_init
add wave -noupdate -label tx_crc_go -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_crc_go
add wave -noupdate -label tx_crc_compute -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_crc_compute
add wave -noupdate -label crc -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_cnr/crc
add wave -noupdate -label tx_req -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/tx_req
add wave -noupdate -label idle -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/idle
add wave -noupdate -label addr -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_cnr/addr
add wave -noupdate -label data -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_cnr/data
add wave -noupdate -label nm_reg_file -radix hexadecimal /cm_tb/cm_top_0/nm_sim_0/nm_cnr/nm_reg_file
add wave -noupdate -label nm_regfile_write -radix binary /cm_tb/cm_top_0/nm_sim_0/nm_cnr/nm_regfile_write
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_cnr/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_sim_0/nm_cnr/next_state

add wave -noupdate -divider NM1_SIM
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_sim_1/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_sim_1/rstb
add wave -noupdate -label run -radix binary /cm_tb/cm_top_0/nm_sim_1/run
add wave -noupdate -label clk_div -radix unsigned /cm_tb/cm_top_0/nm_sim_1/clk_div
add wave -noupdate -label twoMHz_stb -radix binary /cm_tb/cm_top_0/nm_sim_1/twoMHz_stb
add wave -noupdate -label c2n_valid -radix binary /cm_tb/cm_top_0/nm_sim_1/c2n_valid
add wave -noupdate -label c2n_data -radix binary /cm_tb/cm_top_0/nm_sim_1/c2n_data

add wave -noupdate -divider adc_nm1
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/rstb
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/clk
add wave -noupdate -label twoMHz_stb -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/twoMHz_stb
add wave -noupdate -label tx_wait -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/tx_wait
add wave -noupdate -label tx_idle -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/tx_idle
add wave -noupdate -label dout -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/dout
add wave -noupdate -label bit_count -radix unsigned /cm_tb/cm_top_0/nm_sim_1/nm_adc/bit_cnt
add wave -noupdate -label next_word -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/next_word
#add wave -noupdate -label wc_rst -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/wc_rst
#add wave -noupdate -label wc_inc -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/wc_inc
add wave -noupdate -label word_count -radix unsigned /cm_tb/cm_top_0/nm_sim_1/nm_adc/word_cnt
add wave -noupdate -label end_of_packet -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/end_of_packet
add wave -noupdate -label next_packet -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/next_packet
add wave -noupdate -label sr_input -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/sr_input
add wave -noupdate -label sr_load -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/sr_load
add wave -noupdate -label shift_reg -radix hexadecimal /cm_tb/cm_top_0/nm_sim_1/nm_adc/shift_reg
add wave -noupdate -label crc_init -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/crc_init
add wave -noupdate -label crc_compute -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/crc_compute
add wave -noupdate -label crc -radix binary /cm_tb/cm_top_0/nm_sim_1/nm_adc/crc
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/nm_sim_1/nm_adc/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/nm_sim_1/nm_adc/next_state

add wave -noupdate -divider ACC_SIM
add wave -noupdate -label aclk -radix binary /cm_tb/cm_top_0/acc_sim_0/aclk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/acc_sim_0/rstb
add wave -noupdate -label scl -radix binary /cm_tb/cm_top_0/acc_sim_0/scl
add wave -noupdate -label sda_o -radix binary /cm_tb/cm_top_0/acc_sim_0/sda_o
add wave -noupdate -label sda_i -radix binary /cm_tb/cm_top_0/acc_sim_0/sda_i
add wave -noupdate -label bc_en -radix binary /cm_tb/cm_top_0/acc_sim_0/bc_en
add wave -noupdate -label bc_rst -radix binary /cm_tb/cm_top_0/acc_sim_0/bc_rst
add wave -noupdate -label bc_cnt -radix unsigned /cm_tb/cm_top_0/acc_sim_0/bc_cnt
add wave -noupdate -label reg_en -radix binary /cm_tb/cm_top_0/acc_sim_0/reg_en
add wave -noupdate -label reg_ld_hdr -radix binary /cm_tb/cm_top_0/acc_sim_0/reg_ld_hdr
add wave -noupdate -label reg_ld_rd_data -radix binary /cm_tb/cm_top_0/acc_sim_0/reg_ld_rd_data
add wave -noupdate -label reg_ld_wr_data -radix binary /cm_tb/cm_top_0/acc_sim_0/reg_ld_wr_data
add wave -noupdate -label sda_reg -radix binary /cm_tb/cm_top_0/acc_sim_0/sda_reg
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/acc_sim_0/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/acc_sim_0/next_state

add wave -noupdate -divider ACC_IF
add wave -noupdate -label pclk -radix binary /cm_tb/cm_top_0/acc_if_0/pclk
add wave -noupdate -label aclk -radix binary /cm_tb/cm_top_0/acc_if_0/aclk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/acc_if_0/rstb
add wave -noupdate -label addr -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/addr
add wave -noupdate -label data_wr -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/data_wr
add wave -noupdate -label wr_enable -radix binary /cm_tb/cm_top_0/acc_if_0/wr_enable
add wave -noupdate -label data_rd -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/data_rd
add wave -noupdate -label rd_enable -radix binary /cm_tb/cm_top_0/acc_if_0/rd_enable
add wave -noupdate -label acc_irq -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq
add wave -noupdate -label i2c_scl -radix binary /cm_tb/cm_top_0/acc_if_0/i2c_scl
add wave -noupdate -label i2c_sda_o -radix binary /cm_tb/cm_top_0/acc_if_0/i2c_sda_o
add wave -noupdate -label i2c_sda_i -radix binary /cm_tb/cm_top_0/acc_if_0/i2c_sda_i
add wave -noupdate -label acc_data -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/acc_data
add wave -noupdate -label apb_scl -radix binary /cm_tb/cm_top_0/acc_if_0/apb_scl
add wave -noupdate -label apb_sda_o -radix binary /cm_tb/cm_top_0/acc_if_0/apb_sda_o
add wave -noupdate -label apb_sda_i -radix binary /cm_tb/cm_top_0/acc_if_0/apb_sda_i
add wave -noupdate -label irq_scl -radix binary /cm_tb/cm_top_0/acc_if_0/irq_scl
add wave -noupdate -label irq_sda_o -radix binary /cm_tb/cm_top_0/acc_if_0/irq_sda_o
add wave -noupdate -label irq_sda_i -radix binary /cm_tb/cm_top_0/acc_if_0/irq_sda_i
add wave -noupdate -label mux_sel -radix unsigned /cm_tb/cm_top_0/acc_if_0/mux_sel
add wave -noupdate -label apb_reg_rd_ok -radix binary /cm_tb/cm_top_0/acc_if_0/apb_reg_rd_ok
add wave -noupdate -label apb_reg_wr_ok -radix binary /cm_tb/cm_top_0/acc_if_0/apb_reg_wr_ok
add wave -noupdate -label acc_irq_en -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_en
add wave -noupdate -label acc_irq_ok -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_ok
add wave -noupdate -label I2C_SCL -radix binary /cm_tb/cm_top_0/I2C_SCL
add wave -noupdate -label I2C_SDA_I -radix binary /cm_tb/cm_top_0/I2C_SDA_I
add wave -noupdate -label I2C_SDA_O -radix binary /cm_tb/cm_top_0/I2C_SDA_O

add wave -noupdate -divider acc_apb
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/rstb
add wave -noupdate -label addr -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/acc_apb_p/addr
add wave -noupdate -label data_wr -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/acc_apb_p/data_wr
add wave -noupdate -label wren_latch -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/wren_latch
add wave -noupdate -label wren_clr -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/wren_clr
add wave -noupdate -label data_rd -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/acc_apb_p/data_rd
add wave -noupdate -label rden_latch -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/rden_latch
add wave -noupdate -label rden_clr -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/rden_clr
add wave -noupdate -label apb_scl -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/scl
add wave -noupdate -label apb_sda_o -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/sda_o
add wave -noupdate -label apb_sda_i -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/sda_i
add wave -noupdate -label scl_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/scl_reg
add wave -noupdate -label sda_o_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/sda_o_reg
add wave -noupdate -label sda_i_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/sda_i_reg
add wave -noupdate -label rd_ok -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/rd_ok
add wave -noupdate -label wr_ok -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/wr_ok
add wave -noupdate -label reg_en -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/reg_en
add wave -noupdate -label bc_en -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/bc_en
add wave -noupdate -label reg_ld_rd -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/reg_ld_rd
add wave -noupdate -label reg_ld_wr -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/reg_ld_wr
add wave -noupdate -label rd_active -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/rd_active
add wave -noupdate -label wr_active -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/wr_active
add wave -noupdate -label ack_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/ack_reg
add wave -noupdate -label result_ld -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/result_ld
add wave -noupdate -label rd_result_reg -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/acc_apb_p/rd_result_reg
add wave -noupdate -label bc_rst -radix binary /cm_tb/cm_top_0/acc_if_0/acc_apb_p/bc_rst
add wave -noupdate -label bc_cnt -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_apb_p/bc_cnt
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_apb_p/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_apb_p/next_state

add wave -noupdate -divider acc_irq
add wave -noupdate -label clk -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/clk
add wave -noupdate -label rstb -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/rstb
add wave -noupdate -label apb_req -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_irq_p/apb_req
add wave -noupdate -label apb_grant -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_irq_p/apb_grant
add wave -noupdate -label mux_sel -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_irq_p/mux_sel
add wave -noupdate -label acc_irq -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/acc_irq
add wave -noupdate -label scl -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/scl
add wave -noupdate -label sda_o -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/sda_o
add wave -noupdate -label sda_i -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/sda_i
add wave -noupdate -label scl_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/scl_reg
add wave -noupdate -label sda_o_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/sda_o_reg
add wave -noupdate -label sda_i_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/sda_i_reg
add wave -noupdate -label acc_data -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/acc_data
add wave -noupdate -label irq_en -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/irq_en
add wave -noupdate -label irq_ok -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/irq_ok
add wave -noupdate -label reg_en -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/reg_en
add wave -noupdate -label reg_ld -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/reg_ld
add wave -noupdate -label acc_ld -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/acc_ld
add wave -noupdate -label ack_reg -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/ack_reg
add wave -noupdate -label bc_en -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/bc_en
add wave -noupdate -label bc_rst -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/bc_rst
add wave -noupdate -label bc_cnt -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_irq_p/bc_cnt
add wave -noupdate -label data_rdy -radix binary /cm_tb/cm_top_0/acc_if_0/acc_irq_p/data_rdy
add wave -noupdate -label int_status_bits -radix hexadecimal /cm_tb/cm_top_0/acc_if_0/acc_irq_p/int_status_bits
add wave -noupdate -label current_state -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_irq_p/current_state
add wave -noupdate -label next_state -radix unsigned /cm_tb/cm_top_0/acc_if_0/acc_irq_p/next_state

TreeUpdate [SetDefaultTree]
#WaveRestoreCursors {{Cursor 1} {512150000000 fs} 0} {{Cursor 2} {1527099328666 fs} 0}
#quietly wave cursor active 2
configure wave -namecolwidth 150
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
configure wave -timelineunits us
update
#WaveRestoreZoom {0 fs} {1575105 ns}

