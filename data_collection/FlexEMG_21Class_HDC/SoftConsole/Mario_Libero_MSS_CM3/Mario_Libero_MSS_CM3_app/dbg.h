/*
 * dbg.h
 *
 *  Created on: Jul 11, 2017
 *      Author: flb
 */

#ifndef DBG_H_
#define DBG_H_

// Hardware debug mux channel selections
// (see SF2 Dev Board debug channels.xlsx)
// For the Mario board only four signals are available on each debug channel.
#define DEBUG_NRX      		0
#define DEBUG_NTX      		1
#define DEBUG_ACK_DP   		2
#define DEBUG_ADC_DP   		3
#define DEBUG_ADC_VEC		4
#define DEBUG_ADC_ART		5
#define DEBUG_ADC_FFT		6
#define DEBUG_PDMA     		7
#define DEBUG_ACC  			8
#define DEBUG_NM_APB  		9
#define DEBUG_CM_APB		10
#define DEBUG_SPI			11
#define DEBUG_NM0_SIM  		12
#define DEBUG_NM0_ADC_SIM	13
#define DEBUG_NM0_CNR_SIM	14
#define DEBUG_MODE_BITS		15
#define DEBUG_GPIO			16
#define DEBUG_FIFOS 		17	// error flags designed for the LEDs (see below)
#define DEBUG_NM1_ACK_DP	18
#define DEBUG_CUSTOM_1 		19
#define DEBUG_CUSTOM_2		20
#define DEBUG_CUSTOM_3		21

#define DEBUG_SEL DEBUG_SPI

//
// FIFO error flag LED indications
//
//	PDMA FIFO overflow		dim 500ms period pulse on LED1
//	PDMA FIFO underflow		dim 500ms period pulse on LED0
//	NM0 ADC FIFO overflow	bright 250ms period pulse on LED1
//	NM0 ADC FIFO underflow	bright 250ms period pulse on LED0
//	NM1 ADC FIFO overflow	dim 250ms period pulse on LED1
//	NM1 ADC FIFO underflow	dim 250ms period pulse on LED0
//	PDMA and NM0 overflow	bright 1s period pulse on LED1
//	PDMA and NM0 underflow	bright 1s period pulse on LED0
//	PDMA and NM1 overflow	dim 1s period pulse on LED1
//	PDMA and NM1 underflow	dim 1s period pulse on LED0
//	NM0 and NM1 overflow	bright 500ms period pulse on LED1
//	NM0 and NM1 underflow	bright 500ms period pulse on LED0
//	all overflow			bright 2s period pulse on LED1
//	all underflow			bright 2s period pulse on LED0
//

// SPI register address offsets (for debug)
#define SPI_CONTROL_REG			0x00
#define SPI_TXRXDF_SIZE_REG		0x04
#define SPI_STATUS_REG	 		0x08
#define SPI_INT_CLEAR_REG 		0x0c
#define SPI_RX_DATA_REG 		0x10
#define SPI_TX_DATA_REG 		0x14
#define SPI_CLK_GEN_REG 		0x18
#define SPI_SLAVE_SELECT_REG 	0x1c
#define SPI_MIS_REG 			0x20
#define SPI_RIS_REG 			0x24
#define SPI_CONTROL2_REG 		0x28
#define SPI_COMMAND_REG 		0x2c
#define SPI_PKTSIZE_REG 		0x30
#define SPI_CMD_SIZE_REG 		0x34
#define SPI_HWSTATUS_REG 		0x38
#define SPI_STAT8_REG 			0x3c
#define SPI_CTRL0_REG 			0x40
#define SPI_CTRL1_REG 			0x44
#define SPI_CTRL2_REG 			0x48
#define SPI_CTRL3_REG 			0x4c

void dbg_set_channel(void);
int dbg_read_SPI_register(int reg);
void dbg_read_SPI_registers(int ts);
void dbg_clear_SPI_regcounts(void);
void dbg_init_nm_record(void);
void dbg_record_nm_ack(uint32_t val);

#endif /* DBG_H_ */
