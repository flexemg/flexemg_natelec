`include "const.vh"

module cellular_automaton #
(	
	parameter WIDTH = `HV_DIMENSION,
	parameter NEIGHBORHOOD_WIDTH = 3,
	parameter RULE = 30
)
(
	// global ports
	input Clk_CI, Reset_RI, 

	// control signals
	input Enable_SI, Clear_SI,

	// output value
	output [0:WIDTH-1] CellValueOut_DO
);

// cell registers
reg [0:WIDTH-1] Cells_DP;
reg [0:WIDTH-1] Cells_DN;
initial 
  Cells_DP = `CELLULAR_AUTOMATON_SEED;

localparam RULE_VECTOR_WIDTH = 2**(2**NEIGHBORHOOD_WIDTH);
localparam [RULE_VECTOR_WIDTH-1:0] RULE_VECTOR = RULE;

genvar i;
generate
	for (i=0; i<WIDTH; i=i+1) begin
		reg [0:NEIGHBORHOOD_WIDTH-1] neighborhood;
		always @(*) begin
			if (i == 0) begin
				neighborhood = {Cells_DP[WIDTH-1], Cells_DP[0:1]};
				Cells_DN[i] = RULE_VECTOR[neighborhood];
			end else if (i == WIDTH-1) begin
				neighborhood = {Cells_DP[WIDTH-2:WIDTH-1], Cells_DP[0]};
				Cells_DN[i] = RULE_VECTOR[neighborhood];
			end else begin
				neighborhood = Cells_DP[i-1:i+1];
				Cells_DN[i] = RULE_VECTOR[neighborhood];
			end
		end
	end
endgenerate

assign CellValueOut_DO = Cells_DP;

always @(posedge Clk_CI) begin
	if (Reset_RI || Clear_SI) 
		Cells_DP <= `CELLULAR_AUTOMATON_SEED;
	else if (Enable_SI)
		Cells_DP <= Cells_DN;
end

endmodule