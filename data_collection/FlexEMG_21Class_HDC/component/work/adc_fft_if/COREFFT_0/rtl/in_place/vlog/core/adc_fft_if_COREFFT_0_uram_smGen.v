`timescale 1 ns/100 ps
// Version: v11.7 SP3 11.7.3.7


module adc_fft_if_COREFFT_0_uram_smGen(
       rD,
       B_DOUT,
       wD,
       rAddr,
       B_ADDR,
       wAddr,
       rBlk,
       B_BLK,
       wBlk,
       A_CLK,
       wClk,
       wEn
    );
output [31:0] rD;
output [31:0] B_DOUT;
input  [31:0] wD;
input  [7:0] rAddr;
input  [7:0] B_ADDR;
input  [7:0] wAddr;
input  rBlk;
input  B_BLK;
input  wBlk;
input  A_CLK;
input  wClk;
input  wEn;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C3 (.A_DOUT({nc0, nc1, 
        nc2, nc3, nc4, nc5, nc6, nc7, nc8, nc9, nc10, nc11, nc12, nc13, 
        rD[15], rD[14], rD[13], rD[12]}), .B_DOUT({nc14, nc15, nc16, 
        nc17, nc18, nc19, nc20, nc21, nc22, nc23, nc24, nc25, nc26, 
        nc27, B_DOUT[15], B_DOUT[14], B_DOUT[13], B_DOUT[12]}), .BUSY()
        , .A_ADDR_CLK(A_CLK), .A_DOUT_CLK(A_CLK), .A_ADDR_SRST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(VCC), .A_DOUT_ARST_N(VCC), 
        .A_ADDR_EN(VCC), .A_DOUT_EN(VCC), .A_BLK({rBlk, VCC}), .A_ADDR({
        rAddr[7], rAddr[6], rAddr[5], rAddr[4], rAddr[3], rAddr[2], 
        rAddr[1], rAddr[0], GND, GND}), .B_ADDR_CLK(VCC), .B_DOUT_CLK(
        VCC), .B_ADDR_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(
        VCC), .B_DOUT_ARST_N(VCC), .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), 
        .B_BLK({B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(wClk), .C_ADDR({wAddr[7], wAddr[6], wAddr[5], 
        wAddr[4], wAddr[3], wAddr[2], wAddr[1], wAddr[0], GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, wD[15], wD[14], wD[13], wD[12]}), .C_WEN(wEn), 
        .C_BLK({wBlk, VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(
        GND), .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C5 (.A_DOUT({nc28, nc29, 
        nc30, nc31, nc32, nc33, nc34, nc35, nc36, nc37, nc38, nc39, 
        nc40, nc41, rD[23], rD[22], rD[21], rD[20]}), .B_DOUT({nc42, 
        nc43, nc44, nc45, nc46, nc47, nc48, nc49, nc50, nc51, nc52, 
        nc53, nc54, nc55, B_DOUT[23], B_DOUT[22], B_DOUT[21], 
        B_DOUT[20]}), .BUSY(), .A_ADDR_CLK(A_CLK), .A_DOUT_CLK(A_CLK), 
        .A_ADDR_SRST_N(VCC), .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(VCC), 
        .A_DOUT_ARST_N(VCC), .A_ADDR_EN(VCC), .A_DOUT_EN(VCC), .A_BLK({
        rBlk, VCC}), .A_ADDR({rAddr[7], rAddr[6], rAddr[5], rAddr[4], 
        rAddr[3], rAddr[2], rAddr[1], rAddr[0], GND, GND}), 
        .B_ADDR_CLK(VCC), .B_DOUT_CLK(VCC), .B_ADDR_SRST_N(VCC), 
        .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(VCC), .B_DOUT_ARST_N(VCC), 
        .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), .B_BLK({B_BLK, VCC}), 
        .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], B_ADDR[4], B_ADDR[3], 
        B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, GND}), .C_CLK(wClk), 
        .C_ADDR({wAddr[7], wAddr[6], wAddr[5], wAddr[4], wAddr[3], 
        wAddr[2], wAddr[1], wAddr[0], GND, GND}), .C_DIN({GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        wD[23], wD[22], wD[21], wD[20]}), .C_WEN(wEn), .C_BLK({wBlk, 
        VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(GND), 
        .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C6 (.A_DOUT({nc56, nc57, 
        nc58, nc59, nc60, nc61, nc62, nc63, nc64, nc65, nc66, nc67, 
        nc68, nc69, rD[27], rD[26], rD[25], rD[24]}), .B_DOUT({nc70, 
        nc71, nc72, nc73, nc74, nc75, nc76, nc77, nc78, nc79, nc80, 
        nc81, nc82, nc83, B_DOUT[27], B_DOUT[26], B_DOUT[25], 
        B_DOUT[24]}), .BUSY(), .A_ADDR_CLK(A_CLK), .A_DOUT_CLK(A_CLK), 
        .A_ADDR_SRST_N(VCC), .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(VCC), 
        .A_DOUT_ARST_N(VCC), .A_ADDR_EN(VCC), .A_DOUT_EN(VCC), .A_BLK({
        rBlk, VCC}), .A_ADDR({rAddr[7], rAddr[6], rAddr[5], rAddr[4], 
        rAddr[3], rAddr[2], rAddr[1], rAddr[0], GND, GND}), 
        .B_ADDR_CLK(VCC), .B_DOUT_CLK(VCC), .B_ADDR_SRST_N(VCC), 
        .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(VCC), .B_DOUT_ARST_N(VCC), 
        .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), .B_BLK({B_BLK, VCC}), 
        .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], B_ADDR[4], B_ADDR[3], 
        B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, GND}), .C_CLK(wClk), 
        .C_ADDR({wAddr[7], wAddr[6], wAddr[5], wAddr[4], wAddr[3], 
        wAddr[2], wAddr[1], wAddr[0], GND, GND}), .C_DIN({GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        wD[27], wD[26], wD[25], wD[24]}), .C_WEN(wEn), .C_BLK({wBlk, 
        VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(GND), 
        .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C0 (.A_DOUT({nc84, nc85, 
        nc86, nc87, nc88, nc89, nc90, nc91, nc92, nc93, nc94, nc95, 
        nc96, nc97, rD[3], rD[2], rD[1], rD[0]}), .B_DOUT({nc98, nc99, 
        nc100, nc101, nc102, nc103, nc104, nc105, nc106, nc107, nc108, 
        nc109, nc110, nc111, B_DOUT[3], B_DOUT[2], B_DOUT[1], 
        B_DOUT[0]}), .BUSY(), .A_ADDR_CLK(A_CLK), .A_DOUT_CLK(A_CLK), 
        .A_ADDR_SRST_N(VCC), .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(VCC), 
        .A_DOUT_ARST_N(VCC), .A_ADDR_EN(VCC), .A_DOUT_EN(VCC), .A_BLK({
        rBlk, VCC}), .A_ADDR({rAddr[7], rAddr[6], rAddr[5], rAddr[4], 
        rAddr[3], rAddr[2], rAddr[1], rAddr[0], GND, GND}), 
        .B_ADDR_CLK(VCC), .B_DOUT_CLK(VCC), .B_ADDR_SRST_N(VCC), 
        .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(VCC), .B_DOUT_ARST_N(VCC), 
        .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), .B_BLK({B_BLK, VCC}), 
        .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], B_ADDR[4], B_ADDR[3], 
        B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, GND}), .C_CLK(wClk), 
        .C_ADDR({wAddr[7], wAddr[6], wAddr[5], wAddr[4], wAddr[3], 
        wAddr[2], wAddr[1], wAddr[0], GND, GND}), .C_DIN({GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        wD[3], wD[2], wD[1], wD[0]}), .C_WEN(wEn), .C_BLK({wBlk, VCC}), 
        .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(GND), .A_WIDTH({GND, 
        VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), .C_WIDTH({GND, VCC, GND})
        , .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C7 (.A_DOUT({nc112, 
        nc113, nc114, nc115, nc116, nc117, nc118, nc119, nc120, nc121, 
        nc122, nc123, nc124, nc125, rD[31], rD[30], rD[29], rD[28]}), 
        .B_DOUT({nc126, nc127, nc128, nc129, nc130, nc131, nc132, 
        nc133, nc134, nc135, nc136, nc137, nc138, nc139, B_DOUT[31], 
        B_DOUT[30], B_DOUT[29], B_DOUT[28]}), .BUSY(), .A_ADDR_CLK(
        A_CLK), .A_DOUT_CLK(A_CLK), .A_ADDR_SRST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(VCC), .A_DOUT_ARST_N(VCC), 
        .A_ADDR_EN(VCC), .A_DOUT_EN(VCC), .A_BLK({rBlk, VCC}), .A_ADDR({
        rAddr[7], rAddr[6], rAddr[5], rAddr[4], rAddr[3], rAddr[2], 
        rAddr[1], rAddr[0], GND, GND}), .B_ADDR_CLK(VCC), .B_DOUT_CLK(
        VCC), .B_ADDR_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(
        VCC), .B_DOUT_ARST_N(VCC), .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), 
        .B_BLK({B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(wClk), .C_ADDR({wAddr[7], wAddr[6], wAddr[5], 
        wAddr[4], wAddr[3], wAddr[2], wAddr[1], wAddr[0], GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, wD[31], wD[30], wD[29], wD[28]}), .C_WEN(wEn), 
        .C_BLK({wBlk, VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(
        GND), .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C2 (.A_DOUT({nc140, 
        nc141, nc142, nc143, nc144, nc145, nc146, nc147, nc148, nc149, 
        nc150, nc151, nc152, nc153, rD[11], rD[10], rD[9], rD[8]}), 
        .B_DOUT({nc154, nc155, nc156, nc157, nc158, nc159, nc160, 
        nc161, nc162, nc163, nc164, nc165, nc166, nc167, B_DOUT[11], 
        B_DOUT[10], B_DOUT[9], B_DOUT[8]}), .BUSY(), .A_ADDR_CLK(A_CLK)
        , .A_DOUT_CLK(A_CLK), .A_ADDR_SRST_N(VCC), .A_DOUT_SRST_N(VCC), 
        .A_ADDR_ARST_N(VCC), .A_DOUT_ARST_N(VCC), .A_ADDR_EN(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({rBlk, VCC}), .A_ADDR({rAddr[7], 
        rAddr[6], rAddr[5], rAddr[4], rAddr[3], rAddr[2], rAddr[1], 
        rAddr[0], GND, GND}), .B_ADDR_CLK(VCC), .B_DOUT_CLK(VCC), 
        .B_ADDR_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(VCC), 
        .B_DOUT_ARST_N(VCC), .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), .B_BLK({
        B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(wClk), .C_ADDR({wAddr[7], wAddr[6], wAddr[5], 
        wAddr[4], wAddr[3], wAddr[2], wAddr[1], wAddr[0], GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, wD[11], wD[10], wD[9], wD[8]}), .C_WEN(wEn), 
        .C_BLK({wBlk, VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(
        GND), .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C1 (.A_DOUT({nc168, 
        nc169, nc170, nc171, nc172, nc173, nc174, nc175, nc176, nc177, 
        nc178, nc179, nc180, nc181, rD[7], rD[6], rD[5], rD[4]}), 
        .B_DOUT({nc182, nc183, nc184, nc185, nc186, nc187, nc188, 
        nc189, nc190, nc191, nc192, nc193, nc194, nc195, B_DOUT[7], 
        B_DOUT[6], B_DOUT[5], B_DOUT[4]}), .BUSY(), .A_ADDR_CLK(A_CLK), 
        .A_DOUT_CLK(A_CLK), .A_ADDR_SRST_N(VCC), .A_DOUT_SRST_N(VCC), 
        .A_ADDR_ARST_N(VCC), .A_DOUT_ARST_N(VCC), .A_ADDR_EN(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({rBlk, VCC}), .A_ADDR({rAddr[7], 
        rAddr[6], rAddr[5], rAddr[4], rAddr[3], rAddr[2], rAddr[1], 
        rAddr[0], GND, GND}), .B_ADDR_CLK(VCC), .B_DOUT_CLK(VCC), 
        .B_ADDR_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(VCC), 
        .B_DOUT_ARST_N(VCC), .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), .B_BLK({
        B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(wClk), .C_ADDR({wAddr[7], wAddr[6], wAddr[5], 
        wAddr[4], wAddr[3], wAddr[2], wAddr[1], wAddr[0], GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, wD[7], wD[6], wD[5], wD[4]}), .C_WEN(wEn), 
        .C_BLK({wBlk, VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(
        GND), .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    RAM64x18 adc_fft_if_COREFFT_0_uram_smGen_R0C4 (.A_DOUT({nc196, 
        nc197, nc198, nc199, nc200, nc201, nc202, nc203, nc204, nc205, 
        nc206, nc207, nc208, nc209, rD[19], rD[18], rD[17], rD[16]}), 
        .B_DOUT({nc210, nc211, nc212, nc213, nc214, nc215, nc216, 
        nc217, nc218, nc219, nc220, nc221, nc222, nc223, B_DOUT[19], 
        B_DOUT[18], B_DOUT[17], B_DOUT[16]}), .BUSY(), .A_ADDR_CLK(
        A_CLK), .A_DOUT_CLK(A_CLK), .A_ADDR_SRST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(VCC), .A_DOUT_ARST_N(VCC), 
        .A_ADDR_EN(VCC), .A_DOUT_EN(VCC), .A_BLK({rBlk, VCC}), .A_ADDR({
        rAddr[7], rAddr[6], rAddr[5], rAddr[4], rAddr[3], rAddr[2], 
        rAddr[1], rAddr[0], GND, GND}), .B_ADDR_CLK(VCC), .B_DOUT_CLK(
        VCC), .B_ADDR_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(
        VCC), .B_DOUT_ARST_N(VCC), .B_ADDR_EN(VCC), .B_DOUT_EN(VCC), 
        .B_BLK({B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(wClk), .C_ADDR({wAddr[7], wAddr[6], wAddr[5], 
        wAddr[4], wAddr[3], wAddr[2], wAddr[1], wAddr[0], GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, wD[19], wD[18], wD[17], wD[16]}), .C_WEN(wEn), 
        .C_BLK({wBlk, VCC}), .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(
        GND), .A_WIDTH({GND, VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), 
        .C_WIDTH({GND, VCC, GND}), .SII_LOCK(GND));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
