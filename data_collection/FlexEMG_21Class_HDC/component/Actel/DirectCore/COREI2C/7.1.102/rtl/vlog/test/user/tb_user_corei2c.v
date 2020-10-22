/******************************************************************************

    File Name:  tb_user_corei2c.v
      Version:  6.0
         Date:  Aug 24th, 2009
  Description:  Top level test module

      Company:  Actel

   SVN Revision Information:
   SVN $Revision: 10646 $
   SVN $Date: 2009-11-03 14:35:34 -0800 (Tue, 03 Nov 2009) $


 REVISION HISTORY:


 COPYRIGHT 2009 BY ACTEL
 THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS
 FROM ACTEL CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM
 ACTEL FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND
 NO BACK-UP OF THE FILE SHOULD BE MADE.

FUNCTIONAL DESCRIPTION:
Parameters marked with "user values" may be modified to check a given
	application.  Other parameter modifications may or may not break the TB.
Refer to the CoreI2C Handbook.
******************************************************************************/

`timescale 1 ns / 1 ns // timescale for following modules

module tb_user_corei2c ();
parameter halfperiod = 50; // half of the clock period
// serCON
parameter [4:0] serCON_ID = 5'b00000;  // serCON location
parameter [7:0] serCON_RV = 8'b00000000; // serCON reset
// serSTA
parameter [4:0] serSTA_ID = 5'b00100;  // serSTA location
parameter [7:0] serSTA_RV = 8'b11111000; // serSTA reset
// serDAT
parameter [4:0] serDAT_ID = 5'b01000;  // serDAT location
parameter [7:0] serDAT_RV = 8'b00000000; // serDAT reset
// serADR
parameter [4:0] serADR0_ID = 5'b01100;  // serADR location
parameter [7:0] serADR0_RV = 8'b00000000; // serADR reset
// serSMB
parameter [4:0] serSMB_ID = 5'b10000;  // SMB_ID location
parameter [7:0] serSMB_RV = 8'b01X1XX00; // SMB_ID reset
// serADR1
parameter [4:0] serADR1_ID = 5'b11100;  // serADR location
parameter [7:0] serADR1_RV = 8'b00000000; // serADR reset

//CoreI2C Instance configuration
//The User SHOULD NOT MODIFY any Instance 0 Parameters, else Testbench may fail.
parameter FAMILY_0         			=17;
parameter OPERATING_MODE_0 			=0;
parameter BAUD_RATE_FIXED_0			=0;
parameter BAUD_RATE_VALUE_0			=0;
parameter BCLK_ENABLED_0			=1;
parameter GLITCHREG_NUM_0			=3;
parameter SMB_EN_0         			=1;
parameter IPMI_EN_0					=0;
parameter FREQUENCY_0      			=20;
parameter FIXED_SLAVE0_ADDR_EN_0	=0;
parameter FIXED_SLAVE0_ADDR_VALUE_0	=0;
parameter ADD_SLAVE1_ADDRESS_EN_0	=0;
parameter FIXED_SLAVE1_ADDR_EN_0	=0;
parameter FIXED_SLAVE1_ADDR_VALUE_0	=0;
parameter I2C_NUM_0					=1;

//CoreI2C Instance0 configuration
//The User CAN modify some Instance 1 Parameters noted to check a given app.
parameter FAMILY_1         			=17;
parameter OPERATING_MODE_1 			=0; //user values: 0,1,2,3
parameter BAUD_RATE_FIXED_1			=0;
parameter BAUD_RATE_VALUE_1			=0;
parameter BCLK_ENABLED_1			=1;
parameter GLITCHREG_NUM_1			=3; //user values: 3-15
parameter SMB_EN_1         			=0; //user values: 0,1
parameter IPMI_EN_1					=1; //user values: 0,1
parameter FREQUENCY_1      			=20;
parameter FIXED_SLAVE0_ADDR_EN_1	=0; //user values: 0,1
parameter FIXED_SLAVE0_ADDR_VALUE_1	=0; //user values: 6'b000000-6'b111111
parameter ADD_SLAVE1_ADDRESS_EN_1	=0; //user values: 0,1
parameter FIXED_SLAVE1_ADDR_EN_1	=0; //user values: 0,1
parameter FIXED_SLAVE1_ADDR_VALUE_1	=0; //user values: 6'b000000-6'b111111
parameter I2C_NUM_1					=13;


// System Clock cycle (in ns)
parameter SYS_CLK_CYCLE	= 50;
//to acheive roughly 100 kbps speed, either approximate with the 7
//clock division values (cr210 bits in CON reg), or use a BCLK input
//to match exactly.
//using the cr210 bit values:
// 	x = Fpclk / 100khz;  x -> 200, choose cr210 = 192 ~ 104kbps
parameter cr210 = 3'b010; //divide by 192 value
parameter ens1  = 1'b1;
parameter sta   = 1'b1;
parameter sto   = 1'b1;
parameter si    = 1'b1;
parameter aa    = 1'b1;
parameter R_nW	= 1'b1;

parameter I0_adr= 7'h59;
parameter I1_adr0= 7'h60;
parameter I1_adr1= 7'h61;
parameter GC	= 1'b1;

//Generated Spike Width In Clock Cycles:
parameter SPIKE_CYCLE_WIDTH = 0;  //user values: 0-16

// required data values for testing:
//parameter [APB_DWIDTH-1:0] 	PERIOD_DATA = 2**APB_DWIDTH-3;
//parameter [16:1] 			ENABLE_DATA = 2**x-1;

// Misc TB parameters
parameter APB_DWIDTH 	= 8;
parameter TIMEOUT		= 3*(2**APB_DWIDTH);

//3 *2**16) * (2**16));
//parameter [19:0] TIMEOUT	= 393216;

// DUT signal declarations
reg						PCLK;
reg						PRESETN;
reg						PSEL_0;
reg						PSEL_1;
reg						PENABLE;
reg						PWRITE;
reg	 [8:0]				PADDR;
reg	 [APB_DWIDTH-1:0]	PWDATA;
wire [APB_DWIDTH-1:0]	PRDATA_0, PRDATA_1;
wire					INT_0, SMBA_INT_0, SMBS_INT_0; 
wire [I2C_NUM_1-1:0]    INT_1, SMBA_INT_1, SMBS_INT_1;
reg						BCLK;

// I2C serial bus signals
wire scl, SCLI_0, SCLO_0; 
wire [I2C_NUM_1-1:0] SCLI_1, SCLO_1;
wire sda, SDAI_0, SDAO_0;
wire [I2C_NUM_1-1:0] SDAI_1, SDAO_1;
// optional SMBus signals
wire SMBALERT_NO_0;
wire [I2C_NUM_1-1:0] SMBALERT_NO_1;
wire SMBALERT_NI_0;
wire [I2C_NUM_1-1:0] SMBALERT_NI_1;
wire SMBALERT_N;
wire SMBSUS_NO_0;
wire [I2C_NUM_1-1:0] SMBSUS_NO_1;
//wire SMBSUS_NI_0;
//wire SMBSUS_NI_1;


// I2C / SMBALERT open drain configuration
pullup   (sda);
pullup   (scl);
pullup   (SMBALERT_N);
assign scl = (SCLO_0 == 1'b0) ? 1'b0 : 1'bz ;
assign scl = (SCLO_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0) ? 1'b0 : 1'bz ;
assign SCLI_0 = scl;
assign SCLI_1[I2C_NUM_1-1:I2C_NUM_1-1] = scl;
assign sda = (SDAO_0 == 1'b0) ? 1'b0 : 1'bz ;
assign sda = (SDAO_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0) ? 1'b0 : 1'bz ;
assign SDAI_0 = sda;
assign SDAI_1[I2C_NUM_1-1:I2C_NUM_1-1] = sda;
assign SMBALERT_N = (SMBALERT_NO_0 == 1'b0) ? 1'b0 : 1'bz ;
assign SMBALERT_N = (SMBALERT_NO_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0) ? 1'b0 : 1'bz ;
assign SMBALERT_NI_0 = SMBALERT_N;
assign SMBALERT_NI_1[I2C_NUM_1-1:I2C_NUM_1-1] = SMBALERT_N;


// other signal declarations
integer			cyc;
integer			simerrors;
integer			count_high, count_low;
integer 		real_error;

// string related signals
reg [8*79:1]	init_str_mem [0:11];
reg [8*79:1]	dash_str,uline_str,copyright_str,tb_name_str,
				tb_ver_str,pound_str,lsb_str,msb_str;
reg [7:0]		sum;
reg [7:0]		sum_count;

// initialize strings
initial
begin: init_strings

dash_str		=
"-----------------------------------------------------------------------------";
uline_str		=
"_____________________________________________________________________________";
pound_str		=
"#############################################################################";
copyright_str	=
"(c) Copyright 2009 Actel Corporation. All rights reserved.";
tb_name_str		=
"Testbench for: CoreI2C (Two Instance Master/Slave Bus Configuration)";
tb_ver_str		=
"Version: 6.0 August 24th, 2009";

// initialization of testbench string
init_str_mem[00]	= "";
init_str_mem[01]	= "";
init_str_mem[02]	= uline_str;
init_str_mem[03]	= "";
init_str_mem[04]	= copyright_str;
init_str_mem[05]	= "";
init_str_mem[06]	= tb_name_str;
init_str_mem[07]	= tb_ver_str;
init_str_mem[08]	= uline_str;
init_str_mem[09]	= "";
init_str_mem[10]	= "";
init_str_mem[11]	= "";

lsb_str				= "LSB";
msb_str				= "MSB";
end


//-------------------------------------------------------------------

// generate the system clock
initial cyc	= SYS_CLK_CYCLE;
initial PCLK = 0;
always #(cyc/2) PCLK = ~PCLK;
always #(cyc*20000)
 begin
  if ($time > 50000000)
  begin
	$display("\n*** Error: Timed Out Waiting For Change at %t.  \n\tSpike Cycle Width Value May Be Too High, or Test Bench Configuration Wrong...\n", $time);
    $stop;
  end
 end

   //i2c unit 0
COREI2C #(
	.FAMILY         			(FAMILY_0         		  ),
	.OPERATING_MODE 			(OPERATING_MODE_0 		  ),
	.BAUD_RATE_FIXED			(BAUD_RATE_FIXED_0		  ),
	.BAUD_RATE_VALUE			(BAUD_RATE_VALUE_0		  ),
	.BCLK_ENABLED				(BCLK_ENABLED_0			  ),
	.GLITCHREG_NUM				(GLITCHREG_NUM_0		  ),
	.SMB_EN         			(SMB_EN_0         		  ),
	.IPMI_EN					(IPMI_EN_0				  ),
	.FREQUENCY      			(FREQUENCY_0      		  ),
	.FIXED_SLAVE0_ADDR_EN		(FIXED_SLAVE0_ADDR_EN_0   ),
	.FIXED_SLAVE0_ADDR_VALUE	(FIXED_SLAVE0_ADDR_VALUE_0),
	.ADD_SLAVE1_ADDRESS_EN		(ADD_SLAVE1_ADDRESS_EN_0  ),
	.FIXED_SLAVE1_ADDR_EN		(FIXED_SLAVE1_ADDR_EN_0   ),
	.FIXED_SLAVE1_ADDR_VALUE	(FIXED_SLAVE1_ADDR_VALUE_0),
	.I2C_NUM					(I2C_NUM_0				  )
    ) ui2c0
	(
	.PCLK   		(PCLK),
	.PRESETN		(PRESETN),
	.BCLK   		(BCLK),
	.SCLI      		(SCLI_0),
	.SDAI      		(SDAI_0),
	.SCLO      		(SCLO_0),
	.SDAO      		(SDAO_0),
	.INT          	(INT_0),
	.PWDATA       	(PWDATA),
	.PRDATA       	(PRDATA_0),
	.PADDR        	(PADDR),
	.PSEL         	(PSEL_0),
	.PENABLE      	(PENABLE),
	.PWRITE       	(PWRITE),
	.SMBALERT_NI  	(SMBALERT_NI_0),
	.SMBALERT_NO  	(SMBALERT_NO_0),
	.SMBA_INT 		(SMBA_INT_0),
	.SMBSUS_NI    	(SMBSUS_NO_1[I2C_NUM_1-1:I2C_NUM_1-1]),   //input gets output of instance1
	.SMBSUS_NO    	(SMBSUS_NO_0),
	.SMBS_INT		(SMBS_INT_0)
	);

//i2c unit 1 -- default configured in 13-channel mode,
// using the last channel
COREI2C #(
	.FAMILY         			(FAMILY_1         		  ),
	.OPERATING_MODE 			(OPERATING_MODE_1 		  ),
	.BAUD_RATE_FIXED			(BAUD_RATE_FIXED_1		  ),
	.BAUD_RATE_VALUE			(BAUD_RATE_VALUE_1		  ),
	.BCLK_ENABLED				(BCLK_ENABLED_1			  ),
	.GLITCHREG_NUM				(GLITCHREG_NUM_1		  ),
	.SMB_EN         			(SMB_EN_1         		  ),
	.IPMI_EN					(IPMI_EN_1				  ),
	.FREQUENCY      			(FREQUENCY_1      		  ),
	.FIXED_SLAVE0_ADDR_EN		(FIXED_SLAVE0_ADDR_EN_1   ),
	.FIXED_SLAVE0_ADDR_VALUE	(FIXED_SLAVE0_ADDR_VALUE_1),
	.ADD_SLAVE1_ADDRESS_EN		(ADD_SLAVE1_ADDRESS_EN_1  ),
	.FIXED_SLAVE1_ADDR_EN		(FIXED_SLAVE1_ADDR_EN_1   ),
	.FIXED_SLAVE1_ADDR_VALUE	(FIXED_SLAVE1_ADDR_VALUE_1),
	.I2C_NUM					(I2C_NUM_1				  )
	) ui2c1
	(
	.PCLK   		(PCLK),
	.PRESETN		(PRESETN),
	.BCLK   		(BCLK),
	.SCLI      		(SCLI_1),
	.SDAI      		(SDAI_1),
	.SCLO      		(SCLO_1),
	.SDAO      		(SDAO_1),
	.INT          	(INT_1),
	.PWDATA       	(PWDATA),
	.PRDATA       	(PRDATA_1),
	.PADDR        	(PADDR),
	.PSEL         	(PSEL_1),
	.PENABLE      	(PENABLE),
	.PWRITE       	(PWRITE),
	.SMBALERT_NI  	(SMBALERT_NI_1),
	.SMBALERT_NO  	(SMBALERT_NO_1),
	.SMBA_INT 		(SMBA_INT_1),
	.SMBSUS_NI    	({SMBSUS_NO_0, {12{1'b1}}}),   //input gets output of instance0
	.SMBSUS_NO    	(SMBSUS_NO_1),
	.SMBS_INT		(SMBS_INT_1)
	);

//spike insertion
i2c_spk #(
	.SPIKE_CYCLE_WIDTH (SPIKE_CYCLE_WIDTH)
	)
	uspk (
	.PCLK(PCLK),
	.PRESETN(PRESETN),
	.scl(scl),
	.sda(sda));


// Primary stimuli
initial
begin: testing
integer i,j,k,l,t;

reg	[8*79:1]	lmsb_str;

$timeformat(-9, 2, " ns", 3);

i			= 0;
j			= 0;
k			= 0;
l			= 0;
t			= 0;
simerrors	= 0;
sum         = 8'b0;
sum_count   = 8'b0;
count_high	= 0;
count_low	= 0;
real_error  = 0;

// print out copyright info, testbench version, name of testbench, etc.
for (i=0;i<12;i=i+1)
begin
	$display("%0s",init_str_mem[i]);
end

	// initialize signals
	PRESETN			= 0;
	PSEL_0			= 0;
	PSEL_1			= 0;
	PWDATA			= 0;
	PADDR			= 0;
	PWRITE			= 0;
	PENABLE			= 0;
	BCLK			= 0;


// synch to falling edge of clock
//		@ (negedge sysclk);
// synch to rising edge of clock
@ (posedge PCLK);

#(cyc * 2);
PRESETN			= 1;
#(cyc * 2);

//cpu_wr syntax:  cpu_wr(Instance#, Address, Write Data)
//cpu_rd syntax:  cpu_rd(Instance#, Address, Expected Value)


$display("\nCheck Initial Register Values:");
cpu_rd(0, serCON_ID ,  serCON_RV);
cpu_rd(0, serSTA_ID ,  serSTA_RV);
cpu_rd(0, serDAT_ID ,  serDAT_RV);
cpu_rd(0, serADR0_ID,  serADR0_RV);
if (SMB_EN_0 == 1)
begin
cpu_rd(0, serSMB_ID ,  serSMB_RV);
end
cpu_rd(0, serADR1_ID,  serADR1_RV);
cpu_rd(1, serCON_ID ,  serCON_RV);
cpu_rd(1, serSTA_ID ,  serSTA_RV);
cpu_rd(1, serDAT_ID ,  serDAT_RV);

if (FIXED_SLAVE0_ADDR_EN_1 == 1)
begin
cpu_rd(1, serADR0_ID ,  {FIXED_SLAVE0_ADDR_VALUE_1,1'b0});
end
else
begin
cpu_rd(1, serADR0_ID,  serADR0_RV);
end


if (IPMI_EN_1 == 1)
begin
cpu_rd(1, serSMB_ID ,  8'b0); //IPMI mode reset value
end
else if (SMB_EN_1 == 1)
begin
cpu_rd(1, serSMB_ID ,  serSMB_RV); //SMBus mode reset value
end

if ((FIXED_SLAVE1_ADDR_EN_1 == 1) && (ADD_SLAVE1_ADDRESS_EN_1 == 1))
begin
cpu_rd(1, serADR1_ID ,  {FIXED_SLAVE1_ADDR_VALUE_1,1'b0});
end
else
begin
cpu_rd(1, serADR1_ID,  serADR1_RV);
end

$display("\nEnable and Configure Addresses:");
cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
cpu_rd(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
cpu_rd(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});

cpu_wr(0, serADR0_ID, {I0_adr, ~GC});
//cpu_rd(0, serADR0_ID, {I0_adr, ~GC});
if (FIXED_SLAVE0_ADDR_EN_1 != 1)
begin
cpu_wr(1, serADR0_ID, {I1_adr0, ~GC});
//cpu_rd(1, serADR0_ID, {I1_adr0, ~GC});
end
if (FIXED_SLAVE0_ADDR_EN_1 == 1)
begin
//cpu_wr(1, serADR0_ID, {I1_adr0, ~GC});
//cpu_rd(1, serADR0_ID, {FIXED_SLAVE0_ADDR_VALUE_1[6:0], ~GC});
end
if ((FIXED_SLAVE1_ADDR_EN_1 != 1) && (ADD_SLAVE1_ADDRESS_EN_1 == 1))
begin
cpu_wr(1, serADR1_ID, {I1_adr1, ~GC});
//cpu_rd(1, serADR1_ID, {I1_adr1, ~GC});
end
if ((FIXED_SLAVE1_ADDR_EN_1 == 1) && (ADD_SLAVE1_ADDRESS_EN_1 == 1))
begin
//cpu_rd(1, serADR1_ID, {FIXED_SLAVE1_ADDR_VALUE_1[6:0], ~GC});
end


//first 8-bits to serDAT = Instance1 slave address value and R_nW bit.
if (FIXED_SLAVE0_ADDR_EN_1 == 1)
begin
cpu_wr(0,  serDAT_ID, {FIXED_SLAVE0_ADDR_VALUE_1[6:0], ~R_nW});
cpu_rd(0,  serDAT_ID, {FIXED_SLAVE0_ADDR_VALUE_1[6:0], ~R_nW});
end
if (FIXED_SLAVE0_ADDR_EN_1 == 0)
begin
cpu_wr(0,  serDAT_ID, {I1_adr0, ~R_nW});
//cpu_rd(0,  serDAT_ID, {I1_adr0, ~R_nW});
end

$display("\nInstance 0 MASTER:");
$display("\tSEND START BIT: Wait For Interrupt...");
cpu_wr(0,  serCON_ID, {cr210[2], ens1, sta, ~sto, ~si, aa, cr210[1:0]});
while (INT_0 == 1'b0)
#(cyc*1);
$display("\nInstance 0 MASTER:");
$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Start Bit Has Been Sent (08)...");
cpu_rd(0,  serSTA_ID, 8'h08);
$display("\tCLEAR INTERRUPT:  Triggering Transmission of Instance1 SLAVE Write Request:");
cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
while (INT_0 == 1'b0)
#(cyc*1);
$display("\nInstance 0 MASTER:");
$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Instance0 Slave has been Addressed and ACK Returned (18)...");
cpu_rd(0,  serSTA_ID, 8'h18);
$display("\tWRITE DATA REGISTER:  Data Register contains byte to be Transmitted to Instance1 Slave...");
cpu_wr(0,  serDAT_ID, 8'hAE);
cpu_rd(0,  serDAT_ID, 8'hAE);
$display("\tCLEAR INTERRUPT:  Triggering Transmission of 8-bit data to Instance1 WHEN Instance1 is Ready:");
cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});

$display("\nInstance 1 SLAVE:");
$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that it has been Addressed for Writing to (60)...");
while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
#(cyc*1);
cpu_rd(1,  serSTA_ID, 8'h60);
if (FIXED_SLAVE0_ADDR_EN_1 == 1)
begin
cpu_rd(1,  serDAT_ID, {FIXED_SLAVE0_ADDR_VALUE_1[6:0], ~GC});
end
if (FIXED_SLAVE0_ADDR_EN_1 == 0)
begin
cpu_rd(1,  serDAT_ID, {I1_adr0, ~GC});
end

$display("\tCLEAR INTERRUPT:  Triggering Transmission of 8-bit data from Instance0 now that Instance1 is Ready:");
cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});

$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that 8-bits of Data has been Received (80)...");
while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
#(cyc*1);
cpu_rd(1,  serSTA_ID, 8'h80);
$display("\tREAD DATA REGISTER:  Check the 8-bits of Received Data...");
cpu_rd(1,  serDAT_ID, 8'hAE);
$display("\tCLEAR INTERRUPT:  Go to IDLE State:");
cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});


while (INT_0 == 1'b0)
#(cyc*1);
$display("\nInstance 0 MASTER:");
$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Data has been Sent (28):");
cpu_rd(0,  serSTA_ID, 8'h28);
$display("\tCLEAR INTERRUPT AND SEND STOP BIT:  Go to IDLE State:");
cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, sto, ~si, aa, cr210[1:0]});
$display("\tREAD STATUS REGISTER:  Check that IDLE State has been Reached (F8)...");
cpu_rd(0,  serSTA_ID, 8'hF8);

$display("\nInstance 1 SLAVE:");
$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Stop Condition has been Detected (A0)...");
while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
#(cyc*1);
cpu_rd(1,  serSTA_ID, 8'ha0);
$display("\tCLEAR INTERRUPT:  Go to IDLE State:");
cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
$display("\tREAD STATUS REGISTER:  Check that IDLE State has been Reached (F8)...");
cpu_rd(1,  serSTA_ID, 8'hF8);

#(cyc*500);

if ((IPMI_EN_1 == 1) || (SMB_EN_1 == 1))
begin
  $display("\nEnabling SMBus or IPMI...");
  cpu_wr(0,  serSMB_ID, 8'b10000111);
  cpu_wr(1,  serSMB_ID, 8'b00000111);
  if (IPMI_EN_1 == 1)
  begin
  cpu_rd(1,  serSMB_ID, 8'b00000100);
  end
  else if (SMB_EN_1 == 1)
  begin
  cpu_rd(0,  serSMB_ID, 8'b10000111);
  cpu_rd(1,  serSMB_ID, 8'b00000111);
  while (SMBA_INT_0 == 1'b0)
	#(cyc*1);
  while (SMBA_INT_1 == 1'b0)
	#(cyc*1);
  while (SMBS_INT_0 == 1'b0)
	#(cyc*1);
  while (SMBS_INT_1 == 1'b0)
	#(cyc*1);
  cpu_wr(0,  serSMB_ID, 8'b11111111);
  cpu_wr(1,  serSMB_ID, 8'b01111111);
  cpu_rd(0,  serSMB_ID, 8'b11111111);
  cpu_rd(1,  serSMB_ID, 8'b01111111);
  while (SMBA_INT_0 == 1'b1)
	#(cyc*1);
  while (SMBA_INT_1 == 1'b1)
	#(cyc*1);
  while (SMBS_INT_0 == 1'b1)
	#(cyc*1);
  while (SMBS_INT_1 == 1'b1)
	#(cyc*1);
  end

  $display("\tChecking Master Resetting Status...and Clear Interrupt");
  cpu_rd(0,  serSTA_ID, 8'hd0);
  cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});

  while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
  #(cyc*1);
  if (IPMI_EN_1 == 1)
  begin
  $display("\n\tTime Check: %t --> Using default TB values, time should be slightly greater than 3 ms for IPMI mode of Instance1\n", $time);
  cpu_rd(1,  serSTA_ID, 8'hd8);
  end
  else if (SMB_EN_1 == 1)
  begin
  $display("\n\tTime Check: %t --> Using default TB values, time should be slightly greater than 25 ms for SMBus mode of Instance1\n", $time);
  cpu_rd(1,  serSTA_ID, 8'hd8);
  end

  $display("\nWait while INSTANCE0 SMBus Master holds SCL low for 35ms, automatically resetting INSTANCE1 SLAVE...");
  while (INT_0 == 1'b0)
  #(cyc*1);
  $display("\tCheck Error Status has gone to Idle...");
  cpu_rd(0,  serSTA_ID, 8'hf8);
  cpu_rd(1,  serSTA_ID, 8'hd8);
  $display("\tClear Interrupts...");
  cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
  cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
  $display("\tCheck Idle Status...");
  cpu_rd(0,  serSTA_ID, 8'hf8);
  cpu_rd(1,  serSTA_ID, 8'hf8);
end

////////// Check 2nd Address Capability /////////////////

if (ADD_SLAVE1_ADDRESS_EN_1 == 1)
begin
	$display("\n\n\nChecking 2nd Address Capability:");
	cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
	//first 8-bits = Instance1 slave address value and R_nW bit.
	if (FIXED_SLAVE1_ADDR_EN_1 == 1)
	begin
	cpu_wr(1, serADR1_ID, 8'h01); // enable 2nd address check
	cpu_rd(1, serADR1_ID, {FIXED_SLAVE1_ADDR_VALUE_1[6:0], 1'b1});  // 1'b1 = 2nd address decode enabled.
	cpu_wr(0,  serDAT_ID, {FIXED_SLAVE1_ADDR_VALUE_1[6:0], ~R_nW});
	cpu_rd(0,  serDAT_ID, {FIXED_SLAVE1_ADDR_VALUE_1[6:0], ~R_nW});
	end
	if (FIXED_SLAVE1_ADDR_EN_1 == 0)
	begin
	cpu_wr(0,  serDAT_ID, {I1_adr1, ~R_nW});
	cpu_rd(0,  serDAT_ID, {I1_adr1, ~R_nW});
	end

	$display("\nInstance 0 MASTER:");
	$display("\tSEND START BIT: Wait For Interrupt...");
	cpu_wr(0,  serCON_ID, {cr210[2], ens1, sta, ~sto, ~si, aa, cr210[1:0]});
							$display("\n\tTime Check: %t DEBUG1\n", $time);
	while (INT_0 == 1'b0)
	#(cyc*1);

	$display("\nInstance 0 MASTER:");
	$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Start Bit Has Been Sent (08)...");
	cpu_rd(0,  serSTA_ID, 8'h08);
	$display("\tCLEAR INTERRUPT:  Triggering Transmission of Instance1 SLAVE Write Request:");
	cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
	while (INT_0 == 1'b0)
	#(cyc*1);
	$display("\nInstance 0 MASTER:");
	$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Instance0 Slave has been Addressed and ACK Returned (18)...");
	cpu_rd(0,  serSTA_ID, 8'h18);
	$display("\tWRITE DATA REGISTER:  Data Register contains byte to be Transmitted to Instance1 Slave...");
	cpu_wr(0,  serDAT_ID, 8'hAE);
	cpu_rd(0,  serDAT_ID, 8'hAE);
	$display("\tCLEAR INTERRUPT:  Triggering Transmission of 8-bit data to Instance1 WHEN Instance1 is Ready:");
	cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});

	$display("\nInstance 1 SLAVE:");
	$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that it has been Addressed for Writing to (60)...");
	while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
	#(cyc*1);
	cpu_rd(1,  serSTA_ID, 8'h60);
	if (FIXED_SLAVE1_ADDR_EN_1 == 1)
	begin
	cpu_rd(1,  serDAT_ID, {FIXED_SLAVE1_ADDR_VALUE_1[6:0], ~GC});
	end
	if (FIXED_SLAVE0_ADDR_EN_1 == 0)
	begin
	cpu_rd(1,  serDAT_ID, {I1_adr1, ~GC});
	end

	$display("\tCLEAR INTERRUPT:  Triggering Transmission of 8-bit data from Instance0 now that Instance1 is Ready:");
	cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});

	$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that 8-bits of Data has been Received (80)...");
	while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
	#(cyc*1);
	cpu_rd(1,  serSTA_ID, 8'h80);
	$display("\tREAD DATA REGISTER:  Check the 8-bits of Received Data...");
	cpu_rd(1,  serDAT_ID, 8'hAE);
	$display("\tCLEAR INTERRUPT:  Go to IDLE State:");
	cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});


	while (INT_0 == 1'b0)
	#(cyc*1);
	$display("\nInstance 0 MASTER:");
	$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Data has been Sent (28):");
	cpu_rd(0,  serSTA_ID, 8'h28);
	$display("\tCLEAR INTERRUPT AND SEND STOP BIT:  Go to IDLE State:");
	cpu_wr(0,  serCON_ID, {cr210[2], ens1, ~sta, sto, ~si, aa, cr210[1:0]});
	$display("\tREAD STATUS REGISTER:  Check that IDLE State has been Reached (F8)...");
	cpu_rd(0,  serSTA_ID, 8'hF8);

	$display("\nInstance 1 SLAVE:");
	$display("\tREAD STATUS REGISTER AFTER INTERRUPT:  Check that Stop Condition has been Detected (A0)...");
	while (INT_1[I2C_NUM_1-1:I2C_NUM_1-1] == 1'b0)
	#(cyc*1);
	cpu_rd(1,  serSTA_ID, 8'ha0);
	$display("\tCLEAR INTERRUPT:  Go to IDLE State:");
	cpu_wr(1,  serCON_ID, {cr210[2], ens1, ~sta, ~sto, ~si, aa, cr210[1:0]});
	$display("\tREAD STATUS REGISTER:  Check that IDLE State has been Reached (F8)...");
	cpu_rd(1,  serSTA_ID, 8'hF8);

	#(cyc*500);

end

// print out number of simulation errors (if any) at end of sim
$display(" ");
$display("%0s",pound_str);
$display("All tests for CoreI2C complete with %d Errors at time %t", simerrors, $time);
$display("%0s",pound_str);
$display(" ");
#(cyc * 1);
//	$finish; //this will prompt for closing MODELSIM window
  $stop;
#(100);
end


//----------------------------------------------------------------------
// tasks
//----------------------------------------------------------------------

// ----------- check the value of a signal or bus (up to 128 bits) ---------

task checksig;
input [127:0] d;
input [8*17:1] sig_name;
input [127:0] v;
begin
	$timeformat(-9, 2, " ns", 3);
	if (d != v)
	begin
		$display("");
		$display("%0s",pound_str);
		$display("ERROR!!! Mismatch on %0s",sig_name);
		$display("At time: %0t",$time);
		$display("Expected value was: 0b%0b, observed value is: 0b%0b",v,d);
//		$display("Expected value was: 0x%0x, observed value is: 0x%0x",v,d);
		$display("%0s",pound_str);
		$display("");
		simerrors = simerrors + 1;
 	    #(cyc * 1);
		$stop;
	end
end
endtask

//-------------------------------------------------------------------
// Emulate task of cpu writing data to peripheral (IP macro)
//-------------------------------------------------------------------
task cpu_wr;
input			sel;
input	[8:0]	addr;
input	[APB_DWIDTH-1:0]	d;
begin
	if (sel == 0)
	begin
	PSEL_0 	= 1;
	PSEL_1	= 0;
	PADDR	= {addr};
	end
	else
	begin
	PSEL_0	= 0;
	PSEL_1 	= 1;
	PADDR	= {I2C_NUM_1-1,addr[4:0]};
	end

	PWRITE	= 1;
	PENABLE	= 0;
	PWDATA	= d;
	#(cyc * 1);
	PENABLE	= 1;
	#(cyc * 1);
//	@ (posedge PCLK);
	@ (negedge PCLK);
	PSEL_0 	= 0;
	PSEL_1	= 0;
	PADDR	= 0;
	PWRITE	= 0;
	PENABLE	= 0;
	PADDR	= 0;
	PWDATA	= 0;
end
endtask

//-------------------------------------------------------------------
// Emulate task of cpu reading data from peripheral (IP macro)
//-------------------------------------------------------------------
task cpu_rd;
input			sel;
input	[8:0]	addr;
input	[APB_DWIDTH-1:0]	d;
begin
	if (sel == 0)
	begin
	PSEL_0 	= 1;
	PSEL_1	= 0;
	PADDR	= {addr};
	end
	else
	begin
	PSEL_0	= 0;
	PSEL_1 	= 1;
	PADDR	= {I2C_NUM_1-1,addr[4:0]};
	end
	PWRITE	= 0;
	PENABLE	= 0;
	#(cyc * 1);
	PENABLE	= 1;
	#(cyc * 1);

	@ (negedge PCLK);
	if (sel == 0)
	begin
	$display("\t\tInstance0 PSEL: PADDR = 0x%0x, Expected PRDATA_0 = 0x%0x",addr, d);
	checksig(PRDATA_0,"APB PRDATA_0",d);
	end
	else
	begin
	$display("\t\tInstance1 PSEL: PADDR = 0x%0x, Expected PRDATA_1 = 0x%0x",addr, d);
	checksig(PRDATA_1,"APB PRDATA_1",d);
	end
	PADDR	= 0;
	PWRITE	= 0;
	PSEL_0	= 0;
	PSEL_1	= 0;
	PENABLE	= 0;
	PADDR	= 0;
end
endtask

endmodule
