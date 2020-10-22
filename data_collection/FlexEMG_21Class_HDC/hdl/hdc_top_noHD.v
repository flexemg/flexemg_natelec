`include "const.vh"

module hdc_top
(
	// global ports
	input HDC_Clk, Clk_CI, Reset_RI, 
    output HDC_ClkEn,

	// handshaking
	input ValidIn_SI, ReadyIn_SI,
	output ReadyOut_SO, ValidOut_SO,

	// inputs
	input [`MODE_WIDTH-1:0] ModeIn_SI,
	input [`LABEL_WIDTH-1:0] LabelIn_DI, 
	// input [`RAW_WIDTH*`INPUT_CHANNELS-1:0] Raw_DI,
    // make it compatible with ADC FIFO width
    input [1023:0] Raw_DI,

	// outputs
	output [`LABEL_WIDTH-1:0] LabelOut_DO,
	output [`DISTANCE_WIDTH-1:0] DistanceOut_DO,
    output [1023:0] Gest_Raw_Out
);


reg [15:0] Cntr, EnableCntr;

assign LabelOut_DO = {`LABEL_WIDTH{1'b0}};
assign DistanceOut_DO = {`DISTANCE_WIDTH{1'b0}};
assign ReadyOut_SO = 1'b0;
assign ValidOut_SO = 1'b0;

assign Gest_Raw_Out = {Raw_DI[1023:16], Cntr};

assign HDC_ClkEn = (EnableCntr < 200);

always @(posedge HDC_Clk) begin
    if (~Reset_RI)
        Cntr <= 16'b0;
    else
        Cntr <= Cntr + 1;
end

always @ (posedge Clk_CI) begin
    if (~Reset_RI)
        EnableCntr <= 16'b0;
    else if (ValidIn_SI)
        EnableCntr <= 16'b0;
    else
        EnableCntr <= EnableCntr + 1;
end

endmodule











