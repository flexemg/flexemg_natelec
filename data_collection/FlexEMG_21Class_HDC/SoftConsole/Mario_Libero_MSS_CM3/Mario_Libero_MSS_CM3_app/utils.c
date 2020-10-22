/*
 * utils.c
 *
 *  Created on: Jun 22, 2017
 *      Author: flb
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <m2sxxx.h>
#include "mss_gpio.h"
#include "core_gpio.h"
#include "utils.h"
#include "hdl.h"
#include "nm.h"

// CoreGPIO Memory Map: 0x30010000 to 0x3001FFFF
#define CoreGPIO_REG_BASE 0x30010000

// HDL TxRx addresses
int *rst 	  = (int*)(REG_BASE+0x0004);	// Rx is readback
int *mode     = (int*)(REG_BASE+0x000c);	// System-wide mode
int *n0d1 	  = (int*)(REG_BASE+0x0010);	// NM0 operation (Rx is readback)
int *n0d2 	  = (int*)(REG_BASE+0x0014);	// NM0 register data and address or command (Rx readback)
int *n1d1 	  = (int*)(REG_BASE+0x0020);	// NM1 operation (Rx is readback)
int *n1d2 	  = (int*)(REG_BASE+0x0024);	// NM1 register data and address or command (Rx readback)

// HDL Tx only addresses
int *command  = (int*)(REG_BASE+0x0000);
int *dbgsel   = (int*)(REG_BASE+0x0008);
int *n0vechi  = (int*)(REG_BASE+0x0018);
int *n0veclo  = (int*)(REG_BASE+0x001c);
int *n1vechi  = (int*)(REG_BASE+0x0028);
int *n1veclo  = (int*)(REG_BASE+0x002c);

// HDL Rx only addresses
int *status   = (int*)(REG_BASE+0x0000);
int *pdma     = (int*)(REG_BASE+0x0008);	// PDMA FIFO data, debug only
int *n0ack 	  = (int*)(REG_BASE+0x0018);	// N0 ACK data
int *n0fft 	  = (int*)(REG_BASE+0x001c);	// N0 FFT data
int *n1ack 	  = (int*)(REG_BASE+0x0028);	// N1 ACK data
int *n1fft 	  = (int*)(REG_BASE+0x002c);	// N1 FFT data

// Stim injection (debug only)
int *dbg_nm0_stim_cnt = (int*)(REG_BASE+0x0100);
int *dbg_nm1_stim_cnt = (int*)(REG_BASE+0x0110);

// NM channel select masks
// Channels are represented by MSB to LSB bits e.g. NM0 channel 0 would be 0x8000 in the leftmost 16 bits for NM0.
uint16_t nm0_rec_enable_vector[4] = {NM0_VEC_63to48, NM0_VEC_47to32, NM0_VEC_31to16, NM0_VEC_15to0};		// NM0 channel enable vectors
uint16_t nm1_rec_enable_vector[4] = {NM1_VEC_63to48, NM1_VEC_47to32, NM1_VEC_31to16, NM1_VEC_15to0};		// NM1 channel enable vectors (31:0 not connected on PCB)

//Structures for HDL library core functions
gpio_instance_t gpio_core_handle;

void gpio_init(void)
{
	// Initialize and configure the MSS internal GPIO block as opposed to a library Core such as CoreGPIO (see below)
	// Used for direct-from-M3 debug output and HDL-to-M3 interrupts

	MSS_GPIO_init();

	MSS_GPIO_config(MSS_GPIO_0, MSS_GPIO_OUTPUT_MODE);
	MSS_GPIO_config(MSS_GPIO_1, MSS_GPIO_OUTPUT_MODE);
	MSS_GPIO_config(MSS_GPIO_2, MSS_GPIO_OUTPUT_MODE);
	MSS_GPIO_config(MSS_GPIO_3, MSS_GPIO_OUTPUT_MODE);
	MSS_GPIO_config(MSS_GPIO_4, MSS_GPIO_OUTPUT_MODE);	// ACC_CLKIN
	MSS_GPIO_config(MSS_GPIO_5, MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE);	// PDMA done interrupt
	MSS_GPIO_config(MSS_GPIO_6, MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE);	// ACK ready interrupt
	MSS_GPIO_config(MSS_GPIO_7, MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE);	// FFT ready interrupt
	MSS_GPIO_config(MSS_GPIO_8, MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE);	// Accelerometer FIFO overflow interrupt

	MSS_GPIO_set_output(MSS_GPIO_0, 0);
	MSS_GPIO_set_output(MSS_GPIO_1, 0);
	MSS_GPIO_set_output(MSS_GPIO_2, 0);
	MSS_GPIO_set_output(MSS_GPIO_3, 0);
	MSS_GPIO_set_output(MSS_GPIO_4, 0);

	// Initialize and configure CoreGPIO
    // This is a soft core from the HDL catalog as opposed to the MSS internal GPIO block (see above)
	// Used for HDL-to-M3 interrupt management
	GPIO_init(&gpio_core_handle, CoreGPIO_REG_BASE, GPIO_APB_32_BITS_BUS);
	GPIO_config(&gpio_core_handle, GPIO_0, GPIO_IRQ_EDGE_POSITIVE);	// PDMA done
	GPIO_config(&gpio_core_handle, GPIO_1, GPIO_IRQ_EDGE_POSITIVE);	// ACK ready
	GPIO_config(&gpio_core_handle, GPIO_2, GPIO_IRQ_EDGE_POSITIVE);	// FFT ready
	GPIO_config(&gpio_core_handle, GPIO_3, GPIO_IRQ_EDGE_POSITIVE);	// Accelerometer FIFO overflow
}
//
// Initializes HDL channel vector tables from nm_rec_enable_vector
//
void init_ADC_vectors(void)
{
	writeNMreg(NM0, NM_REC_ENABLE0_REG, nm0_rec_enable_vector[3]);
	writeNMreg(NM0, NM_REC_ENABLE1_REG, nm0_rec_enable_vector[2]);
	writeNMreg(NM0, NM_REC_ENABLE2_REG, nm0_rec_enable_vector[1]);
	writeNMreg(NM0, NM_REC_ENABLE3_REG, nm0_rec_enable_vector[0]);

	writeNMreg(NM1, NM_REC_ENABLE0_REG, nm1_rec_enable_vector[3]);
	writeNMreg(NM1, NM_REC_ENABLE1_REG, nm1_rec_enable_vector[2]);
	writeNMreg(NM1, NM_REC_ENABLE2_REG, nm1_rec_enable_vector[1]);
	writeNMreg(NM1, NM_REC_ENABLE3_REG, nm1_rec_enable_vector[0]);
}

//
// Updates local (nm_rec_enable_vector) and HDL channel vector tables to reflect channels enabled in NMs
//
void update_ADC_vectors(int nmid, int nm_addr, int data)
{
	switch (nmid){
	case 0:
		// need to update the channel select vector if writing to NM_REC_ENABLE reg
		if (nm_addr == NM_REC_ENABLE0_REG)
		{
			// channels 0-15
			nm0_rec_enable_vector[3] = data;
	 		*n0veclo = (nm0_rec_enable_vector[2] << 16) | nm0_rec_enable_vector[3];
		}
		else if (nm_addr == NM_REC_ENABLE1_REG)
		{
			// channels 16-31
			nm0_rec_enable_vector[2] = data;
	 		*n0veclo = (nm0_rec_enable_vector[2] << 16) | nm0_rec_enable_vector[3];
		}
		else if (nm_addr == NM_REC_ENABLE2_REG)
		{
			// channels 32-47
			nm0_rec_enable_vector[1] = data;
	 		*n0vechi = (nm0_rec_enable_vector[0] << 16) | nm0_rec_enable_vector[1];
		}
		else if (nm_addr == NM_REC_ENABLE3_REG)
		{
			// channels 48-63
			nm0_rec_enable_vector[0] = data;
	 		*n0vechi = (nm0_rec_enable_vector[0] << 16) | nm0_rec_enable_vector[1];
		}
		break;

	case 1:
		if (nm_addr == NM_REC_ENABLE0_REG)
		{
			// channels 0-15
			nm1_rec_enable_vector[3] = data;
	 		*n1veclo = (nm1_rec_enable_vector[2] << 16) | nm1_rec_enable_vector[3];
		}
		else if (nm_addr == NM_REC_ENABLE1_REG)
		{
			// channels 16-31
			nm1_rec_enable_vector[2] = data;
	 		*n1veclo = (nm1_rec_enable_vector[2] << 16) | nm1_rec_enable_vector[3];
		}
		else if (nm_addr == NM_REC_ENABLE2_REG)
		{
			// channels 32-47
			nm1_rec_enable_vector[1] = data;
	 		*n1vechi = (nm1_rec_enable_vector[0] << 16) | nm1_rec_enable_vector[1];
		}
		else if (nm_addr == NM_REC_ENABLE3_REG)
		{
			// channels 48-63
			nm1_rec_enable_vector[0] = data;
	 		*n1vechi = (nm1_rec_enable_vector[0] << 16) | nm1_rec_enable_vector[1];
		}
		break;

	default:
		break;
	}
}

//
// Set mode word FFT channel field for nmid
//
int set_FFT_channel(int nmid, int chan)
{
	// The FFT block snoops on the output of the ADC FIFO while the PDMA block is reading out values.
	// Since the samples in the ADC FIFO are "compressed" in that only enabled channels are stored,
	// the channel number needs to be mapped to a FIFO position. If the selected channel is not enabled
	// in nm_rec_enable_vector the fuction returns -1. Otherwise returns 0.
/*
	int i, j = 0;

	for (i = 0; i < 64; i++) {
		int reg_indx = i / 16;	// index into nm_rec_enable_vector[nmid]
		int bit_indx = i % 16;	// bit position within the register field at nm_rec_enable_vector[nmid][reg_indx]
		if (nm_rec_enable_vector[nmid][reg_indx] & (0x8000 >> bit_indx)) {
			if (i == chan) {
				uint32_t currentmode = *mode & ~(0x3f << (NM0_FFT_CHANNEL_OFFSET+(nmid*6)));	// clear bits for nmid
				*mode = currentmode | (j << (NM0_FFT_CHANNEL_OFFSET+(nmid*6)));					// shift new value into field for nmid;
				break;
			}
			j++;
		}
	}

	if (i == 64) {
		return -1;
	}
*/
	return 0;
}

//
// Post a request for contents of NM[nmid] register at regaddr
// Value will be collected after ACK ready interrupt
//
void postNMregRead(int nmid, int regaddr)
{
	if (nmid == 0) {
		*n0d1 = OP_REG_READ;
		*n0d2 = regaddr << 16;
		*command = NM0_TX_START_BIT;
	}
	else if (nmid == 1) {
		*n1d1 = OP_REG_READ;
		*n1d2 = regaddr << 16;
		*command = NM1_TX_START_BIT;
	}
}

//
// Read contents of NM[nmid] register at regaddr
//
int readNMreg(int nmid, int regaddr)
{
	uint32_t x, w;
bool y =  false;

	uint32_t addr_and_data, readok = 1;

	switch (nmid){
		case 0:
			*n0d1 = OP_REG_READ;
			*n0d2 = regaddr << 16;
			*command = NM0_TX_START_BIT;

			do {
				w = NM0_ACK_RDY_BIT;
				x = *status;
				y = x & NM0_ACK_RDY_BIT;
			} while (!y);
//			while(!(*status & NM0_ACK_RDY_BIT));

			addr_and_data = *n0ack;

			break;

		case 1:
			*n1d1 = OP_REG_READ;
			*n1d2 = regaddr << 16;
			*command = NM1_TX_START_BIT;

			do {
				w = NM1_ACK_RDY_BIT;
				x = *status;
				y = x & NM1_ACK_RDY_BIT;
			} while (!y);
//			while(!(*status & NM1_ACK_RDY_BIT));

			addr_and_data = *n1ack;

			break;

		default:
			break;
		}

		readok = (((addr_and_data >> 16) & 0xffff) == regaddr);

	    return readok ? (addr_and_data & 0xffff) : -1;
}

uint16_t nm_regs[0x1f];

void readAllNMregs(int nmid) {
	int i;

	memset((char *) nm_regs, 0, sizeof(nm_regs));

	for (i = 0; i < 0x1f; i++) {
	    nm_regs[i] = readNMreg(nmid, i);
	}
}

//
// Write regdata to NM[nmid] register at regaddr
//
void writeNMreg(int nmid, int regaddr, int regdata)
{
	int i;

	update_ADC_vectors(nmid, regaddr, regdata);

	switch (nmid){
	case 0:
		*n0d1 = OP_REG_WRITE;
		*n0d2 = (regaddr << 16) | regdata;
		*command = NM0_TX_START_BIT;			// start transmit

		for (i = 0; i < 10; i++);				// delay a little bit to allow the busy flag to be set

		while((*status) & NM0_TX_BUSY_BIT);

		break;

	case 1:
		*n1d1 = OP_REG_WRITE;
		*n1d2 = (regaddr << 16) | regdata;
		*command = NM1_TX_START_BIT;			// start transmit

		for (i = 0; i < 10; i++);				// delay a little bit to allow the busy flag to be set

		while((*status) & NM1_TX_BUSY_BIT);

		break;

	default:
		break;
	}
}

//
// Send cmd to NM[nmid]
//
void sendNMcmd(int nmid, int cmd)
{
    int i;

    switch (nmid) {
    case 0:
        *n0d2 = cmd;
        *command = NM0_TX_START_BIT | NM0_TX_MODE_BIT;		// set to command send mode and start transmit

        for (i = 0; i < 10; i++);							// delay a little bit to allow the busy flag to be set

        while((*status) & NM0_TX_BUSY_BIT);					// wait for Tx to complete

        break;

    case 1:
        *n1d2 = cmd;
        *command = NM1_TX_START_BIT | NM1_TX_MODE_BIT;		// set to command send mode and start transmit

        for (i = 0; i < 10; i++);							// delay a little bit to allow the busy flag to be set

        while((*status) & NM1_TX_BUSY_BIT);					// wait for Tx to complete

        break;

    default:
        break;
    }
}

//
// Turn NM[nmid] power switch on
// Used for protocol testing only, not used in Mario-CM
//
void NMon(int nmid)
{
	switch (nmid){
	case 0:
		*rst = 0x101;
		*command = RST_START_BIT | POWER_SW_MODE_BIT;

		while((*status) & RST_BUSY_BIT);

		break;

	case 1:
		*rst = 0x202;
		*command = RST_START_BIT | POWER_SW_MODE_BIT;

		while((*status) & RST_BUSY_BIT);

		break;

	default:
		break;
	}
}

//
// Turn NM[nmid] power switch off
// Used for protocol testing only, not used in Mario-CM
//
void NMoff(int nmid)
{
	switch (nmid){
	case 0:
		*rst = 0x100;
		*command = RST_START_BIT | POWER_SW_MODE_BIT;
		while((*status) & RST_BUSY_BIT);
		break;
	case 1:
		*rst = 0x200;
		*command = RST_START_BIT | POWER_SW_MODE_BIT;
		while((*status) & RST_BUSY_BIT);
		break;
	default:
		break;
	}
}

//
// Send reset command to NM[nmid]
//
void NMreset(int nmid)
	{
	switch (nmid){
	case 0:
		*rst = 0x100;
		*command = RST_START_BIT | RST_MODE_NM_BIT;

		while((*status) & RST_BUSY_BIT);

		break;

	case 1:
		*rst = 0x200;
		*command = RST_START_BIT | RST_MODE_NM_BIT;

		while((*status) & RST_BUSY_BIT);

		break;

	default:
		break;
	}
}

void delay_us(int us)
{
	int i;
	for (i = 0;  i < (us * 3); i++);
}
