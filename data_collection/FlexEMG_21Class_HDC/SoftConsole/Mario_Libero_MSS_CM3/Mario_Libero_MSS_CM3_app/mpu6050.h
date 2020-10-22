/*
 * mpu6050.h
 *
 *  Created on: Apr 18, 2016
 *      Author: flb
 */

#include <stdio.h>
#include <stdbool.h>
#include <m2sxxx.h>
#include <mss_hpdma.h>

#ifndef MPU6050_H_
#define MPU6050_H_

#define MPU6050_NUM_SENSORS 3
#define MPU6050_NUM_BYTES_PER_SAMPLE (MPU6050_NUM_SENSORS*2)
#define MPU6050_FIFO_SIZE 1024
#define MPU6050_MAX_SAMPLES_IN_FIFO	 (MPU6050_FIFO_SIZE/MPU6050_NUM_BYTES_PER_SAMPLE)

#define MPU6050_BASE_ADDR (0x68)
// Local HDL registers
#define STATUS        0x00
#define LAST_X_VAL    0x01
#define LAST_Y_VAL    0x02
#define LAST_Z_VAL    0x03
#define LAST_REG_READ 0x04

// Initialization and Control Registers
#define MPU6050_SAMPLE_RATE_REG		0x19
#define MPU6050_CONFIG_REG 			0x1a
#define MPU6050_GYRO_CONFIG_REG 	0x1b
#define MPU6050_ACCEL_CONFIG_REG	0x1c
#define MPU6050_SMPRT_DIV_REG		0x19
#define MPU6050_FIFO_EN_REG			0x23
#define MPU6050_SIG_PATH_RST_REG	0x68
#define MPU6050_USER_CTRL_REG		0x6a
#define MPU6050_PWR_MGMT_1_REG		0x6b	// reset value 0x40
#define MPU6050_PWR_MGMT_2_REG		0x6c
// Sensor Data Registers and FIFO Registers
#define MPU6050_ACCEL_X_OUT_H_REG	0x3b
#define MPU6050_ACCEL_X_OUT_L_REG	0x3c
#define MPU6050_ACCEL_Y_OUT_H_REG	0x3d
#define MPU6050_ACCEL_Y_OUT_L_REG	0x3e
#define MPU6050_ACCEL_Z_OUT_H_REG	0x3f
#define MPU6050_ACCEL_Z_OUT_L_REG	0x40
#define MPU6050_TEMP_OUT_H_REG		0x41
#define MPU6050_TEMP_OUT_L_REG		0x42
#define MPU6050_GYRO_X_OUT_H_REG	0x43
#define MPU6050_GYRO_X_OUT_L_REG	0x44
#define MPU6050_GYRO_Y_OUT_H_REG	0x45
#define MPU6050_GYRO_Y_OUT_L_REG	0x46
#define MPU6050_GYRO_Z_OUT_H_REG	0x47
#define MPU6050_GYRO_Z_OUT_L_REG	0x48
#define MPU6050_FIFO_COUNT_H_REG	0x72
#define MPU6050_FIFO_COUNT_L_REG	0x73
#define MPU6050_FIFO_R_W_REG		0x74
// Interrupt and Self Test Registers
#define MPU6050_INT_PIN_CFG_REG		0x37
#define MPU6050_INT_ENABLE_REG		0x38
#define MPU6050_INT_STATUS_REG		0x3a
#define MPU6050_SELF_TEST_X_REG		0x0d
#define MPU6050_SELF_TEST_Y_REG		0x0e
#define MPU6050_SELF_TEST_Z_REG		0x0f
#define MPU6050_SELF_TEST_A_REG		0x10
// MOtion Detect Registers
#define MPU6050_MOT_THR_REG			0x1f
#define MPU6050_MOT_DETECT_CTRL_REG	0x69
// ID Register
#define MPU6050_WHO_AM_I_REG		0x75	// reset value 0x68
// Slave registers not defined yet (unused)

//// BIT MAPS

// CONFIG register
// FSYNC field options (choose one)
#define FSYNC_DISABLE		(0x0 << 3)
#define FSYNC_TEMP_OUT		(0x1 << 3)
#define FSYNC_GYRO_XOUT		(0x2 << 3)
#define FSYNC_GYRO_YOUT		(0x3 << 3)
#define FSYNC_GYRO_ZOUT		(0x4 << 3)
#define FSYNC_ACCEL_XOUT	(0x5 << 3)
#define FSYNC_ACCEL_YOUT	(0x6 << 3)
#define FSYNC_ACCEL_ZOUT	(0x7 << 3)
// no defines for DLPF_CFG - see register map pdf page 13

// GYRO_CONFIG register
#define XG_ST			(1 << 7)
#define YG_ST			(1 << 6)
#define ZG_ST			(1 << 5)
// FS_SEL field options (choose one)
#define FS_250			(0x0 << 4)
#define FS_500			(0x1 << 4)
#define FS_1000			(0x2 << 4)
#define FS_2000			(0x3 << 4)

// ACCEL_CONFIG register
#define XA_ST			(1 << 7)
#define YA_ST			(1 << 6)
#define ZA_ST			(1 << 5)
// AFS_SEL field options (choose one)
#define AFS_2			(0x0 << 3)
#define AFS_4			(0x1 << 3)
#define AFS_8			(0x2 << 3)
#define AFS_16			(0x3 << 3)

// FIFO_EN register
#define TEMP_FIFO_EN	(1 << 7)
#define XG_FIFO_EN		(1 << 6)
#define YG_FIFO_EN		(1 << 5)
#define ZG_FIFO_EN		(1 << 4)
#define ACCEL_FIFO_EN	(1 << 3)
#define SLV2_FIFO_EN	(1 << 2)
#define SLV1_FIFO_EN	(1 << 1)
#define ALV0_FIFO_EN	(1 << 0)

// SIGNAL_PATH_RESET register
#define GYRO_RESET		(1 << 2)
#define ACCEL_RESET		(1 << 1)
#define TEMP_RESET		(1 << 0)

// USER_CTRL register
#define FIFO_EN			(1 << 6)
#define I2C_MST_EN		(1 << 5)
#define I2C_IF_DIS		(1 << 4)
#define FIFO_RESET		(1 << 2)
#define I2C_MST_RESET	(1 << 1)
#define SIG_COND_RESET	(1 << 0)

// PWR_MGMT_1 register
#define DEVICE_RESET	(1 << 7)
#define SLEEP			(1 << 6)
#define CYCLE			(1 << 5)
#define TEMP_DIS		(1 << 3)
// CLKSEL field options (choose one)
#define CLKSEL_8MHz		(0x0)
#define CLKSEL_GYROX	(0x1)
#define CLKSEL_GYROY	(0x2)
#define CLKSEL_GYROZ	(0x3)
#define CLKSEL_EXT32K	(0x4)
#define CLKSEL_EXT19M	(0x5)
// 6 is reserved
#define CLKSEL_STOP		(0x7)

// PWR_MGMT_2 register
#define STBY_XA			(1 << 5)
#define STBY_YA			(1 << 4)
#define STBY_ZA			(1 << 3)
#define STBY_XG			(1 << 2)
#define STBY_YG			(1 << 1)
#define STBY_ZG			(1 << 0)
// LP_WAKE_CTRL field options (choose one)
#define LP_WAKE_1p25	(0x0 << 6)
#define LP_WAKE_5		(0x1 << 6)
#define LP_WAKE_20		(0x2 << 6)
#define LP_WAKE_40		(0x3 << 6)

// INT_PIN_CFG register
#define INT_LEVEL		(1 << 7)
#define INT_OPEN		(1 << 6)
#define LATCH_INT_EN	(1 << 5)
#define INT_RD_CLEAR	(1 << 4)
#define FSYNC_INT_LEVEL	(1 << 3)
#define FSYNC_INT_EN	(1 << 2)
#define I2C_BYPASS_EN	(1 << 1)

// INT_ENABLE register
#define MOT_EN			(1 << 6)
#define FIFO_OFLOW_EN	(1 << 4)
#define I2C_MST_INT_EN	(1 << 3)
#define DATA_RDY_EN		(1 << 0)

// INT_STATUS register
#define MOT_INT			(1 << 6)
#define FIFO_OFLOW_INT	(1 << 4)
#define I2C_MST_INT		(1 << 3)
#define DATA_RDY_INT	(1 << 0)

int MPU6050_init(void);
int MPU6050_write_reg(int *regaddr, uint8_t regval);
int MPU6050_read_reg(int *regaddr, uint8_t *regval);
int MPU6050_write_reg_readback(int *regaddr, uint8_t regval);
int MPU6050_reset_FIFO(void);
int MPU6050_clear_FIFO(void);
int MPU6050_get_FIFO_byte_count(void);

#endif /* MPU6050_H_ */
