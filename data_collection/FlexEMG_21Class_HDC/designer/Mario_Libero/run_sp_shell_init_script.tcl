set_device \
    -family  SmartFusion2 \
    -die     PA4M6000 \
    -package fcs325 \
    -speed   STD \
    -tempr   {COM} \
    -voltr   {COM}
set_def {VOLTAGE} {1.2}
set_def {VCCI_1.2_VOLTR} {COM}
set_def {VCCI_1.5_VOLTR} {COM}
set_def {VCCI_1.8_VOLTR} {COM}
set_def {VCCI_2.5_VOLTR} {COM}
set_def {VCCI_3.3_VOLTR} {COM}
set_def {PLL_SUPPLY} {PLL_SUPPLY_25}
set_def {VPP_SUPPLY_25_33} {VPP_SUPPLY_25}
set_def {PA4_URAM_FF_CONFIG} {SUSPEND}
set_def {PA4_SRAM_FF_CONFIG} {SUSPEND}
set_def {PA4_MSS_FF_CLOCK} {RCOSC_1MHZ}
set_netlist -afl {C:\Users\bwrc\Desktop\HyperFlexEG\designer\Mario_Libero\Mario_Libero.afl} -adl {C:\Users\bwrc\Desktop\HyperFlexEG\designer\Mario_Libero\Mario_Libero.adl}
set_placement   {C:\Users\bwrc\Desktop\HyperFlexEG\designer\Mario_Libero\Mario_Libero.loc}
set_routing     {C:\Users\bwrc\Desktop\HyperFlexEG\designer\Mario_Libero\Mario_Libero.seg}
