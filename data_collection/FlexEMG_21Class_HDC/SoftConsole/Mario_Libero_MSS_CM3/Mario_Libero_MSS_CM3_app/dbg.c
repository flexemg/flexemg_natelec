/*
 * dbg.c
 *
 *  Created on: Jul 11, 2017
 *      Author: flb
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <m2sxxx.h>
#include "utils.h"
#include "dbg.h"

extern int *dbgsel;

void dbg_set_channel(void)
{
    *dbgsel = DEBUG_SEL;
}

//
// SPI register read functions. Debug only.
//

#define SPI_REG_SAMPLES 15

// SPI base address
int spi0_addr = 0x40001000;

uint32_t spi_regvals[SPI_REG_SAMPLES][17];

void dbg_clear_SPI_regcounts(void)
{
	memset((char *) spi_regvals, 0, sizeof(spi_regvals));
}

int dbg_read_SPI_register(int reg)
{
	return *((int *) (spi0_addr + reg));
}

void dbg_read_SPI_registers(int ts)
{
	spi_regvals[ts][0] = *((int *) (spi0_addr + SPI_CONTROL_REG));
	spi_regvals[ts][1] = *((int *) (spi0_addr + SPI_TXRXDF_SIZE_REG));
	spi_regvals[ts][2] = *((int *) (spi0_addr + SPI_STATUS_REG));
	spi_regvals[ts][3] = *((int *) (spi0_addr + SPI_INT_CLEAR_REG));
	spi_regvals[ts][4] = *((int *) (spi0_addr + SPI_RX_DATA_REG));
	spi_regvals[ts][5] = *((int *) (spi0_addr + SPI_TX_DATA_REG));
	spi_regvals[ts][6] = *((int *) (spi0_addr + SPI_CLK_GEN_REG));
	spi_regvals[ts][7] = *((int *) (spi0_addr + SPI_SLAVE_SELECT_REG));
	spi_regvals[ts][8] = *((int *) (spi0_addr + SPI_MIS_REG));
	spi_regvals[ts][9] = *((int *) (spi0_addr + SPI_RIS_REG));
	spi_regvals[ts][10] = *((int *) (spi0_addr + SPI_CONTROL2_REG));
	spi_regvals[ts][11] = *((int *) (spi0_addr + SPI_COMMAND_REG));
	spi_regvals[ts][12] = *((int *) (spi0_addr + SPI_PKTSIZE_REG));
	spi_regvals[ts][13] = *((int *) (spi0_addr + SPI_CMD_SIZE_REG));
	spi_regvals[ts][14] = *((int *) (spi0_addr + SPI_HWSTATUS_REG));
	spi_regvals[ts][15] = *((int *) (spi0_addr + SPI_STAT8_REG));
	spi_regvals[ts][16]++;	// sample count

// SPI_CTRL0_REG, SPI_CTRL1_REG, SPI_CTRL2_REG, SPI_CTRL3_REG are 8 bit mirrors of SPI_CONTROL_REG
}

//
// Record NM_ACK_RECORDS incoming ACK packets for traffic analysis
//

#define NM_ACK_RECORD_BUFSIZE 500
#define NM_ACK_RECORDS 100

uint32_t nm_ack_debug[NM_ACK_RECORD_BUFSIZE];
int nm_ack_debug_indx = 0;

void dbg_init_nm_record(void)
{
	memset((char *) nm_ack_debug, 0, sizeof(nm_ack_debug));
}
void dbg_record_nm_ack(uint32_t val)
{
	if (nm_ack_debug_indx < NM_ACK_RECORDS) {
		nm_ack_debug[nm_ack_debug_indx++] = val;
	} else {
		nm_ack_debug_indx = NM_ACK_RECORDS;	//  place for breakpoint
	}
}

//uint32_t reg_array[30][2];
//int rindx = 0;

//if (rindx < 30) {
//	reg_array[rindx][0] = rx_buf[1];
//	reg_array[rindx][1] = (uint32_t) reg_val;
//	rindx++;
//} else {
//	readAllNMregs(1);
//	rindx = 0;
//}

