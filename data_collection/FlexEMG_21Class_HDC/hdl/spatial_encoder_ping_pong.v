`include "const.vh"

module spatial_encoder_ping_pong
(
	// global ports
	input Clk_CI, Reset_RI, 

	// handshaking
	input ValidIn_SI, ReadyIn_SI,
	output reg ReadyOut_SO, ValidOut_SO,

	// inputs
	input [`MODE_WIDTH-1:0] ModeIn_SI,
	input [`LABEL_WIDTH-1:0] LabelIn_DI, 
	input [`CHANNEL_WIDTH*`INPUT_CHANNELS-1:0] ChannelsIn_DI,

	// outputs
	output [`MODE_WIDTH-1:0] ModeOut_SO,
	output [`LABEL_WIDTH-1:0] LabelOut_DO,
	output [0:`HV_DIMENSION-1] HypervectorOut_DO
);

// FSM state definitions
localparam IDLE = 0;
localparam DATA_RECEIVED_0 = 1;
localparam ACCUM_FED_0 = 2;
localparam DATA_RECEIVED_1 = 3;
localparam ACCUM_FED_1 = 4;
localparam CHANNELS_MAPPED = 5;

// FSM and control signals
reg [2:0] prev_state, next_state;
reg InputBuffersEN_S, AccumulatorEN_S, CellAutoEN_S, CellAutoCLR_S, CycleCntrEN_S, CycleCntrCLR_S;
reg FirstHypervector_S;
wire LastChannel_S;
reg IMHalf;
reg Latch_0;

// Cycle (channel) counter
reg [`ceilLog2(`INPUT_CHANNELS)-1:0] CycleCntr_SP;
wire [`ceilLog2(`INPUT_CHANNELS)-1:0] CycleCntr_SN;

// datapath internal wires
wire [`MODE_WIDTH-1:0] ModeIn_SN;
wire [`LABEL_WIDTH-1:0] LabelIn_DN;
wire [`CHANNEL_WIDTH-1:0] ChannelsIn_DN [0:`INPUT_CHANNELS-1];

reg [`MODE_WIDTH-1:0] ModeIn_SP;
reg [`LABEL_WIDTH-1:0] LabelIn_DP;
reg [`CHANNEL_WIDTH-1:0] ChannelsIn_DP [0:`INPUT_CHANNELS-1];

wire [`CHANNEL_WIDTH-1:0] ChannelFeature_D;

wire [0:`SPATIAL_DIMENSION-1] IMOut_D [0:1];
wire [0:`SPATIAL_DIMENSION-1] SpatAccumIn;

wire [0:`SPATIAL_DIMENSION-1] SpatAccumOut;
reg [0:`SPATIAL_DIMENSION-1] Result_0;


// DATAPATH
// latch input signals
assign ModeIn_SN = ModeIn_SI;
assign LabelIn_DN = LabelIn_DI;

// assign ChannelsIn_DN = ChannelsIn_DI;
genvar j;
generate
	for (j=0; j<`INPUT_CHANNELS; j=j+1) begin
		assign ChannelsIn_DN[j] = ChannelsIn_DI[(`CHANNEL_WIDTH-1+(`CHANNEL_WIDTH*j)):(`CHANNEL_WIDTH*j)];
	end
endgenerate

integer i;
always @(posedge Clk_CI) begin
	if (Reset_RI) begin
		ModeIn_SP <= {`MODE_WIDTH{1'b0}};
		LabelIn_DP <= {`LABEL_WIDTH{1'b0}};
		for (i=0; i < `INPUT_CHANNELS; i=i+1) ChannelsIn_DP[i] <= {`CHANNEL_WIDTH{1'b0}};
	end else if (InputBuffersEN_S) begin
		ModeIn_SP <= ModeIn_SN;
		LabelIn_DP <= LabelIn_DN;
		for (i=0; i < `INPUT_CHANNELS; i=i+1) ChannelsIn_DP[i] <= ChannelsIn_DN[i];
	end
end

// get current feature value
assign ChannelFeature_D = ChannelsIn_DP[CycleCntr_SP];
// get current half of cell auto to the spatial accumulator
assign SpatAccumIn = IMHalf ? IMOut_D[1] : IMOut_D[0];
// asign outputs
assign HypervectorOut_DO[`SPATIAL_DIMENSION:`HV_DIMENSION-1] = SpatAccumOut;
assign HypervectorOut_DO[0:`SPATIAL_DIMENSION-1] = Result_0;

// cellular automaton
cellular_automaton Cell_Auto(
	.Clk_CI(Clk_CI),
	.Reset_RI(Reset_RI),
	.Enable_SI(CellAutoEN_S),
	.Clear_SI(CellAutoCLR_S),
	.CellValueOut_DO({IMOut_D[0], IMOut_D[1]})
);

// accumulator
spatial_accumulator Spat_Accum(
	.Clk_CI(Clk_CI),
	.Reset_RI(Reset_RI),
	.Enable_SI(AccumulatorEN_S),
	.FirstHypervector_SI(FirstHypervector_S),
	.HypervectorIn_DI(SpatAccumIn),
	.FeatureIn_DI(ChannelFeature_D),
	.HypervectorOut_DO(SpatAccumOut)
);

assign ModeOut_SO = ModeIn_SP;
assign LabelOut_DO = LabelIn_DP;

// CONTROLLER

// signals for looping through channels
assign LastChannel_S = (CycleCntr_SP == `INPUT_CHANNELS-1);
assign CycleCntr_SN = CycleCntr_SP + 1;
// FSM
always @(*) begin
	// default values
	next_state = IDLE;
	
	ReadyOut_SO = 1'b0;
	ValidOut_SO = 1'b0;

	InputBuffersEN_S = 1'b0;
	AccumulatorEN_S = 1'b0;
	CellAutoEN_S = 1'b0;
	CellAutoCLR_S = 1'b0;
	CycleCntrEN_S = 1'b0;
	CycleCntrCLR_S = 1'b0;

	FirstHypervector_S = 1'b0;
	IMHalf = 1'b0;
	Latch_0 = 1'b0;

	case (prev_state)
		IDLE: begin
			next_state = ValidIn_SI ? DATA_RECEIVED_0 : IDLE;
			ReadyOut_SO = 1;
			InputBuffersEN_S = ValidIn_SI ? 1'b1 : 1'b0;
		end
		DATA_RECEIVED_0: begin
			next_state = ACCUM_FED_0;
			AccumulatorEN_S = 1'b1;
			CellAutoEN_S = 1'b1;
			CycleCntrEN_S = 1'b1;
			FirstHypervector_S = 1'b1;
		end
		ACCUM_FED_0: begin
			next_state = LastChannel_S ? DATA_RECEIVED_1 : ACCUM_FED_0;
			AccumulatorEN_S = 1'b1;
			if (LastChannel_S) begin
				CellAutoCLR_S = 1'b1;
				CycleCntrCLR_S  = 1'b1;
			end else begin
				CellAutoEN_S = 1'b1;
				CycleCntrEN_S = 1'b1;
			end
		end
		DATA_RECEIVED_1: begin
			Latch_0 = 1'b1;
			IMHalf = 1'b1;
			next_state = ACCUM_FED_1;
			AccumulatorEN_S = 1'b1;
			CellAutoEN_S = 1'b1;
			CycleCntrEN_S = 1'b1;
			FirstHypervector_S = 1'b1;
		end
		ACCUM_FED_1: begin
			IMHalf = 1'b1;
			next_state = LastChannel_S ? CHANNELS_MAPPED : ACCUM_FED_1;
			AccumulatorEN_S = 1'b1;
			if (LastChannel_S) begin
				CellAutoCLR_S = 1'b1;
				CycleCntrCLR_S  = 1'b1;
			end else begin
				CellAutoEN_S = 1'b1;
				CycleCntrEN_S = 1'b1;
			end
		end
		CHANNELS_MAPPED: begin
			next_state = ReadyIn_SI ? IDLE : CHANNELS_MAPPED;
			ValidOut_SO = 1'b1;
		end
		default: ;
	endcase // prev_state
end

// FSM state transitions
always @(posedge Clk_CI) begin
	if (Reset_RI)
		prev_state <= IDLE;
	else
		prev_state <= next_state;
end

// Cycle (channel) counter
always @(posedge Clk_CI) begin
	if (Reset_RI || CycleCntrCLR_S) 
		CycleCntr_SP <= {`ceilLog2(`INPUT_CHANNELS){1'b0}};
	else if (CycleCntrEN_S)
		CycleCntr_SP <= CycleCntr_SN;
end

// latch bottom half
always @(posedge Clk_CI) begin
	if (Reset_RI)
		Result_0 <= {`SPATIAL_DIMENSION{1'b0}};
	else if (Latch_0)
		Result_0 <= SpatAccumOut;
end

endmodule






