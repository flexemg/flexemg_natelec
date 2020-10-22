`include "const.vh"

module associative_memory
(
	// global inputs
	input Clk_CI, Reset_RI, 

	// handshaking
	input ValidIn_SI, ReadyIn_SI, 
	output reg ReadyOut_SO, ValidOut_SO,

	// inputs
	input [`MODE_WIDTH-1:0] ModeIn_SI, 
	input [`LABEL_WIDTH-1:0] LabelIn_DI, 
	input [0:`HV_DIMENSION-1] HypervectorIn_DI,
	
	// outputs
	output [`LABEL_WIDTH-1:0] LabelOut_DO,
	output [`DISTANCE_WIDTH-1:0] DistanceOut_DO
);

// rotating memory
reg [0:`HV_DIMENSION-1] TrainedMemory_DP [0:`CLASSES-1]; 
reg [0:`HV_DIMENSION-1] TrainedMemory_DN [0:`CLASSES-1];
reg [`LABEL_WIDTH-1:0] LabelMemory_DP [0:`CLASSES-1];
reg [`LABEL_WIDTH-1:0] LabelMemory_DN [0:`CLASSES-1];

// output buffers
reg [`LABEL_WIDTH-1:0] LabelOut_DP;
wire [`LABEL_WIDTH-1:0] LabelOut_DN;
reg [`DISTANCE_WIDTH-1:0] DistanceOut_DP;
wire [`DISTANCE_WIDTH-1:0] DistanceOut_DN;

// data registers
reg [0:`HV_DIMENSION-1] QueryHypervector_DP;
wire [0:`HV_DIMENSION-1] QueryHypervector_DN;

reg [`DISTANCE_WIDTH-1:0] CompDistance_DP;
wire [`DISTANCE_WIDTH-1:0] CompDistance_DN;

reg [`LABEL_WIDTH-1:0] CompLabel_DP;
wire [`LABEL_WIDTH-1:0] CompLabel_DN;


// FSM state definitions and control signals
reg [1:0] prev_state, next_state;
localparam IDLE = 2'd0;
localparam FIND_MIN_DIST = 2'd1;
localparam OUTPUT_STABLE = 2'd2;

// shift counter
localparam SHIFT_CNTR_WIDTH = `ceilLog2(`CLASSES+1);
reg [SHIFT_CNTR_WIDTH-1:0] ShiftCntr_SP; 
wire [SHIFT_CNTR_WIDTH-1:0] ShiftCntr_SN;

// Datapath signals
wire [0:`HV_DIMENSION-1] SimilarityOut_D;
reg [`DISTANCE_WIDTH-1:0] AdderOut_D;

wire CompRegisterSEN_S;

reg OutputBuffersEN_S, ShiftMemoryEN_S, QueryHypervectorEN_S, CompRegisterEN_S, CompRegisterCLR_S, ShiftCntrEN_S, ShiftCntrCLR_S, RotateMemories_S, UpdateEN_S;

wire ShiftComplete_S; 

reg [0:`HV_DIMENSION-1] UpdatedHypervector_D;

localparam [0:`HV_DIMENSION-1] BIT_SELECT = `MERGE_BITS;

// 50% merge
genvar i;
generate
	for (i=0; i<`HV_DIMENSION; i=i+1) begin
		always @(*) begin
			if (BIT_SELECT[i])
				UpdatedHypervector_D[i] = HypervectorIn_DI[i];
			else
				UpdatedHypervector_D[i] = TrainedMemory_DP[`CLASSES-1][i];
		end
	end
endgenerate

//rotating memory
always @(*) begin
	if (RotateMemories_S) begin
		// preserve memory during rotating search
		TrainedMemory_DN[0] = TrainedMemory_DP[`CLASSES-1];
		LabelMemory_DN[0] = LabelMemory_DP[`CLASSES-1];
	end else if (UpdateEN_S) begin
		// overwrite with merged vector
		TrainedMemory_DN[0] = UpdatedHypervector_D;
		LabelMemory_DN[0] = LabelIn_DI;
	end else begin
		// completely overwrite
		TrainedMemory_DN[0] = HypervectorIn_DI;
		LabelMemory_DN[0] = LabelIn_DI;
	end
end

assign QueryHypervector_DN = HypervectorIn_DI;

//trained and label memory shift register
generate
	for (i=1; i<`CLASSES; i=i+1) begin
		always @(*) begin
			TrainedMemory_DN[i] = TrainedMemory_DP[i-1];
			LabelMemory_DN[i] = LabelMemory_DP[i-1];
		end
	end
endgenerate

//Similarity
assign SimilarityOut_D = TrainedMemory_DP[`CLASSES-1] ^ QueryHypervector_DP;

//adders
integer j;
always @(*) begin
	AdderOut_D = {`DISTANCE_WIDTH{1'b0}};
	for (j=0; j<`HV_DIMENSION; j=j+1) begin
		AdderOut_D = AdderOut_D + SimilarityOut_D[j];
	end
end

//comparison
//Comparator Registers
assign CompLabel_DN = LabelMemory_DP[`CLASSES-1];
assign CompDistance_DN = AdderOut_D;

// Comparison
assign CompRegisterSEN_S = (CompDistance_DN < CompDistance_DP);

//Output Buffers
assign LabelOut_DN = CompLabel_DP;
assign DistanceOut_DN = CompDistance_DP;

//output signals
assign LabelOut_DO = LabelOut_DP;
assign DistanceOut_DO = DistanceOut_DP;

// Shift counter
assign ShiftCntr_SN = ShiftCntr_SP - 1;
assign ShiftComplete_S = ~|ShiftCntr_SP;

//FSM
always @(*) begin
	//Default Assignments
	next_state = IDLE;

	ReadyOut_SO = 1'b0;
	ValidOut_SO = 1'b0;

	OutputBuffersEN_S    	= 1'b0;
	ShiftMemoryEN_S      	= 1'b0;
	QueryHypervectorEN_S 	= 1'b0;
	CompRegisterEN_S     	= 1'b0;
	CompRegisterCLR_S    	= 1'b0;
	ShiftCntrEN_S       	= 1'b0;
	ShiftCntrCLR_S       	= 1'b0;
	RotateMemories_S     	= 1'b0;
	UpdateEN_S 		 		= 1'b0;

	case (prev_state)
		IDLE: begin
			ReadyOut_SO = 1'b1;
			if (ValidIn_SI == 1'b0) begin
				next_state = IDLE;
			end else begin
   				if (ModeIn_SI == `MODE_PREDICT) begin
   					// prediction mode: need to cycle through AM entries
   					next_state = FIND_MIN_DIST;
   				end else begin
   					// train or update mode: just need to store new entry and move on
   					next_state = IDLE;
   				end
   				UpdateEN_S = (ModeIn_SI == `MODE_UPDATE);
      			ShiftMemoryEN_S = (ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE);
      			QueryHypervectorEN_S = (ModeIn_SI == `MODE_PREDICT);
        	end
		end
		FIND_MIN_DIST: begin
			if (ShiftComplete_S == 1'b0) begin
      			next_state = FIND_MIN_DIST;
      			ShiftMemoryEN_S  = 1'b1;
      			CompRegisterEN_S = 1'b1;
      			ShiftCntrEN_S    = 1'b1;
      			RotateMemories_S = 1'b1;
      		end else begin
      			next_state = OUTPUT_STABLE;
      			OutputBuffersEN_S = 1'b1;
      			CompRegisterCLR_S = 1'b1;
      			ShiftCntrCLR_S    = 1'b1;
    		end
		end
		OUTPUT_STABLE: begin
			next_state = (ReadyIn_SI) ? IDLE : OUTPUT_STABLE;
    		ValidOut_SO = 1'b1;
		end

	endcase
end

//Memories
//Output buffers
always @ (posedge Clk_CI) begin
	if (Reset_RI) begin
		LabelOut_DP  <= {`LABEL_WIDTH{1'b0}};
    	DistanceOut_DP <= {`DISTANCE_WIDTH{1'b0}};
	end else if (OutputBuffersEN_S) begin
		LabelOut_DP  <= LabelOut_DN;
    	DistanceOut_DP <= DistanceOut_DN;
	end
end

//Data registers
// rotating memory
always @ (posedge Clk_CI) begin
	if (Reset_RI) begin
		for (j=0; j<`CLASSES; j=j+1) TrainedMemory_DP[j] <= {`HV_DIMENSION{1'b0}};
		for (j=0; j<`CLASSES; j=j+1) LabelMemory_DP[j] <= {`LABEL_WIDTH{1'b0}};
	end
	else if (ShiftMemoryEN_S == 1'b1) begin
		for (j=0; j<`CLASSES; j=j+1) TrainedMemory_DP[j] <= TrainedMemory_DN[j];
		for (j=0; j<`CLASSES; j=j+1) LabelMemory_DP[j] <= LabelMemory_DN[j];
	end
end

// query hypervector register
always @ (posedge Clk_CI) begin
	if (Reset_RI) 
		QueryHypervector_DP <= {`HV_DIMENSION{1'b0}};
	else if (QueryHypervectorEN_S)
		QueryHypervector_DP <= QueryHypervector_DN;
end

// comparator registers
always @ (posedge Clk_CI) begin
	if (Reset_RI || CompRegisterCLR_S) begin
		CompDistance_DP <= {`DISTANCE_WIDTH{1'b1}};
    	CompLabel_DP <= {`LABEL_WIDTH{1'b0}};
	end else if (CompRegisterEN_S && CompRegisterSEN_S) begin
		CompDistance_DP <= CompDistance_DN;
    	CompLabel_DP <= CompLabel_DN;
	end
end

// rotating memory counter register
always @ (posedge Clk_CI) begin
	if (Reset_RI || ShiftCntrCLR_S)
		ShiftCntr_SP <= `CLASSES;
	else if (ShiftCntrEN_S)
		ShiftCntr_SP <= ShiftCntr_SN;
end

// FSM transition register
always @ (posedge Clk_CI) begin
	if (Reset_RI)
		prev_state <= IDLE;
	else
		prev_state <= next_state;
end 

endmodule












