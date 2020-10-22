open_project -project {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero_fp\Mario_Libero.pro}\
         -connect_programmers {FALSE}
if { [catch {load_programming_data \
    -name {M2S060T} \
    -fpga {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero.map} \
    -header {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero.hdr} \
    -envm {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero.efc}  \
    -spm {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero.spm} \
    -dca {C:\Users\bwrc\Desktop\HyperFlexEMG_190405_21Class\designer\Mario_Libero\Mario_Libero.dca} } return_val] } {
save_project
close_project
exit }
set_programming_file -name {M2S060T} -no_file
save_project
close_project
