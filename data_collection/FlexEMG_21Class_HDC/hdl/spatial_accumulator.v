`include "const.vh"

module spatial_accumulator
(
	// global ports
	input Clk_CI, Reset_RI, 

	// control signals
	input Enable_SI, FirstHypervector_SI,

	// input values
	input [0:`SPATIAL_DIMENSION-1] HypervectorIn_DI,
	input [`CHANNEL_WIDTH-1:0] FeatureIn_DI,

	// output value
	output [0:`SPATIAL_DIMENSION-1] HypervectorOut_DO
);
	// accumulator register
	reg [`SPATIAL_WIDTH-1:0] Accumulator_DP [0:`SPATIAL_DIMENSION-1];
	reg [`SPATIAL_WIDTH-1:0] Accumulator_DN [0:`SPATIAL_DIMENSION-1];

	// up down accumulator based on HV element
	integer i;
	always @(*) begin
		for (i=0; i<`SPATIAL_DIMENSION; i=i+1) begin
			if (FirstHypervector_SI) begin
				if (HypervectorIn_DI[i])
					Accumulator_DN[i] = -FeatureIn_DI;
				else
					Accumulator_DN[i] = FeatureIn_DI;
			end else begin
				if (HypervectorIn_DI[i])
					Accumulator_DN[i] = Accumulator_DP[i] - FeatureIn_DI;
				else
					Accumulator_DN[i] = Accumulator_DP[i] + FeatureIn_DI;
			end
		end
	end

	// take sign bit as output
	genvar j;
	for (j=0; j<`SPATIAL_DIMENSION; j=j+1) begin
		assign HypervectorOut_DO[j] = Accumulator_DP[j][`SPATIAL_WIDTH-1];
	end

	// update accumulator reg
	always @(posedge Clk_CI) begin
		if (Reset_RI)
			for (i=0; i<`SPATIAL_DIMENSION; i=i+1) Accumulator_DP[i] = {`SPATIAL_WIDTH{1'b0}};
		else if (Enable_SI)
			for (i=0; i<`SPATIAL_DIMENSION; i=i+1) Accumulator_DP[i] = Accumulator_DN[i];
	end
endmodule
