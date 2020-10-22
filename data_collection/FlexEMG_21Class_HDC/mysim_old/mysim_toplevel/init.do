quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECT_DIR "C:/Users/flb.EECS/Desktop/mario_laptop_sf2_newarch/Mario_SF2_devbrd"
quietly set ACTEL_SW_DIR "C:/Users/flb.EECS/Desktop/mario_laptop_sf2_newarch/Mario_SF2_devbrd\simulation"
source "${PROJECT_DIR}/simulation/bfmtovec_compile.tcl";source "${PROJECT_DIR}/simulation/CM3_compile_bfm.tcl";

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap SmartFusion2 "C:/Microsemi/Libero_SoC_v11.7///Designer//lib//modelsim//precompiled/vlog/SmartFusion2"
if {[file exists COREAPB3_LIB/_info]} {
   echo "INFO: Simulation library COREAPB3_LIB already exists"
} else {
   file delete -force COREAPB3_LIB 
   vlib COREAPB3_LIB
}
vmap COREAPB3_LIB "COREAPB3_LIB"
if {[file exists CORESPI_LIB/_info]} {
   echo "INFO: Simulation library CORESPI_LIB already exists"
} else {
   file delete -force CORESPI_LIB 
   vlib CORESPI_LIB
}
vmap CORESPI_LIB "CORESPI_LIB"

vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_datapath/adc_datapath.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_fft_if/adc_fft_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/cm_if/cm_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/cmam_if/cmam_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/debug_bus/debug_bus.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/nm_channel/nm_channel.v"

vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_apb_proc.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_irq_proc.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/ack_datapath.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/ack_deserializer.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/adc_artifact_cancel.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/adc_debug.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/adc_fft_cntl.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/adc_frame_buffer.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/adc_vector_compressor.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/ADCMEM_SP.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/am_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/cm_demux.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/cm_if_apb.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/cmam_if_apb.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/debug_mux.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nmic_rx.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nmic_tx.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/pdma_if.v"

vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_sim.v"
vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_sim.v"
vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_sim_adc_gen.v"
vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_sim_cmd_and_reg.v"
vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/hdl/pdma_sim.v"

vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/corefifo_doubleSync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/corefifo_grayToBinConv.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/corefifo_async.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/corefifo_fwft.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/corefifo_sync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/corefifo_sync_scntr.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/ADCFIFO_ADCFIFO_0_LSRAM_top.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/ADCFIFO_ADCFIFO_0_ram_wrapper.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ADCFIFO/ADCFIFO_0/rtl/vlog/core/COREFIFO.v"

vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/corefifo_doubleSync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/corefifo_grayToBinConv.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/corefifo_async.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/corefifo_fwft.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/corefifo_sync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/corefifo_sync_scntr.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/ACKFIFO_ACKFIFO_0_USRAM_top.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/ACKFIFO_ACKFIFO_0_ram_wrapper.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/ACKFIFO/ACKFIFO_0/rtl/vlog/core/COREFIFO.v"

vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_doubleSync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_grayToBinConv.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_async.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_fwft.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_sync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_sync_scntr.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/PDMAFIFO_PDMAFIFO_0_USRAM_top.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/PDMAFIFO_PDMAFIFO_0_ram_wrapper.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/COREFIFO.v"

vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_fft_if/COREFFT_0/twiddle32.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_fft_if/COREFFT_0/rtl/in_place/vlog/core/COREFFT_TOP.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_fft_if/COREFFT_0/rtl/in_place/vlog/core/COREFFT.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_fft_if/COREFFT_0/rtl/in_place/vlog/core/fftDp.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/adc_fft_if/COREFFT_0/rtl/in_place/vlog/core/adc_fft_if_COREFFT_0_uram_smGen.v"

vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/stimulus/cmam_tb.v"

vsim -L SmartFusion2 -L presynth -L COREAPB3_LIB -L CORESPI_LIB  -t 1fs presynth.toplevel_tb
do wave.do
run 2.5ms