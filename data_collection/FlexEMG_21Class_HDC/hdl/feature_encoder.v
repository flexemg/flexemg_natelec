`include "const.vh"

module feature_encoder
(
	// global ports
	input Clk_CI, Reset_RI, 

	// handshaking
	input ValidIn_SI, ReadyIn_SI,
	output reg ReadyOut_SO, ValidOut_SO,

	// inputs
	input [`MODE_WIDTH-1:0] ModeIn_SI,
	input [`LABEL_WIDTH-1:0] LabelIn_DI, 
	input [`RAW_WIDTH*`INPUT_CHANNELS-1:0] Raw_DI,

	// outputs
	output [`MODE_WIDTH-1:0] ModeOut_SO,
	output [`LABEL_WIDTH-1:0] LabelOut_DO,
	output [`CHANNEL_WIDTH*`INPUT_CHANNELS-1:0] ChannelsOut_DO,

    // debugs
    output reg [`ceilLog2(`FEATWIN_SIZE)-1:0] FeatureCntr 
);

	// FSM state definitions
	localparam IDLE = 0;
	localparam FEATURE_CALC = 1;
	localparam FEATURE_READY = 2;

	// FSM and control signals
	reg [1:0] prev_state, next_state;
	reg SBuff_WE, SBuff_RE;

	// datapath internal wires
	wire [`MODE_WIDTH-1:0] ModeIn_SN;
	wire [`LABEL_WIDTH-1:0] LabelIn_DN;
	wire [`RAW_WIDTH-1:0] Raw_DN [0:`INPUT_CHANNELS-1];
	wire [`RAW_WIDTH*`INPUT_CHANNELS-1:0] OldSample;

	reg [`MODE_WIDTH-1:0] ModeIn_SP;
	reg [`LABEL_WIDTH-1:0] LabelIn_DP;
	reg [`RAW_WIDTH-1:0] Raw_DP [0:`INPUT_CHANNELS-1];
	reg [`RAW_WIDTH+`ceilLog2(`SBUFFER_DEPTH)-1:0] MeanVal [0:`INPUT_CHANNELS-1];
	reg [`RAW_WIDTH-1:0] RawDemean [0:`INPUT_CHANNELS-1];
    reg [`RAW_WIDTH-1:0] RawDemean2 [0:`INPUT_CHANNELS-1];
	reg [`RAW_WIDTH+`FEATWIN_SIZE-1:0] FeatureVal [0:`INPUT_CHANNELS-1];
	reg [`CHANNEL_WIDTH-1:0] ChannelsOut [0:`INPUT_CHANNELS-1];

	// DATAPATH

	// latch input signals
	assign ModeIn_SN = ModeIn_SI;
	assign LabelIn_DN = LabelIn_DI;

	generate
		genvar j;
		for (j=0; j < `INPUT_CHANNELS; j=j+1) begin
			assign Raw_DN[j] = Raw_DI[(j+1)*`RAW_WIDTH-1:j*`RAW_WIDTH];
			assign ChannelsOut_DO[(j+1)*`CHANNEL_WIDTH-1:j*`CHANNEL_WIDTH] = ChannelsOut[j];
		end
	endgenerate

	integer i;
	always @(posedge Clk_CI) begin
		if (Reset_RI) begin
			ModeIn_SP <= {`MODE_WIDTH{1'b0}};
			LabelIn_DP <= {`LABEL_WIDTH{1'b0}};
			for (i=0; i < `INPUT_CHANNELS; i=i+1) Raw_DP[i] <= {`RAW_WIDTH{1'b0}};
		end
		else if (prev_state == IDLE && ValidIn_SI == 1) begin
			ModeIn_SP <= ModeIn_SN;
			LabelIn_DP <= LabelIn_DN;
			for (i=0; i < `INPUT_CHANNELS; i=i+1) Raw_DP[i] <= Raw_DN[i];
		end
        else begin
            ModeIn_SP <= ModeIn_SP;
            LabelIn_DP <= LabelIn_DP;
            for (i=0; i < `INPUT_CHANNELS; i=i+1) Raw_DP[i] <= Raw_DP[i];
        end
	end

	assign ModeOut_SO = ModeIn_SP;
	assign LabelOut_DO = LabelIn_DP;

	// instantiate sample buffer
	fifo #(.data_width(`RAW_WIDTH*`INPUT_CHANNELS), .fifo_depth(`SBUFFER_DEPTH), .addr_width(`ceilLog2(`SBUFFER_DEPTH))) SampleBuffer (
		.clk(Clk_CI),
		.rst(Reset_RI),
		.wr_en(SBuff_WE),
		.din(Raw_DI),
		.rd_en(SBuff_RE),
		.dout(OldSample)
	);

    generate
    genvar k;
        for (k=0; k < `INPUT_CHANNELS; k=k+1) begin
            always @(*) begin
                ChannelsOut[k] = (FeatureVal[k][`RAW_WIDTH+`FEATWIN_SIZE-1:0] > ((1 << `CHANNEL_WIDTH)-1)) ? ((1 << `CHANNEL_WIDTH)-1) : FeatureVal[k][`RAW_WIDTH+`FEATWIN_SIZE-1:0];
                // Demean the raw signal					
                RawDemean[k] = Raw_DP[k] - ((Raw_DP[k] - OldSample[k*`RAW_WIDTH+:`RAW_WIDTH] + MeanVal[k]) >> (`ceilLog2(`SBUFFER_DEPTH)));
                // absolute value:
                if (RawDemean[k][`RAW_WIDTH-1])
                    RawDemean2[k] = -RawDemean[k];
                else
                    RawDemean2[k] = RawDemean[k];
            end
        end
    endgenerate

    

	// FSM
	always @(*) begin
		// default values
		next_state = IDLE;
		
		ReadyOut_SO = 1'b0;
		ValidOut_SO = 1'b0;

		SBuff_WE = 1'b0;
		SBuff_RE = 1'b0;

		case (prev_state)
			IDLE: begin
				next_state = ValidIn_SI ? FEATURE_CALC : IDLE;
				ReadyOut_SO = 1'b1;
				SBuff_WE = ValidIn_SI ? 1'b1 : 1'b0;
				SBuff_RE = ValidIn_SI ? 1'b1 : 1'b0;
			end
			FEATURE_CALC: begin
				if (FeatureCntr == `FEATWIN_SIZE-1) begin
					next_state = FEATURE_READY;
				end
				else begin
					next_state = IDLE;
				end
			end
			FEATURE_READY: begin
				next_state = ReadyIn_SI ? IDLE : FEATURE_READY;
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

	// FSM output registers
	always @(posedge Clk_CI) begin
		if (Reset_RI) begin
			for (i=0; i < `INPUT_CHANNELS; i=i+1) begin
				MeanVal[i] <= {(`RAW_WIDTH+`ceilLog2(`SBUFFER_DEPTH)){1'b0}};
				FeatureVal[i] <= {(`RAW_WIDTH+`FEATWIN_SIZE){1'b0}};
			end
			FeatureCntr <= 0;
		end
		else
		case (prev_state)
			IDLE: begin
                for (i=0; i < `INPUT_CHANNELS; i=i+1) begin
                    MeanVal[i] <= MeanVal[i];
                    FeatureVal[i] <= FeatureVal[i];
                end
                FeatureCntr <= FeatureCntr;
			end
			FEATURE_CALC: begin
				for (i=0; i < `INPUT_CHANNELS; i=i+1) begin
					MeanVal[i] <= Raw_DP[i] - OldSample[i*`RAW_WIDTH+:`RAW_WIDTH] + MeanVal[i];	
				end
				if (FeatureCntr == `FEATWIN_SIZE-1) begin
					FeatureCntr <= 0;
					// for (i=0; i < `INPUT_CHANNELS; i=i+1) FeatureVal[i] <= (RawDemean2[i] + FeatureVal[i]) >> (`ceilLog2(`FEATWIN_SIZE));
					for (i=0; i < `INPUT_CHANNELS; i=i+1) FeatureVal[i] <= (RawDemean2[i] + FeatureVal[i]) >> (`ceilLog2(`FEATWIN_SIZE))-1;
				end
				else if (FeatureCntr == 0) begin
					FeatureCntr <= FeatureCntr + 1;					
					for (i=0; i < `INPUT_CHANNELS; i=i+1) FeatureVal[i] <= RawDemean2[i];
				end
				else begin
					FeatureCntr <= FeatureCntr + 1;
					for (i=0; i < `INPUT_CHANNELS; i=i+1) FeatureVal[i] <= RawDemean2[i] + FeatureVal[i];
				end
			end
			FEATURE_READY: begin
				for (i=0; i < `INPUT_CHANNELS; i=i+1) begin
                    MeanVal[i] <= MeanVal[i];
                    FeatureVal[i] <= FeatureVal[i];
                end
                FeatureCntr <= FeatureCntr;
			end
			default: ;
		endcase // prev_state		
	end

endmodule
