#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <m2sxxx.h>
#include "mss_timer.h"
#include "mss_pdma.h"
#include "mss_uart.h"
#include "mss_spi.h"
#include "mss_gpio.h"
#include "core_gpio.h"
#include "mpu6050.h"
#include "utils.h"
#include "nm.h"
#include "hdl.h"
#include "isr.h"
#include "dbg.h"

// See utils.c for info on these externs
extern int *mode;
extern int *status;
extern int *n0ack, *n0fft;
extern int *n1ack, *n1fft;

// debug globals
extern int *dbg_nm0_stim_cnt, *dbg_nm1_stim_cnt;

// GPIO fabric core handle
extern gpio_instance_t gpio_core_handle;

// Global flags set by ISRs and cleared in main loop
bool poll_tx_start = false;		// initiate an SPI poll when set
bool poll_rx_rdy = false;		// data is available from a poll
bool pdma_tx_start = false;		// time to initiate a PDMA frame Tx
bool pdma_rx_done = false;		// data is available from a PDMA frame
bool ack_rdy = false;			// the HDL has an ack ready for processing
bool fft_rdy = false;			// the HDL has an fft result ready for processing

// Poll buffers
static uint8_t poll_tx_buf[POLL_TX_BUF_SIZE];
static uint8_t poll_rx_buf[POLL_RX_BUF_SIZE];

// PDMA buffers
// PDMA Tx buf is internal to HDL
static uint8_t pdma_rx_buf[PDMA_RX_FRAME_SIZE];

static int stim_count = 0;
static bool rec_enable_write = false;
static int data_ack_req = 0x3;	// bit 0 is NM0, bit 1 is NM1

// Number of stim requests to send
static uint32_t stim_rep = 0;

// GUI command state
static bool stream_en = 0;
static bool artifact_en = 0; // whether we are doing artifact cancellation or not. Default not.

// Temporary debugging
static int dbg_rx_pdma_indx = 0;
static uint8_t dbg_rx_pdma_array[20][POLL_RX_BUF_SIZE+1];
static int dbg_bad_cmd = 0;

// Function prototypes
void SPI_poll_write_read(void);
void SPI_PDMA_write_read(void);
uint8_t *PDMA_find_command(void);
void SPI_read_check(uint8_t *cmd);
int sys_init(void);

int main()
{
	// Assert rstb in the HDL blocks
	SYSREG->SOFT_RST_CR |= SYSREG_FPGA_SOFTRESET_MASK;
	SYSREG->SOFT_RST_CR &= ~SYSREG_FPGA_SOFTRESET_MASK;

	// debug
	memset((char *) dbg_rx_pdma_array, 0, sizeof(dbg_rx_pdma_array));

	// Set debug channel for HDL debug_mux.v, To select, in dbg.h set DEBUG_SEL to one of the DEBUG_... #defines.
	dbg_set_channel();

//	set_system_mode(NM0_EMULATE_EN | NM1_EMULATE_EN);

    sys_init();

	// Enable or disable PDMA block, accelerometer IRQ, NM emulation, accelerometer emulation, or PDMA emulation
	set_system_mode(PDMA_EN | ACC_IRQ_EN);
//	set_system_mode(PDMA_EN | ACC_IRQ_EN | ARTIFACT_EN | FFT_EN | ACC_EMULATE_EN | NM0_EMULATE_EN | NM1_EMULATE_EN);

	// Select the channel for FFT. One channel can be selected for each NM.
	set_FFT_channel(0,9);
	set_FFT_channel(1,5);

	while(1)
	{
    	// DEBUG ONLY:  Emulates a stim for stim_cnt frames. Don't do it too often.
		// Works only if NM0_EMULATE_EN is set in the mode flags.
//        *dbg_nm0_stim_cnt = 4;

		//
		// If streaming is enabled SPI reads are a side-effect of ADC PDMA data transfers.
		// If streaming is not enabled SPI polls are done based on a timer.
		// Currently register read commands are ignored when streaming is enabled to avoid
		// conflicts between programmed I/O and PDMA on the SPI. Commands and register writes are allowed.
		//

		//
		// The following conditionals test the status of flags set by interrupt service routines in isr.c.
		// All SPI I/O and Tx/Rx buffering is done here.
		// A complete event-driven solution can be realized by putting the M3 to sleep pending an interrupt.
		//

		// The poll timer has expired so start a poll if streaming is off
		if (poll_tx_start && !stream_en) {
			poll_tx_start = false;
			poll_tx_buf[0] = 0;
   			SPI_poll_write_read();
   		}

		// A valid command from the GUI has been detected in a poll.
		if (poll_rx_rdy && !stream_en) {
			poll_rx_rdy = false;
			SPI_read_check(poll_rx_buf);
		}

		// The PDMA interrupt has occurred indicating an ADC frame is ready for transfer via SPI.
		// If streaming is enabled start Tx and Rx PDMA channels.
		if (pdma_tx_start && stream_en) {
			pdma_tx_start = false;
			SPI_PDMA_write_read();
		}

		// The PDMA Rx channel has completed a transfer.
		// If streaming is still enabled check the Rx channel for a command.
		if (pdma_rx_done && stream_en) {
			pdma_rx_done = false;
			SPI_read_check(PDMA_find_command());
		}

		// An ACK (register read) packet has been received by the HDL.
		// Either manage stims or forward the ACK to the GUI.
		if (ack_rdy && !stream_en) {
			uint32_t stat;
			uint32_t addr_n_data;
			uint16_t addr, data;
			bool ackok;

			ack_rdy = false;

			stat = *status;

        	if (stat & NM0_ACK_RDY_BIT)
			{
				addr_n_data = *n0ack;
				addr = (addr_n_data >> 16) & 0xffff;
				data = addr_n_data & 0xffff;

		        if (stim_rep > 0) // if we still have a stim train to start
				{
		        	ackok = (addr == 0x01);

		        	if (ackok & !(data & (1 << 15))) // previous stim ended, so start a new train
		        	{
		        		stim_rep--;
		        		sendNMcmd(NM0, 0x09);
		        		stim_count++;
		        		if (stim_rep > 0)
		        		{
		        			postNMregRead(NM0, 0x01);
		        		}
		        	}
		        	else
		        	{
		        		postNMregRead(NM0, 0x01);
		        	}
				}
		        else if (data_ack_req & 0x01) // not doing stim on NM0, so continue with register operations
				{
		   	 		poll_tx_buf[0] = 0xff;
		   	 		poll_tx_buf[1] = (char) ((addr_n_data >> 16) & 0xff);
		   	 		poll_tx_buf[2] = (char) ((addr_n_data >> 24) & 0xff);
		   	 		poll_tx_buf[3] = (char) ((addr_n_data >> 0) & 0xff);
		   	 		poll_tx_buf[4] = (char) ((addr_n_data >> 8) & 0xff);

		   	 		delay_us(100);	// The Nordic is sensitive to turnaround time so delay a little here to make sure it's ready

		   	 		SPI_poll_write_read();

		   			data_ack_req &= ~0x01;

					// debug only
//		   			dbg_record_nm_ack(addr_n_data);
				}
			}

            if (stat & NM1_ACK_RDY_BIT)
            {
				addr_n_data = *n1ack;
				addr = (addr_n_data >> 16) & 0xffff;
				data = addr_n_data & 0xffff;

		        if (stim_rep > 0) // if we still have a stim train to start
				{
		        	ackok = (addr == 0x01);

		        	if (ackok & !(data & (1 << 15))) // previous stim ended, so start a new train
		        	{
		        		stim_rep--;
		        		sendNMcmd(NM1, 0x09);
		        		stim_count++;
		        		if (stim_rep > 0)
		        		{
		        			postNMregRead(NM1, 0x01);
		        		}
		        	}
		        	else
		        	{
		        		postNMregRead(NM1, 0x01);
		        	}
				}
		        else if (data_ack_req & 0x02) // not doing stim on NM1, so continue with register operations
				{
		   	 		poll_tx_buf[0] = 0xff;
		   	 		poll_tx_buf[1] = (char) ((addr_n_data >> 16) & 0xff);
		   	 		poll_tx_buf[2] = (char) ((addr_n_data >> 24) & 0xff);
		   	 		poll_tx_buf[3] = (char) ((addr_n_data >> 0) & 0xff);
		   	 		poll_tx_buf[4] = (char) ((addr_n_data >> 8) & 0xff);

		   	 		delay_us(100);	// The Nordic is sensitive to turnaround time so delay a little here to make sure it's ready

		   	 		SPI_poll_write_read();

					data_ack_req &= ~0x02;

					// debug only
//		   			dbg_record_nm_ack(addr_n_data);
				}
            }
		}

		if (fft_rdy) {
			fft_rdy = false;

			uint32_t fftval;

			while (*status & NM0_FFT_RDY_BIT) {
				fftval = *n0fft;
			}
			while (*status & NM1_FFT_RDY_BIT) {
				fftval = *n1fft;
			}
        }
	}

	return 0;
}

//
// Writes poll_tx_buf to SPI (to GUI via Nordic) and receives command (if any) in poll_rx_buf
// Checks to see if anything interesting was returned in a SPI poll.
//
void SPI_poll_write_read(void)
{
	if (stream_en) return;	// assertion

	memset((char *) poll_rx_buf, 0, sizeof(poll_rx_buf));

	MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
 	MSS_SPI_transfer_block(&g_mss_spi0, poll_tx_buf, POLL_TX_BUF_SIZE, poll_rx_buf, POLL_RX_BUF_SIZE);
	MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);

	if (poll_rx_buf[0] == 0xAA) {
		poll_rx_rdy = true;
	}
}

//
// Starts Tx and Rx PDMA channels to/from the SPI (to GUI via Nordic)
// Command from the GUI will be in pdma_rx_buf when Rx transfer is complete
//
void SPI_PDMA_write_read(void)
{
	if (!stream_en) return;	// assertion

	memset((char *) pdma_rx_buf, 0, sizeof(pdma_rx_buf));

	MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
	MSS_SPI_disable(&g_mss_spi0);
	MSS_SPI_set_transfer_byte_count(&g_mss_spi0, PDMA_TX_FRAME_SIZE);	// can only be set with SPI disabled
	PDMA_start(PDMA_CHANNEL_0, REG_BASE+0x0008, PDMA_SPI0_TX_REGISTER, PDMA_TX_FRAME_SIZE);
	PDMA_start(PDMA_CHANNEL_1, PDMA_SPI0_RX_REGISTER, (uint32_t) pdma_rx_buf, PDMA_RX_FRAME_SIZE);
	MSS_SPI_enable(&g_mss_spi0);

	// Alternate method, from mss_spi.h
/*    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, 0, 0, 0, 0);
    PDMA_start(PDMA_CHANNEL_0, REG_BASE+0x0008, PDMA_SPI0_TX_REGISTER, PDMA_TX_FRAME_SIZE);
    PDMA_start(PDMA_CHANNEL_1, PDMA_SPI0_RX_REGISTER, (uint32_t) pdma_rx_buf, PDMA_RX_FRAME_SIZE);
    while (PDMA_status(PDMA_CHANNEL_1) == 0);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
*/
}

//
// Find the start of a GUI command in pdma_rx_buf.
// For whatever reason the commands do not always start in the same place so this ensures that the header byte is correctly identified.
// Also records commands for debugging.
//
uint8_t *PDMA_find_command(void)
{
    int  i;

    for (i = 0; i < sizeof(dbg_rx_pdma_array); i++) {
       	if (pdma_rx_buf[i] == 0xAA) {
       		if (dbg_rx_pdma_indx < 20) {
       			dbg_rx_pdma_array[dbg_rx_pdma_indx][0] = i;
       			memcpy((char *) &(dbg_rx_pdma_array[dbg_rx_pdma_indx++][1]), (char *) &pdma_rx_buf[i], 6);
       		} else {
       			dbg_rx_pdma_indx = dbg_rx_pdma_indx;	// line for breakpoint
       		}
       		break;
       	}
    }

    if (i == sizeof(dbg_rx_pdma_array)) {
       	return NULL;
    }

	return &pdma_rx_buf[i];
}

//
// A valid GUI command should be in rx_buf.
// Parse rx_buf and execute the command.
//
void SPI_read_check(uint8_t *rx_buf)
{
   	bool stream_on = 0, stream_off = 0, artifact_on = 0, artifact_off = 0;
   	int stim_req = 0, stim_nm0 = 0, stim_nm1 = 0;

   	// Sanity check
   	if (rx_buf[0] != 0xAA) {
   		++dbg_bad_cmd;
   	}

	if (rx_buf[1] == 0xFF)
	{
	    // The command is a local state change
        stim_rep      = (rx_buf[2] << 8) | rx_buf[3];
        data_ack_req  =  rx_buf[4]       & 0x3;
        stim_nm0      = (rx_buf[4] >> 3) & 0x01;
        stim_nm1      = (rx_buf[4] >> 4) & 0x01;
        stim_req      = (rx_buf[4] >> 5) & 0x1;
        artifact_off  = (rx_buf[4] >> 6) & 0x1;
        artifact_on   = (rx_buf[4] >> 7) & 0x1;
        stream_off    = (rx_buf[5] >> 4) & 0x1;
        stream_on     = (rx_buf[5] >> 5) & 0x1;

        if (stream_on && !stream_en)
        {
           	*mode = (*mode) | PDMA_EN;
            stream_en = 1;
//            MSS_TIM1_stop();		// don't need the poll timer in streaming mode
        }
        if (stream_off && stream_en)
        {
           	*mode = (*mode) & ~PDMA_EN;
           	stream_en = 0;
//           	poll_tx_start = false;	// make sure we don't execute a poll immediately
//           	MSS_TIM1_start();		// restart the poll timer
        }

        if (artifact_on && !artifact_en)
        {
           	*mode = (*mode) | ARTIFACT_EN;
            artifact_en = 1;
        }
        if (artifact_off && artifact_en)
        {
           	*mode = (*mode) & ~ARTIFACT_EN;
            artifact_en = 0;
        }

        if (stim_req)
        {
            if (stim_nm0)
            {
            	sendNMcmd(NM0, 0x09 | (1 << 10));
               	stim_count++;
                if (stim_rep > 0)
                {
                	postNMregRead(NM0, 0x01);
                }
            }
            else if (stim_nm1)
            {
            	sendNMcmd(NM1, 0x09 | (1 << 10));
               	stim_count++;
                if (stim_rep > 0)
                {
      				postNMregRead(NM1, 0x01);
                }
            }
        }
	}

	else if ((unsigned char) rx_buf[1] <= 0x4f)
	{
		// The message is an NM command or a read/write of an NM or HDL register.
		// The HDL target register address is in rx_buf[1]. The payload in rx_buf[5:2] is either an HDL register value or an NM register address and data.
		// See Mario-CM M3 code documentation.pptx for the address map.

		int reg_val;
		uint16_t reg_addr, reg_data;

		reg_val = rx_buf[5] + ((uint32_t)rx_buf[4] << 8) + ((uint32_t)rx_buf[3] << 16) + ((uint32_t)rx_buf[2] << 24);
		*(int*)(REG_BASE+rx_buf[1]) = reg_val;
		while((*status) & (NM0_TX_BUSY_BIT | NM1_TX_BUSY_BIT));

		reg_addr = (reg_val >> 16) & 0xFFFF;
		reg_data = reg_val & 0xFFFF;

		// If we are writing to one of the record enable registers we need to update the vectors
		// both in the M3 and HDL to support hardware vector compression.
		// Currently register operations consist of exactly four commands:
		//		1) HDL d1 register write
		//		2) HDL d2 register write
		//		3) HDL command register write, initiates Tx of d1 and d2 to selected NM.
		//		4) set local enable ACK return flag

		// The previous command was a d1 HDL register write (indicating type of op, either write or read).
		// If it was a write rec_enable_write will be set.
		if (rec_enable_write)
		{
			rec_enable_write = false;

			// If this command is for the NM0 d2 HDL register, then update NM0 vectors
			if (rx_buf[1] == 0x14)
			{
				update_ADC_vectors(0, reg_addr, reg_data);
			}
			// If this command is for the NM1 d2 HDL register, then update NM1 vectors
			else if (rx_buf[1] == 0x24)
			{
				update_ADC_vectors(1, reg_addr, reg_data);
			}
		}

		// If this command is an HDL d1 register write...
		if (((rx_buf[1] == 0x10) || (rx_buf[1] == 0x20)) && (reg_data == 1))
		{
			// The next command will be a d2 HDL register write.
			rec_enable_write = true;
		}
	}
}

//
// Initialize and configure MSS peripherals and core blocks
//
int sys_init(void)
{
	gpio_init();

	// Initialize SPI_0
	MSS_SPI_init(&g_mss_spi0);
	MSS_SPI_configure_master_mode(&g_mss_spi0,
			MSS_SPI_SLAVE_0,
			MSS_SPI_MODE0,
//			12u, // changed to 12 so that we get 2.5MHz from the new 30MHz apb clock
			8u, // 20MHz/8 = 2.5MHz clock (max nordic is 8MHz)
//			6u,
//			4u, // seems to work best with PDMA on eval board but does not work with Nordic - FLB
			MSS_SPI_BLOCK_TRANSFER_FRAME_SIZE	 //needed for transmitting in blocks
	);

	// Initialize timer for polling when PDMA is disabled
	MSS_TIM1_init(MSS_TIMER_PERIODIC_MODE);
 	MSS_TIM1_load_background(GUI_POLL_DELAY_IDLE);
	MSS_TIM1_enable_irq();
 	MSS_TIM1_start();

	// Initialize PDMA channels
	PDMA_init();
	PDMA_configure(PDMA_CHANNEL_0, PDMA_TO_SPI_0,   PDMA_LOW_PRIORITY  | PDMA_BYTE_TRANSFER | PDMA_NO_INC,            PDMA_DEFAULT_WRITE_ADJ);
	PDMA_configure(PDMA_CHANNEL_1, PDMA_FROM_SPI_0, PDMA_HIGH_PRIORITY | PDMA_BYTE_TRANSFER | PDMA_INC_DEST_ONE_BYTE, PDMA_DEFAULT_WRITE_ADJ);
	PDMA_set_irq_handler(PDMA_CHANNEL_0, PDMA_0_isr);
	PDMA_set_irq_handler(PDMA_CHANNEL_1, PDMA_1_isr);

	// Initialize accelerometer and test
	// Sometimes initialization fails if code restarted without power cycle
    int retval = MPU6050_init();
    if (retval < 0) {
    	while(1);	// assertion
    }

	// Turn on rec_en for both NMs
	writeNMreg(NM0, NM_REC_CONFIG_REG, 0x3884);
	writeNMreg(NM1, NM_REC_CONFIG_REG, 0x3884);

	// Change LV charge pumps from 3:1 to 2:1 for both NMs
	writeNMreg(NM0, NM_PWR_CONFIG_REG, 0x0001); //change NM0 LV charge pump from 3:1 to 2:1
	writeNMreg(NM1, NM_PWR_CONFIG_REG, 0x0001); //change NM1 LV charge pump from 3:1 to 2:1

	// Program NM channel enable registers.
	// Side effect is to initialize ADC vectors in HDL ADC data path
	init_ADC_vectors();

	// Enable recording bias current to go to the stimulator
	writeNMreg(NM0, NM_SYS_CONFIG_REG, 0x4000);
	writeNMreg(NM1, NM_SYS_CONFIG_REG, 0x4000);

	// The CoreGPIO block intercepts the PDMA ready signal from the CMAM block and generates an interrupt on MSS GPIO[5].
	// CoreGPIO and MSS GPIOs are completely independent.
	MSS_GPIO_enable_irq(MSS_GPIO_5);
	GPIO_enable_irq(&gpio_core_handle, GPIO_0);

	// ACK ready
	MSS_GPIO_enable_irq(MSS_GPIO_6);
	GPIO_enable_irq(&gpio_core_handle, GPIO_1);

	// FFT ready
	MSS_GPIO_enable_irq(MSS_GPIO_7);
	GPIO_enable_irq(&gpio_core_handle, GPIO_2);

	// ACC FIFO overflow
	// If the accelerometer FIFO gets out of sync it may overflow.
	// Take action to either reset the FIFO (doesn't always work) or read all data.
//	MSS_GPIO_enable_irq(MSS_GPIO_8);
//	GPIO_enable_irq(&gpio_core_handle, GPIO_3);

	PDMA_enable_irq(0);
	PDMA_enable_irq(1);

	return 0;
}

