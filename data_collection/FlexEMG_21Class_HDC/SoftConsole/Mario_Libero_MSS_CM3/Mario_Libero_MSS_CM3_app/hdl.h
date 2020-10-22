/*
 * hdl.h
 *
 *  Created on: Apr 11, 2017
 *      Author: flb
 */

#ifndef HDL_H_
#define HDL_H_

// CM Memory Map: 0x30000000 to 0x3000FFFF
#define REG_BASE 0x30000000

// System mode mask word
#define PDMA_EN 		 (1 << 0)	// enable PDMA channels
#define ACC_IRQ_EN 		 (1 << 1)	// enable accelerometer IRQ (normal or emulated mode)
#define ARTIFACT_EN		 (1 << 2)	// enable artifact cancellation
#define FFT_EN			 (1 << 3)	// enable FFT in ADC datapath block
#define ACC_EMULATE_EN 	 (1 << 4)	// enable accelerometer emulator in HDL (sim/emulation only)
#define NM0_EMULATE_EN	 (1 << 5)	// enable NM0 emulator in HDL (sim/emulation only)
#define NM1_EMULATE_EN	 (1 << 6)	// enable NM1 emulator in HDL (sim/emulation only)
#define PDMA_EMULATE_EN  (1 << 7)	// enable PDMA emulator in HDL (sim/emulation only)
#define NM0_FFT_CHANNEL_OFFSET  16	// channel number for NM0 FFT is the field from 21:16
#define NM1_FFT_CHANNEL_OFFSET  22	// channel number for NM1 FFT is the field from 27:22

// HDL command word
#define LINK_RST_TYPE        0x03
#define NM0_TX_MODE_BIT  (1 << 4)
#define NM1_TX_MODE_BIT  (1 << 5)
#define RST_START_BIT    (1 << 8)
#define NM0_TX_START_BIT (1 << 12)
#define NM1_TX_START_BIT (1 << 13)

// HDL status word
#define LINK_RST_TYPE_RDBACK 0x03
#define CMD_MODE_RDBACK	     0x30
#define RST_BUSY_BIT	 (1 << 16)
#define NM0_TX_BUSY_BIT	 (1 << 20)
#define NM1_TX_BUSY_BIT	 (1 << 21)
#define NM0_FFT_RDY_BIT  (1 << 24)
#define NM1_FFT_RDY_BIT  (1 << 25)
#define NM0_ACK_RDY_BIT	 (1 << 28)
#define NM1_ACK_RDY_BIT  (1 << 29)

#define POWER_SW_MODE_BIT 0x0
#define RST_MODE_AM_BIT   0x3
#define RST_MODE_NM_BIT   0x2

#endif /* HDL_H_ */
