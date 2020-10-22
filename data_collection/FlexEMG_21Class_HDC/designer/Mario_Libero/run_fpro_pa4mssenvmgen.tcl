set_device \
    -fam SmartFusion2 \
    -die PA4M6000 \
    -pkg fcs325
set_input_cfg \
	-path {C:/Users/bwrc/Desktop/HyperFlexEMG_190405_21Class/component/work/Mario_Libero_MSS/ENVM.cfg}
set_output_efc \
    -path {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero.efc}
set_proj_dir \
    -path {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class}
gen_prg -use_init false
