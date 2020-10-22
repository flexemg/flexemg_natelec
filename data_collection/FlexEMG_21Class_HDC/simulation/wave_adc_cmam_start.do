onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider top_level_IO
add wave -noupdate -label clk -radix binary /cmam_tb/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/rstb
add wave -noupdate -label addr -radix hexadecimal /cmam_tb/addr
add wave -noupdate -label data_wr -radix hexadecimal /cmam_tb/data_wr
add wave -noupdate -label wren -radix binary /cmam_tb/wren
add wave -noupdate -label data_rd -radix hexadecimal /cmam_tb/data_rd
add wave -noupdate -label cmam_data_rd -radix hexadecimal /cmam_tb/cmam_data_rd
add wave -noupdate -label acc_data_rd -radix hexadecimal /cmam_tb/acc_data_rd
add wave -noupdate -label rden -radix binary /cmam_tb/rden
add wave -noupdate -label a2n_valid -radix binary /cmam_tb/a2n_valid
add wave -noupdate -label a2n_data -radix binary /cmam_tb/a2n_data
add wave -noupdate -label n2a_data -radix binary /cmam_tb/n2a_data
add wave -noupdate -label debug -radix hexadecimal /cmam_tb/debug
add wave -noupdate -label nm_has_adc -radix binary /cmam_tb/cmam_m/nif/nm_has_adc
add wave -noupdate -label adc_fifo_empty -radix hexadecimal /cmam_tb/cmam_m/nif/adc_fifo_empty
add wave -noupdate -divider NM_CHANNEL_0
add wave -noupdate -label clk_0 -radix binary /cmam_tb/cmam_m/nif/nmc0/clk
add wave -noupdate -label rstb_0 -radix binary /cmam_tb/cmam_m/nif/nmc0/rstb
add wave -noupdate -label rx_bit -radix binary /cmam_tb/cmam_m/nif/nmc0/rx_bit
add wave -noupdate -label rx_data_strobe -radix binary /cmam_tb/cmam_m/nif/nmc0/rx_data_strobe
add wave -noupdate -label adc_rx_start -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_rx_start
add wave -noupdate -label adc_fifo_empty -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_fifo_empty
add wave -noupdate -label adc_fifo_dout -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_fifo_dout
add wave -noupdate -label has_ackdata -radix binary /cmam_tb/cmam_m/nif/nmc0/has_ackdata
add wave -noupdate -label ack_fifo_dout -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/ack_fifo_dout
add wave -noupdate -label tx_start -radix binary /cmam_tb/cmam_m/nif/nmc0/tx_start
add wave -noupdate -label tx_mode -radix binary /cmam_tb/cmam_m/nif/nmc0/tx_mode
add wave -noupdate -label tx_data_strobe -radix binary /cmam_tb/cmam_m/nif/nmc0/tx_data_strobe
add wave -noupdate -label tx_data -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/tx_data
add wave -noupdate -label tx_bit_valid -radix binary /cmam_tb/cmam_m/nif/nmc0/tx_bit_valid
add wave -noupdate -label a2n_data -radix binary /cmam_tb/cmam_m/nif/nmc0/tx_bit
add wave -noupdate -label tx_bit -radix binary /cmam_tb/cmam_m/nif/nmc0/tx_busy
add wave -noupdate -label tx_data_rb -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/tx_data_rb
add wave -noupdate -label bit_valid -radix binary /cmam_tb/cmam_m/nif/nmc0/bit_valid
add wave -noupdate -label ack_rx_start -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_rx_start
add wave -noupdate -label crc_ok -radix binary /cmam_tb/cmam_m/nif/nmc0/crc_ok
add wave -noupdate -label pkt_done -radix binary /cmam_tb/cmam_m/nif/nmc0/pkt_done
add wave -noupdate -label adc_vec_bits -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_vec_bits
add wave -noupdate -label ack_fifo_pop -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_fifo_pop
add wave -noupdate -label adc_fifo_pop -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_fifo_pop
add wave -noupdate -divider nmic_rx
add wave -noupdate -label clk -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/cmam_m/nif/nmc0/rstb
add wave -noupdate -label rx_bit -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/rx_bit
add wave -noupdate -label pkt_done -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/pkt_done
add wave -noupdate -label bit_valid -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/bit_valid
add wave -noupdate -label sync_shift_reg -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/sync_shift_reg
add wave -noupdate -label sync -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/sync
add wave -noupdate -label bc_count -radix unsigned /cmam_tb/cmam_m/nif/nmc0/nrx/bc_count
add wave -noupdate -label pktType -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/pktType
add wave -noupdate -label bc_dec -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/bc_dec
add wave -noupdate -label bc_preset -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/bc_preset
add wave -noupdate -label crc_ok -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/crc_ok
add wave -noupdate -label crc_rst -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/crc_rst
add wave -noupdate -label crc_init -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/crc_init
add wave -noupdate -label crc_compute -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/crc_compute
add wave -noupdate -label crc -radix binary /cmam_tb/cmam_m/nif/nmc0/nrx/crc
add wave -noupdate -label current_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/nrx/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/nrx/next_state
add wave -noupdate -divider ack_datapath
add wave -noupdate -label start -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/start
add wave -noupdate -label fifo_dout -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_dout
add wave -noupdate -label fifo_not_empty -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_not_empty
add wave -noupdate -label fifo_push -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_push
add wave -noupdate -label fifo_pop -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_pop
add wave -noupdate -label fifo_empty -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_empty
add wave -noupdate -label fifo_din -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_din
add wave -noupdate -label fifo_full -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/fifo_full
add wave -noupdate -label bitPos -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/bitPos
add wave -noupdate -label bc_preset -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/bc_preset
add wave -noupdate -label bc_dec -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/bc_dec
add wave -noupdate -label shift -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/shift
add wave -noupdate -label bc_zero -radix binary /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/bc_zero
add wave -noupdate -label current_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ack_dp/ads/next_state
add wave -noupdate -divider adc_datapath
add wave -noupdate -label start -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/start
add wave -noupdate -label vector_bits -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_dp/vector_bits
add wave -noupdate -label fifo_empty -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/fifo_empty
add wave -noupdate -label fifo_din -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_dp/selected_data
add wave -noupdate -label fifo_push -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/fifo_push
add wave -noupdate -label fifo_dout -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_dp/fifo_dout
add wave -noupdate -label fifo_pop -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/fifo_pop
add wave -noupdate -label fifo_din_n1 -radix hexadecimal /cmam_tb/cmam_m/nif/nmc1/adc_dp/selected_data
add wave -noupdate -label fifo_push_n1 -radix binary /cmam_tb/cmam_m/nif/nmc1/adc_dp/fifo_push
add wave -noupdate -label fifo_dout_n1 -radix hexadecimal /cmam_tb/cmam_m/nif/nmc1/adc_dp/fifo_dout
add wave -noupdate -label fifo_pop_n1 -radix binary /cmam_tb/cmam_m/nif/nmc1/adc_dp/fifo_pop
add wave -noupdate -label word_cnt -radix unsigned /cmam_tb/cmam_m/nif/nmc0/adc_dp/word_cnt
add wave -noupdate -label wc_preset -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/wc_preset
add wave -noupdate -label wc_dec -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/wc_dec
add wave -noupdate -label selected_data -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_dp/selected_data
add wave -noupdate -label fifo_full -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/fifo_full
add wave -noupdate -label buf1_out -radix binary /cmam_tb/cmam_m/nif/nmc0/adc_dp/buf1_out
add wave -noupdate -label buf2_out -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/adc_dp/buf2_out
add wave -noupdate -label current_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/adc_dp/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/adc_dp/next_state
add wave -noupdate -divider nmic_tx
add wave -noupdate -label clk -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/rstb
add wave -noupdate -label start -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/start
add wave -noupdate -label start_reg -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/start_reg
add wave -noupdate -label tx_bit_valid -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/tx_bit_valid
add wave -noupdate -label tx_busy -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/tx_busy
add wave -noupdate -label data_stb -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/data_stb
add wave -noupdate -label data -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/ntx/data
add wave -noupdate -label data_rb -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/ntx/data_rb
add wave -noupdate -label cmd_mode -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ntx/cmd_mode
add wave -noupdate -label tx_bit -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/tx_bit
add wave -noupdate -label count -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ntx/count
add wave -noupdate -label crc -radix hexadecimal /cmam_tb/cmam_m/nif/nmc0/ntx/crc
add wave -noupdate -label done -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/done
add wave -noupdate -label length -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ntx/length
add wave -noupdate -label dbit -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/dbit
add wave -noupdate -label cnt_en -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/cnt_en
add wave -noupdate -label cnt_rst -radix binary /cmam_tb/cmam_m/nif/nmc0/ntx/cnt_rst
add wave -noupdate -label current_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ntx/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/cmam_m/nif/nmc0/ntx/next_state
add wave -noupdate -divider AM
add wave -noupdate -label clk_am -radix binary /cmam_tb/cmam_m/am_if/clk_am
add wave -noupdate -label n2a_data -radix binary /cmam_tb/cmam_m/am_if/n2a_data
add wave -noupdate -label a2c_data -radix binary /cmam_tb/cmam_m/am_if/a2c_data
add wave -noupdate -label c2a_valid -radix binary /cmam_tb/cmam_m/am_if/c2a_valid
add wave -noupdate -label c2a_valid_reg -radix binary /cmam_tb/cmam_m/am_if/c2a_valid_reg
add wave -noupdate -label c2a_data -radix binary /cmam_tb/cmam_m/am_if/c2a_data
add wave -noupdate -label c2a_data_reg -radix binary /cmam_tb/cmam_m/am_if/c2a_data_reg
add wave -noupdate -label a2n_valid -radix binary /cmam_tb/cmam_m/am_if/a2n_valid
add wave -noupdate -label a2n_data -radix binary /cmam_tb/cmam_m/am_if/a2n_data
add wave -noupdate -label nm_switch -radix binary /cmam_tb/cmam_m/am_if/nm_switch
add wave -noupdate -label am_cntr -radix unsigned /cmam_tb/cmam_m/am_if/am_cntr
add wave -noupdate -label isReset -radix binary /cmam_tb/cmam_m/am_if/isReset
add wave -noupdate -label nm_isReset -radix binary /cmam_tb/cmam_m/am_if/nm_isReset
add wave -noupdate -label nm_isPSwitch -radix binary /cmam_tb/cmam_m/am_if/nm_isPSwitch
add wave -noupdate -label nm_rst_flag -radix binary /cmam_tb/cmam_m/am_if/nm_rst_flag
add wave -noupdate -label nm_onoff -radix binary /cmam_tb/cmam_m/am_if/nm_onoff
add wave -noupdate -label c2a_valid_frame -radix binary /cmam_tb/cmam_m/am_if/c2a_valid_frame
add wave -noupdate -label training_cntr -radix unsigned /cmam_tb/cmam_m/am_if/training_cntr
add wave -noupdate -label reset -radix binary /cmam_tb/cmam_m/am_if/reset
add wave -noupdate -divider CM_DEMUX
add wave -noupdate -label clk -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/rstb
add wave -noupdate -label c2a_valid -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/c2a_valid
add wave -noupdate -label c2a_data -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/c2a_data
add wave -noupdate -label tx_data -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/tx_data
add wave -noupdate -label tx_valid -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/tx_valid
add wave -noupdate -label tx_data_stb -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/tx_data_stb
add wave -noupdate -label a2c_data -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/a2c_data
add wave -noupdate -label rx_frame -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/rx_frame
add wave -noupdate -label rx_data -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/rx_data
add wave -noupdate -label state -radix unsigned /cmam_tb/cmam_m/nif/cm_demux_0/state
add wave -noupdate -divider reset
add wave -noupdate -label link_rst -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/link_rst
add wave -noupdate -label link_rst_type -radix unsigned /cmam_tb/cmam_m/nif/cm_demux_0/link_rst_type
add wave -noupdate -label rst_start -radix binary /cmam_tb/cmam_m/nif/rst_start
add wave -noupdate -label rst_busy -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/rst_busy
add wave -noupdate -label cm_tx_ctr -radix unsigned /cmam_tb/cmam_m/nif/cm_demux_0/cm_tx_ctr
add wave -noupdate -label link_rst_latch -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/link_rst_latch
add wave -noupdate -label rst_valid -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/rst_valid
add wave -noupdate -label rst_data -radix binary /cmam_tb/cmam_m/nif/cm_demux_0/rst_data
add wave -noupdate -label current_state -radix unsigned /cmam_tb/acc_sim_m/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/acc_sim_m/next_state
add wave -noupdate -divider PDMA_SIM
add wave -noupdate -label clk -radix binary /cmam_tb/pdma_sim_m/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/pdma_sim_m/rstb
add wave -noupdate -label pdma_rdy -radix binary /cmam_tb/pdma_sim_m/pdma_rdy
add wave -noupdate -label pdma_fifo_empty -radix binary /cmam_tb/pdma_sim_m/pdma_fifo_empty
add wave -noupdate -label rden -radix binary /cmam_tb/pdma_sim_m/rden
add wave -noupdate -label addr -radix hexadecimal /cmam_tb/pdma_sim_m/addr
add wave -noupdate -label acc_data -radix hexadecimal /cmam_tb/acc_data
add wave -noupdate -label pdma_data -radix hexadecimal /cmam_tb/cmam_m/nif/pdma/pdma_data
add wave -noupdate -label current_state -radix unsigned /cmam_tb/pdma_sim_m/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/pdma_sim_m/next_state
add wave -noupdate -divider PDMA_IF
add wave -noupdate -label clk -radix binary /cmam_tb/cmam_m/nif/pdma/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/cmam_m/nif/pdma/rstb
add wave -noupdate -label adc_fifo_dout_n0 -radix hexadecimal /cmam_tb/cmam_m/nif/pdma/adc_fifo_dout_n0
add wave -noupdate -label adc_data_rdy_n0 -radix binary /cmam_tb/cmam_m/nif/pdma/adc_data_rdy_n0
add wave -noupdate -label adc_fifo_empty_n0 -radix binary /cmam_tb/cmam_m/nif/pdma/adc_fifo_empty_n0
add wave -noupdate -label adc_fifo_pop_n0 -radix binary /cmam_tb/cmam_m/nif/pdma/adc_fifo_pop_n0
add wave -noupdate -label adc_fifo_dout_n1 -radix hexadecimal /cmam_tb/cmam_m/nif/pdma/adc_fifo_dout_n1
add wave -noupdate -label adc_data_rdy_n1 -radix binary /cmam_tb/cmam_m/nif/pdma/adc_data_rdy_n1
add wave -noupdate -label adc_fifo_empty_n1 -radix binary /cmam_tb/cmam_m/nif/pdma/adc_fifo_empty_n1
add wave -noupdate -label adc_fifo_pop_n1 -radix binary /cmam_tb/cmam_m/nif/pdma/adc_fifo_pop_n1
add wave -noupdate -label acc_data -radix hexadecimal /cmam_tb/cmam_m/nif/pdma/acc_data
add wave -noupdate -label pdma_data -radix hexadecimal /cmam_tb/cmam_m/nif/pdma/pdma_data
add wave -noupdate -label pdma_rdy -radix binary /cmam_tb/cmam_m/nif/pdma/pdma_rdy
add wave -noupdate -label pdma_ena -radix binary /cmam_tb/cmam_m/nif/pdma/pdma_en
add wave -noupdate -label pdma_fifo_push -radix binary /cmam_tb/cmam_m/nif/pdma/pdma_fifo_push
add wave -noupdate -label pdma_fifo_pop -radix binary /cmam_tb/cmam_m/nif/pdma/pdma_fifo_pop
add wave -noupdate -label pdma_fifo_clr -radix binary /cmam_tb/cmam_m/nif/pdma/pdma_fifo_clr
add wave -noupdate -label pdma_fifo_full -radix binary /cmam_tb/cmam_m/nif/pdma/pdma_fifo_full
add wave -noupdate -label pdma_fifo_din -radix hexadecimal /cmam_tb/cmam_m/nif/pdma/pdma_fifo_din
add wave -noupdate -label data_rdy_n0 -radix binary /cmam_tb/cmam_m/nif/pdma/data_rdy_n0
add wave -noupdate -label data_rdy_n1 -radix binary /cmam_tb/cmam_m/nif/pdma/data_rdy_n1
add wave -noupdate -label latch_clr -radix binary /cmam_tb/cmam_m/nif/pdma/latch_clr
add wave -noupdate -label mux_sel -radix unsigned /cmam_tb/cmam_m/nif/pdma/mux_sel
add wave -noupdate -label current_state -radix unsigned /cmam_tb/cmam_m/nif/pdma/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/cmam_m/nif/pdma/next_state
add wave -noupdate -divider ACC_SIM
add wave -noupdate -label clk -radix binary /cmam_tb/acc_sim_m/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/acc_sim_m/rstb
add wave -noupdate -label scl -radix binary /cmam_tb/acc_sim_m/scl
add wave -noupdate -label sda_o -radix binary /cmam_tb/acc_sim_m/sda_o
add wave -noupdate -label sda_i -radix binary /cmam_tb/acc_sim_m/sda_i
add wave -noupdate -label sda_dir -radix binary /cmam_tb/acc_if_m/sda_dir
add wave -noupdate -label bc_en -radix binary /cmam_tb/acc_sim_m/bc_en
add wave -noupdate -label bc_rst -radix binary /cmam_tb/acc_sim_m/bc_rst
add wave -noupdate -label bc_cnt -radix unsigned /cmam_tb/acc_sim_m/bc_cnt
add wave -noupdate -label reg_en -radix binary /cmam_tb/acc_sim_m/reg_en
add wave -noupdate -label reg_ld_hdr -radix binary /cmam_tb/acc_sim_m/reg_ld_hdr
add wave -noupdate -label reg_ld_data -radix binary /cmam_tb/acc_sim_m/reg_ld_data
add wave -noupdate -label sda_reg -radix binary /cmam_tb/acc_sim_m/sda_reg
add wave -noupdate -label current_state -radix unsigned /cmam_tb/acc_sim_m/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/acc_sim_m/next_state
add wave -noupdate -divider ACC_IF
add wave -noupdate -label clk -radix binary /cmam_tb/acc_if_m/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/acc_if_m/rstb
add wave -noupdate -label addr -radix hexadecimal /cmam_tb/acc_if_m/addr
add wave -noupdate -label data_wr -radix hexadecimal /cmam_tb/acc_if_m/data_wr
add wave -noupdate -label wren -radix binary /cmam_tb/acc_if_m/wren
add wave -noupdate -label data_rd -radix binary /cmam_tb/acc_if_m/data_rd
add wave -noupdate -label rden -radix binary /cmam_tb/acc_if_m/rden
add wave -noupdate -label acc_irq -radix binary /cmam_tb/acc_if_m/acc_irq
add wave -noupdate -label scl -radix binary /cmam_tb/acc_if_m/scl
add wave -noupdate -label sda_o -radix binary /cmam_tb/acc_if_m/sda_o
add wave -noupdate -label sda_dir -radix binary /cmam_tb/acc_if_m/sda_dir
add wave -noupdate -label sda_i -radix binary /cmam_tb/acc_if_m/sda_i
add wave -noupdate -label acc_data -radix hexadecimal /cmam_tb/acc_if_m/acc_data
add wave -noupdate -label apb_scl -radix binary /cmam_tb/acc_if_m/apb_scl
add wave -noupdate -label apb_sda_o -radix binary /cmam_tb/acc_if_m/apb_sda_o
add wave -noupdate -label apb_sda_dir -radix binary /cmam_tb/acc_if_m/apb_sda_dir
add wave -noupdate -label apb_sda_i -radix binary /cmam_tb/acc_if_m/apb_sda_i
add wave -noupdate -label irq_scl -radix binary /cmam_tb/acc_if_m/irq_scl
add wave -noupdate -label irq_sda_o -radix binary /cmam_tb/acc_if_m/irq_sda_o
add wave -noupdate -label irq_sda_dir -radix binary /cmam_tb/acc_if_m/irq_sda_dir
add wave -noupdate -label irq_sda_i -radix binary /cmam_tb/acc_if_m/irq_sda_i
add wave -noupdate -label mux_sel -radix unsigned /cmam_tb/acc_if_m/mux_sel
add wave -noupdate -label rd_ok -radix binary /cmam_tb/acc_if_m/reg_rd_ok
add wave -noupdate -label wr_ok -radix binary /cmam_tb/acc_if_m/reg_wr_ok
add wave -noupdate -label rd_pending -radix binary /cmam_tb/acc_if_m/reg_rd_pending
add wave -noupdate -label irq_go -radix binary /cmam_tb/acc_if_m/irq_go
add wave -noupdate -label irq_ok -radix binary /cmam_tb/acc_if_m/irq_ok
add wave -noupdate -divider acc_apb
add wave -noupdate -label clk -radix binary /cmam_tb/acc_if_m/acc_apb_p/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/acc_if_m/acc_apb_p/rstb
add wave -noupdate -label addr -radix binary /cmam_tb/acc_if_m/acc_apb_p/addr
add wave -noupdate -label data_wr -radix hexadecimal /cmam_tb/acc_if_m/acc_apb_p/data_wr
add wave -noupdate -label wren -radix binary /cmam_tb/acc_if_m/acc_apb_p/wren
add wave -noupdate -label data_rd -radix binary /cmam_tb/acc_if_m/acc_apb_p/data_rd
add wave -noupdate -label rden -radix binary /cmam_tb/acc_if_m/acc_apb_p/rden
add wave -noupdate -label apb_scl -radix binary /cmam_tb/acc_if_m/acc_apb_p/scl
add wave -noupdate -label apb_sda_o -radix binary /cmam_tb/acc_if_m/acc_apb_p/sda_o
add wave -noupdate -label apb_sda_dir -radix binary /cmam_tb/acc_if_m/acc_apb_p/sda_dir
add wave -noupdate -label apb_sda_i -radix binary /cmam_tb/acc_if_m/acc_apb_p/sda_i
add wave -noupdate -label scl_reg -radix binary /cmam_tb/acc_if_m/acc_apb_p/scl_reg
add wave -noupdate -label sda_o_reg -radix binary /cmam_tb/acc_if_m/acc_apb_p/sda_o_reg
add wave -noupdate -label sda_dir_reg -radix binary /cmam_tb/acc_if_m/acc_apb_p/sda_dir_reg
add wave -noupdate -label sda_i_reg -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_i_reg
add wave -noupdate -label mux_sel -radix unsigned /cmam_tb/acc_if_m/acc_apb_p/mux_sel
add wave -noupdate -label rd_ok -radix binary /cmam_tb/acc_if_m/acc_apb_p/rd_ok
add wave -noupdate -label wr_ok -radix binary /cmam_tb/acc_if_m/acc_apb_p/wr_ok
add wave -noupdate -label rd_pending -radix binary /cmam_tb/acc_if_m/acc_apb_p/rd_pending
add wave -noupdate -label reg_en -radix binary /cmam_tb/acc_if_m/acc_apb_p/reg_en
add wave -noupdate -label bc_en -radix binary /cmam_tb/acc_if_m/acc_apb_p/bc_en
add wave -noupdate -label reg_ld_rd -radix binary /cmam_tb/acc_if_m/acc_apb_p/reg_ld_rd
add wave -noupdate -label reg_ld_wr -radix binary /cmam_tb/acc_if_m/acc_apb_p/reg_ld_wr
add wave -noupdate -label rd_active -radix binary /cmam_tb/acc_if_m/acc_apb_p/rd_active
add wave -noupdate -label wr_active -radix binary /cmam_tb/acc_if_m/acc_apb_p/wr_active
add wave -noupdate -label ack_reg -radix binary /cmam_tb/acc_if_m/acc_apb_p/ack_reg
add wave -noupdate -label result_ld -radix binary /cmam_tb/acc_if_m/acc_apb_p/result_ld
add wave -noupdate -label result_reg -radix binary /cmam_tb/acc_if_m/acc_apb_p/result_reg
add wave -noupdate -label bc_rst -radix binary /cmam_tb/acc_if_m/acc_apb_p/bc_rst
add wave -noupdate -label bc_cnt -radix unsigned /cmam_tb/acc_if_m/acc_apb_p/bc_cnt
add wave -noupdate -label current_state -radix unsigned /cmam_tb/acc_if_m/acc_apb_p/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/acc_if_m/acc_apb_p/next_state
add wave -noupdate -divider acc_irq
add wave -noupdate -label clk -radix binary /cmam_tb/acc_if_m/acc_irq_p/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/acc_if_m/acc_irq_p/rstb
add wave -noupdate -label acc_irq -radix binary /cmam_tb/acc_if_m/acc_irq_p/acc_irq
add wave -noupdate -label scl -radix binary /cmam_tb/acc_if_m/acc_irq_p/scl
add wave -noupdate -label sda_o -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_o
add wave -noupdate -label sda_dir -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_dir
add wave -noupdate -label sda_i -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_i
add wave -noupdate -label scl_reg -radix binary /cmam_tb/acc_if_m/acc_irq_p/scl_reg
add wave -noupdate -label sda_o_reg -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_o_reg
add wave -noupdate -label sda_dir_reg -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_dir_reg
add wave -noupdate -label sda_i_reg -radix binary /cmam_tb/acc_if_m/acc_irq_p/sda_i_reg
add wave -noupdate -label acc_data -radix binary /cmam_tb/acc_if_m/acc_irq_p/acc_data
add wave -noupdate -label go -radix binary /cmam_tb/acc_if_m/acc_irq_p/go
add wave -noupdate -label irq_ok -radix binary /cmam_tb/acc_if_m/acc_irq_p/irq_ok
add wave -noupdate -label reg_en -radix binary /cmam_tb/acc_if_m/acc_irq_p/reg_en
add wave -noupdate -label reg_ld -radix binary /cmam_tb/acc_if_m/acc_irq_p/reg_ld
add wave -noupdate -label acc_ld -radix binary /cmam_tb/acc_if_m/acc_irq_p/acc_ld
add wave -noupdate -label ack_reg -radix binary /cmam_tb/acc_if_m/acc_irq_p/ack_reg
add wave -noupdate -label bc_en -radix binary /cmam_tb/acc_if_m/acc_irq_p/bc_en
add wave -noupdate -label bc_rst -radix binary /cmam_tb/acc_if_m/acc_irq_p/bc_rst
add wave -noupdate -label bc_cnt -radix unsigned /cmam_tb/acc_if_m/acc_irq_p/bc_cnt
add wave -noupdate -label current_state -radix unsigned /cmam_tb/acc_if_m/acc_irq_p/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/acc_if_m/acc_irq_p/next_state
add wave -noupdate -divider NM_SIM_0
add wave -noupdate -label clk -radix binary /cmam_tb/nm0_sim_m/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/nm0_sim_m/rstb
add wave -noupdate -label start -radix binary /cmam_tb/nm0_sim_m/start
add wave -noupdate -label clk_div -radix unsigned /cmam_tb/nm0_sim_m/clk_div
add wave -noupdate -label twoMHz_clk -radix binary /cmam_tb/nm0_sim_m/twoMHz_clk
add wave -noupdate -label a2n_valid -radix binary /cmam_tb/nm0_sim_m/a2n_valid
add wave -noupdate -label a2n_data -radix binary /cmam_tb/nm0_sim_m/a2n_data
add wave -noupdate -label n2a_data -radix binary /cmam_tb/nm0_sim_m/n2a_data
add wave -noupdate -divider adc_nm0
add wave -noupdate -label rstb -radix binary /cmam_tb/nm0_sim_m/nm_adc/rstb
add wave -noupdate -label clk -radix binary /cmam_tb/nm0_sim_m/nm_adc/clk
add wave -noupdate -label twoMHz_clk -radix binary /cmam_tb/nm0_sim_m/nm_adc/twoMHz_clk
add wave -noupdate -label tx_wait -radix binary /cmam_tb/nm0_sim_m/nm_adc/tx_wait
add wave -noupdate -label tx_idle -radix binary /cmam_tb/nm0_sim_m/nm_adc/tx_idle
add wave -noupdate -label dout -radix binary /cmam_tb/nm0_sim_m/nm_adc/dout
add wave -noupdate -label bit_count -radix unsigned /cmam_tb/nm0_sim_m/nm_adc/bit_count
add wave -noupdate -label next_word -radix binary /cmam_tb/nm0_sim_m/nm_adc/next_word
add wave -noupdate -label wc_rst -radix binary /cmam_tb/nm0_sim_m/nm_adc/wc_rst
add wave -noupdate -label wc_inc -radix binary /cmam_tb/nm0_sim_m/nm_adc/wc_inc
add wave -noupdate -label word_count -radix unsigned /cmam_tb/nm0_sim_m/nm_adc/word_count
add wave -noupdate -label end_of_packet -radix binary /cmam_tb/nm0_sim_m/nm_adc/end_of_packet
add wave -noupdate -label next_packet -radix binary /cmam_tb/nm0_sim_m/nm_adc/next_packet
add wave -noupdate -label sr_input -radix binary /cmam_tb/nm0_sim_m/nm_adc/sr_input
add wave -noupdate -label sr_load -radix binary /cmam_tb/nm0_sim_m/nm_adc/sr_load
add wave -noupdate -label shift_reg -radix hexadecimal /cmam_tb/nm0_sim_m/nm_adc/shift_reg
add wave -noupdate -label crc_init -radix binary /cmam_tb/nm0_sim_m/nm_adc/crc_init
add wave -noupdate -label crc_compute -radix binary /cmam_tb/nm0_sim_m/nm_adc/crc_compute
add wave -noupdate -label crc -radix binary /cmam_tb/nm0_sim_m/nm_adc/crc
add wave -noupdate -label current_state -radix unsigned /cmam_tb/nm0_sim_m/nm_adc/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/nm0_sim_m/nm_adc/next_state
add wave -noupdate -divider cnr_nm0
add wave -noupdate -label rstb -radix binary /cmam_tb/nm0_sim_m/nm_cnr/rstb
add wave -noupdate -label clk -radix binary /cmam_tb/nm0_sim_m/nm_cnr/clk
add wave -noupdate -label twoMHz_clk -radix binary /cmam_tb/nm0_sim_m/nm_cnr/twoMHz_clk
add wave -noupdate -label rx_valid -radix binary /cmam_tb/nm0_sim_m/nm_cnr/rx_valid
add wave -noupdate -label rx_bit -radix binary /cmam_tb/nm0_sim_m/nm_cnr/rx_bit
add wave -noupdate -label tx_rdy -radix binary /cmam_tb/nm0_sim_m/nm_cnr/tx_rdy
add wave -noupdate -label tx_ok -radix binary /cmam_tb/nm0_sim_m/nm_cnr/tx_ok
add wave -noupdate -label dout -radix binary /cmam_tb/nm0_sim_m/nm_cnr/dout
add wave -noupdate -label is_rst -radix binary /cmam_tb/nm0_sim_m/nm_cnr/is_rst
add wave -noupdate -label bc_rst -radix binary /cmam_tb/nm0_sim_m/nm_cnr/bc_rst
add wave -noupdate -label bit_count -radix unsigned /cmam_tb/nm0_sim_m/nm_cnr/bit_count
add wave -noupdate -label end_of_packet -radix binary /cmam_tb/nm0_sim_m/nm_cnr/end_of_packet
add wave -noupdate -label sr_load -radix binary /cmam_tb/nm0_sim_m/nm_cnr/sr_load
add wave -noupdate -label shift_reg -radix hexadecimal /cmam_tb/nm0_sim_m/nm_cnr/shift_reg
add wave -noupdate -label tx_req -radix binary /cmam_tb/nm0_sim_m/nm_cnr/tx_req
add wave -noupdate -label tx_idle -radix binary /cmam_tb/nm0_sim_m/nm_cnr/tx_idle
add wave -noupdate -label current_state -radix unsigned /cmam_tb/nm0_sim_m/nm_cnr/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/nm0_sim_m/nm_cnr/next_state
add wave -noupdate -divider NM_SIM_1
add wave -noupdate -label clk -radix binary /cmam_tb/nm1_sim_m/clk
add wave -noupdate -label rstb -radix binary /cmam_tb/nm1_sim_m/rstb
add wave -noupdate -label start -radix binary /cmam_tb/nm1_sim_m/start
add wave -noupdate -label clk_div -radix unsigned /cmam_tb/nm1_sim_m/clk_div
add wave -noupdate -label twoMHz_clk -radix binary /cmam_tb/nm1_sim_m/twoMHz_clk
add wave -noupdate -label a2n_valid -radix binary /cmam_tb/nm1_sim_m/a2n_valid
add wave -noupdate -label a2n_data -radix binary /cmam_tb/nm1_sim_m/a2n_data
add wave -noupdate -label n2a_data -radix binary /cmam_tb/nm1_sim_m/n2a_data
add wave -noupdate -divider adc_nm1
add wave -noupdate -label rstb -radix binary /cmam_tb/nm1_sim_m/nm_adc/rstb
add wave -noupdate -label clk -radix binary /cmam_tb/nm1_sim_m/nm_adc/clk
add wave -noupdate -label twoMHz_clk -radix binary /cmam_tb/nm1_sim_m/nm_adc/twoMHz_clk
add wave -noupdate -label tx_wait -radix binary /cmam_tb/nm1_sim_m/nm_adc/tx_wait
add wave -noupdate -label tx_idle -radix binary /cmam_tb/nm1_sim_m/nm_adc/tx_idle
add wave -noupdate -label dout -radix binary /cmam_tb/nm1_sim_m/nm_adc/dout
add wave -noupdate -label bit_count -radix unsigned /cmam_tb/nm1_sim_m/nm_adc/bit_count
add wave -noupdate -label next_word -radix binary /cmam_tb/nm1_sim_m/nm_adc/next_word
add wave -noupdate -label wc_rst -radix binary /cmam_tb/nm1_sim_m/nm_adc/wc_rst
add wave -noupdate -label wc_inc -radix binary /cmam_tb/nm1_sim_m/nm_adc/wc_inc
add wave -noupdate -label word_count -radix unsigned /cmam_tb/nm1_sim_m/nm_adc/word_count
add wave -noupdate -label end_of_packet -radix binary /cmam_tb/nm1_sim_m/nm_adc/end_of_packet
add wave -noupdate -label next_packet -radix binary /cmam_tb/nm1_sim_m/nm_adc/next_packet
add wave -noupdate -label sr_input -radix binary /cmam_tb/nm1_sim_m/nm_adc/sr_input
add wave -noupdate -label sr_load -radix binary /cmam_tb/nm1_sim_m/nm_adc/sr_load
add wave -noupdate -label shift_reg -radix hexadecimal /cmam_tb/nm1_sim_m/nm_adc/shift_reg
add wave -noupdate -label crc_init -radix binary /cmam_tb/nm1_sim_m/nm_adc/crc_init
add wave -noupdate -label crc_compute -radix binary /cmam_tb/nm1_sim_m/nm_adc/crc_compute
add wave -noupdate -label crc -radix binary /cmam_tb/nm1_sim_m/nm_adc/crc
add wave -noupdate -label current_state -radix unsigned /cmam_tb/nm1_sim_m/nm_adc/current_state
add wave -noupdate -label next_state -radix unsigned /cmam_tb/nm1_sim_m/nm_adc/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {1024300000000 fs} 1} {{Cursor 6} {1016300000000 fs} 1} {{Cursor 7} {1032300000000 fs} 1} {{Cursor 8} {1008300000000 fs} 1} {{Cursor 9} {1040300000000 fs} 1} {{Cursor 10} {1048300000000 fs} 1} {init_dut {1003508011861 fs} 1} {init_vectors {1028605017 fs} 1} {reset_AM {2057210033 fs} 1} {reset_NM0 {350384854957 fs} 1} {power_cycle_NM0 {351413459973 fs} 1} {nm_command {359884854957 fs} 1} {nm_register_write {382884854957 fs} 1} {read_ADC_FIFO {1607384854957 fs} 1}
quietly wave cursor active 4
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
WaveRestoreZoom {1001181031851 fs} {1059249313131 fs}
