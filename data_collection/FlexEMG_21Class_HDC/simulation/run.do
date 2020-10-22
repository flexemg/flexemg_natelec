quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECT_DIR "C:/Users/flb/Desktop/mario_laptop_sf2_newarch/Mario_SF2_devbrd"
source "${PROJECT_DIR}/simulation/CM3_compile_bfm.tcl";source "${PROJECT_DIR}/simulation/bfmtovec_compile.tcl";

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

vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/cmam.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nmic_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/am.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/cm_demux.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_channel.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nmic_rx.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nmic_tx.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/ack_datapath.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/adc_datapath.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/ack_deserializer.v"
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
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_irq_proc.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/acc_apb_proc.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/cmam_if_wrap.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/pdma_if.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/PDMAFIFO_PDMAFIFO_0_USRAM_top.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/PDMAFIFO_PDMAFIFO_0_ram_wrapper.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/COREFIFO.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_async.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_doubleSync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_fwft.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_grayToBinConv.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_sync.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/PDMAFIFO/PDMAFIFO_0/rtl/vlog/core/corefifo_sync_scntr.v"
vlog -vlog01compat -work COREAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAPB3/4.1.100/rtl/vlog/core_obfuscated/coreapb3.v"
vlog -vlog01compat -work COREAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAPB3/4.1.100/rtl/vlog/core_obfuscated/coreapb3_iaddr_reg.v"
vlog -vlog01compat -work COREAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAPB3/4.1.100/rtl/vlog/core_obfuscated/coreapb3_muxptob3.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreInterrupt/1.1.101/rtl/verilog/o/CoreInterrupt.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/Actel/SgCore/OSC/2.0.101/osc_comps.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/Actel/SgCore/OSC/2.0.101/osc_comps_pre.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/Mario_Libero/FCCC_0/Mario_Libero_FCCC_0_FCCC.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/Mario_Libero/Mario_Libero.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/Mario_Libero/OSC_0/Mario_Libero_OSC_0_OSC.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/Mario_Libero_MSS/Mario_Libero_MSS.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/Mario_Libero_MSS/Mario_Libero_MSS_pre.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/component/work/Mario_Libero_MSS/Mario_Libero_MSS_syn.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_sim.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_sim_adc_gen.v"
vlog -vlog01compat -work presynth "${PROJECT_DIR}/hdl/nm_sim_cmd_and_reg.v"
vlog "+incdir+${PROJECT_DIR}/stimulus" -vlog01compat -work presynth "${PROJECT_DIR}/stimulus/toplevel_tb.v"

vsim -L SmartFusion2 -L presynth -L COREAPB3_LIB -L CORESPI_LIB  -t 1fs presynth.toplevel_tb
add wave /toplevel_tb/*
run 1000ns
