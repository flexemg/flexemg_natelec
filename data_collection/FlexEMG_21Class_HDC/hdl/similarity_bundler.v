`include "const.vh"

module similarity_bundler
(
	input Clk_CI, Reset_RI, 
	input BundledHypervectorEN_SI, 
	input CycleShiftRegEN_SI, CycleShiftRegCLR_SI,
	input [0:`HV_DIMENSION-1] HypervectorIn_DI,
	output [0:`HV_DIMENSION-1] HypervectorOut_DO
);

reg [0:`HV_DIMENSION-1] BundledHypervector_DP;
wire [0:`HV_DIMENSION-1] BundledHypervector_DN;
reg [0:`MAX_BUNDLE_CYCLES-1] CycleShiftReg_SP;
wire [0:`MAX_BUNDLE_CYCLES-1] CycleShiftReg_SN;
wire [0:`HV_DIMENSION-1] SimilarHypervector_D;

hypervector_manipulator manipulate_forbundler (
	.HypervectorIn_DI(BundledHypervector_DP), 
	.ManipulatorIn_DI(CycleShiftReg_SP),
	.HypervectorOut_DO(SimilarHypervector_D)
);

assign CycleShiftReg_SN = CycleShiftReg_SP >> 1;

genvar i;
generate
	for (i=0; i<`HV_DIMENSION; i=i+1) begin
		assign BundledHypervector_DN[i] =
        	(BundledHypervector_DP[i] & HypervectorIn_DI[i]) |
        	(BundledHypervector_DP[i] & SimilarHypervector_D[i]) |
        	(HypervectorIn_DI[i] & SimilarHypervector_D[i]);
	end
endgenerate

assign HypervectorOut_DO = BundledHypervector_DP;

always @ (posedge Clk_CI) begin
	if ((Reset_RI == 1'b1) || (CycleShiftRegCLR_SI == 1'b1)) begin
		CycleShiftReg_SP <= {1'b1,{`MAX_BUNDLE_CYCLES-1{1'b0}}};
	end else if (CycleShiftRegEN_SI == 1'b1) begin
		CycleShiftReg_SP <= CycleShiftReg_SN;
	end
end

always @ (posedge Clk_CI) begin
	if (Reset_RI == 1'b1) begin
		BundledHypervector_DP <= {`HV_DIMENSION{1'b0}};
	end 
	else if (BundledHypervectorEN_SI == 1'b1) begin
		BundledHypervector_DP <= BundledHypervector_DN;
	end
end

endmodule