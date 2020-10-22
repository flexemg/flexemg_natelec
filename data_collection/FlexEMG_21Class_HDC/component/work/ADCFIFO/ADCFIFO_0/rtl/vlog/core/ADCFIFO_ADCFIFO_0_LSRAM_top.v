`timescale 1 ns/100 ps
// Version: v11.7 SP1 11.7.1.11


module ADCFIFO_ADCFIFO_0_LSRAM_top(
       WD,
       RD,
       WADDR,
       RADDR,
       WEN,
       REN,
       CLK
    );
input  [15:0] WD;
output [15:0] RD;
input  [5:0] WADDR;
input  [5:0] RADDR;
input  WEN;
input  REN;
input  CLK;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM1K18 ADCFIFO_ADCFIFO_0_LSRAM_top_R0C0 (.A_DOUT({nc0, RD[15], 
        RD[14], RD[13], RD[12], RD[11], RD[10], RD[9], RD[8], nc1, 
        RD[7], RD[6], RD[5], RD[4], RD[3], RD[2], RD[1], RD[0]}), 
        .B_DOUT({nc2, nc3, nc4, nc5, nc6, nc7, nc8, nc9, nc10, nc11, 
        nc12, nc13, nc14, nc15, nc16, nc17, nc18, nc19}), .BUSY(), 
        .A_CLK(CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), .A_DOUT_EN(VCC), 
        .A_BLK({REN, VCC, VCC}), .A_DOUT_ARST_N(VCC), .A_DOUT_SRST_N(
        VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND}), .A_ADDR({GND, GND, 
        GND, GND, RADDR[5], RADDR[4], RADDR[3], RADDR[2], RADDR[1], 
        RADDR[0], GND, GND, GND, GND}), .A_WEN({GND, GND}), .B_CLK(CLK)
        , .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({
        WEN, VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(VCC), 
        .B_DIN({GND, WD[15], WD[14], WD[13], WD[12], WD[11], WD[10], 
        WD[9], WD[8], GND, WD[7], WD[6], WD[5], WD[4], WD[3], WD[2], 
        WD[1], WD[0]}), .B_ADDR({GND, GND, GND, GND, WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND, 
        GND, GND}), .B_WEN({VCC, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), 
        .A_WIDTH({VCC, GND, GND}), .A_WMODE(GND), .B_EN(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({VCC, GND, GND}), .B_WMODE(GND), 
        .SII_LOCK(GND));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
