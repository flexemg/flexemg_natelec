`timescale 1 ns/100 ps
// Version: v11.7 SP3 11.7.3.7


module adc_fft_if_COREFIFO_0_LSRAM_top(
       WD,
       RD,
       WADDR,
       RADDR,
       WEN,
       REN,
       CLK
    );
input  [31:0] WD;
output [31:0] RD;
input  [8:0] WADDR;
input  [8:0] RADDR;
input  WEN;
input  REN;
input  CLK;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM1K18 adc_fft_if_COREFIFO_0_LSRAM_top_R0C0 (.A_DOUT({nc0, RD[31], 
        RD[30], RD[29], RD[28], RD[27], RD[26], RD[25], RD[24], nc1, 
        RD[23], RD[22], RD[21], RD[20], RD[19], RD[18], RD[17], RD[16]})
        , .B_DOUT({nc2, RD[15], RD[14], RD[13], RD[12], RD[11], RD[10], 
        RD[9], RD[8], nc3, RD[7], RD[6], RD[5], RD[4], RD[3], RD[2], 
        RD[1], RD[0]}), .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(VCC), 
        .A_ARST_N(VCC), .A_DOUT_EN(VCC), .A_BLK({REN, VCC, VCC}), 
        .A_DOUT_ARST_N(VCC), .A_DOUT_SRST_N(VCC), .A_DIN({GND, WD[31], 
        WD[30], WD[29], WD[28], WD[27], WD[26], WD[25], WD[24], GND, 
        WD[23], WD[22], WD[21], WD[20], WD[19], WD[18], WD[17], WD[16]})
        , .A_ADDR({RADDR[8], RADDR[7], RADDR[6], RADDR[5], RADDR[4], 
        RADDR[3], RADDR[2], RADDR[1], RADDR[0], GND, GND, GND, GND, 
        GND}), .A_WEN({VCC, VCC}), .B_CLK(CLK), .B_DOUT_CLK(VCC), 
        .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, VCC, VCC}), 
        .B_DOUT_ARST_N(VCC), .B_DOUT_SRST_N(VCC), .B_DIN({GND, WD[15], 
        WD[14], WD[13], WD[12], WD[11], WD[10], WD[9], WD[8], GND, 
        WD[7], WD[6], WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]}), 
        .B_ADDR({WADDR[8], WADDR[7], WADDR[6], WADDR[5], WADDR[4], 
        WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND, GND, GND, 
        GND}), .B_WEN({VCC, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), 
        .A_WIDTH({VCC, GND, VCC}), .A_WMODE(GND), .B_EN(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({VCC, GND, VCC}), .B_WMODE(GND), 
        .SII_LOCK(GND));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
