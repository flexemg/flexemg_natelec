`include "const.vh"

module bundle_counter
(
	input Clk_CI, Reset_RI, 
	input Enable_SI, 
	input FirstHypervector_SI,
	input [0:`HV_DIMENSION-1] HypervectorIn_DI,
	output reg [0:`HV_DIMENSION-1] HypervectorOut_DO
);

localparam MAX_VALUE = {1'b0, {(`BUNDLE_NGRAMS_WIDTH - 1){1'b1}}};
localparam MIN_VALUE = {1'b1, {(`BUNDLE_NGRAMS_WIDTH - 1){1'b0}}};

reg [`BUNDLE_NGRAMS_WIDTH-1:0] BundleCounter_DP [0:`HV_DIMENSION-1];
reg [`BUNDLE_NGRAMS_WIDTH-1:0] BundleCounter_DN [0:`HV_DIMENSION-1];
reg [0:`HV_DIMENSION-1] CounterSEN_S;

integer i;
always @(*) begin
	for (i=0; i<`HV_DIMENSION; i=i+1) begin
		if (FirstHypervector_SI == 1'b1) begin
			BundleCounter_DN[i] = {{(`BUNDLE_NGRAMS_WIDTH-1){HypervectorIn_DI[i]}}, 1'b1};
			CounterSEN_S[i] = 1'b1;
		end else begin
			if (HypervectorIn_DI[i] == 1'b1) begin
				BundleCounter_DN[i] = BundleCounter_DP[i] - 1;
				CounterSEN_S[i] = (BundleCounter_DP[i] == MIN_VALUE) ? 1'b0 : 1'b1;
			end else begin
				BundleCounter_DN[i] = BundleCounter_DP[i] + 1;
				CounterSEN_S[i] = (BundleCounter_DP[i] == MAX_VALUE) ? 1'b0 : 1'b1;
			end
		end
		HypervectorOut_DO[i] = BundleCounter_DP[i][`BUNDLE_NGRAMS_WIDTH-1];
	end
end

always @ (posedge Clk_CI) begin
	if (Reset_RI == 1'b1) begin
		for (i=0; i<`HV_DIMENSION; i=i+1) BundleCounter_DP[i] <= {`BUNDLE_NGRAMS_WIDTH{1'b0}};
	end else if (Enable_SI == 1'b1) begin
		for (i=0; i<`HV_DIMENSION; i=i+1) begin
			if (CounterSEN_S[i] == 1'b1) BundleCounter_DP[i] <= BundleCounter_DN[i];
		end
	end
end

endmodule