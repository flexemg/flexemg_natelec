/*
 * nm.h
 *
 *  Created on: Mar 17, 2017
 *      Author: flb
 */

#ifndef NM_H_
#define NM_H_

#define MAX_CHANNELS 64

#define NM0 0
#define NM1 1

#define OP_REG_READ 0
#define OP_REG_WRITE 1

// NM registers
#define NM_CHIP_ID_REG 		0x00
#define NM_STATUS_REG 		0x01
#define NM_PWR_CONFIG_REG 	0x02
#define NM_TEST_SEL_REG 	0x03
#define NM_REC_ENABLE0_REG 	0x04
#define NM_REC_ENABLE1_REG 	0x05
#define NM_REC_ENABLE2_REG 	0x06
#define NM_REC_ENABLE3_REG 	0x07
#define NM_IMP_EN0_REG 		0x08
#define NM_IMP_EN1_REG 		0x09
#define NM_IMP_EN2_REG 		0x0A
#define NM_IMP_EN3_REG 		0x0B
#define NM_REC_CONFIG_REG 	0x0C
#define NM_SYS_CONFIG_REG 	0x0D
#define RESERVED1 			0x0E
#define NM_SCRATCH_REG 		0x0F

#define NM_STIM_CFG0_REG 	0x10
#define NM_STIM_CFG1_REG 	0x11
#define NM_STIM_CFG2_REG 	0x12
#define NM_STIM_CFG3_REG 	0x13
#define NM_STIM_CFG4_REG 	0x14
#define NM_STIM_CFG5_REG 	0x15
#define NM_STIM_CFG6_REG 	0x16
#define NM_STIM_CFG7_REG 	0x17
#define NM_STIM_CFG8_REG 	0x18
#define NM_STIM_CFG9_REG 	0x19
#define NM_STIM_CFG10_REG 	0x1A
#define NM_STIM_CFG11_REG 	0x1B
#define NM_STIM_CFG12_REG 	0x1C
#define NM_STIM_CFG13_REG 	0x1D
#define NM_STIM_CFG14_REG 	0x1E
#define NM_STIM_CFG15_REG 	0x1F

#endif /* NM_H_ */
