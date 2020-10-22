/*
 * mpu6050.c
 *
 *  Created on: Apr 20, 2016
 *      Author: flb
 */

#include "mpu6050.h"

int MPU6050_fifo_error, MPU6050_data_ready;

#define MPU_REG_BASE 0x30001000

// status word2
#define REG_RD_OK  0x01
#define REG_WR_OK  0x02
#define IRQ_OK     0x04
#define APB_BUSY   0x08
#define APB_GRANT  0x10
#define DATA_RDY   0x20
#define FIFO_OFLOW 0x40

#define compute_addr(x) ((int*)(MPU_REG_BASE+((x) << 4)))

int *reg_config       = compute_addr(MPU6050_CONFIG_REG);
int *reg_sample_rate  = compute_addr(MPU6050_SAMPLE_RATE_REG);
int *reg_pwr_mgmt_1   = compute_addr(MPU6050_PWR_MGMT_1_REG);
int *reg_pwr_mgmt_2   = compute_addr(MPU6050_PWR_MGMT_2_REG);
int *reg_fifo_en      = compute_addr(MPU6050_FIFO_EN_REG);
int *reg_int_pin_cfg  = compute_addr(MPU6050_INT_PIN_CFG_REG);
int *reg_user_ctrl    = compute_addr(MPU6050_USER_CTRL_REG);
int *reg_int_status   = compute_addr(MPU6050_INT_STATUS_REG);
int *reg_int_enable   = compute_addr(MPU6050_INT_ENABLE_REG);
int *reg_fifo_count_h = compute_addr(MPU6050_FIFO_COUNT_H_REG);
int *reg_fifo_count_l = compute_addr(MPU6050_FIFO_COUNT_L_REG);
int *reg_fifo_r_w     = compute_addr(MPU6050_FIFO_R_W_REG);

int *mpu_status       = compute_addr(STATUS);
int *read_result      = compute_addr(LAST_REG_READ);
int *mpu_last_X	  	  = compute_addr(LAST_X_VAL);
int *mpu_last_Y	  	  = compute_addr(LAST_Y_VAL);
int *mpu_last_Z	      = compute_addr(LAST_Z_VAL);


void mpu_delay(int ticks)
{
	int i = 0;
	for(i = 0; i < ticks; i++);
}

int MPU6050_init(void)
{
	// MPU6050 initialization state:
	//
	// Internal 8MHz oscillator
	// Sample rate 1KHz for all sensors
	// Gyroscope on standby
	// Accelerometer bandwidth 44KHz, delay 4.9ms
	// Accelerometer full scale range +-2g
	// Motion detection off
	// Interrupts enabled
	// All sensors standby on start-up

	int retval;

    // Set DLPF_CFG to 3
	retval = MPU6050_write_reg_readback(reg_config, 3);
//	if (retval < 0) return retval - 4;

	// Disable temperature sensor, set clock source to internal 8MHz (accelerometer sample rate = 1KHz)
	retval = MPU6050_write_reg_readback(reg_pwr_mgmt_1, TEMP_DIS);
	if (retval < 0) return retval - 12;

	// Gyro on standby and accelerometer running
	retval = MPU6050_write_reg_readback(reg_pwr_mgmt_2, STBY_XG | STBY_YG | STBY_ZG);
	if (retval < 0) return retval - 16;

	// Tell FIFO to accept samples from all accelerometer axes
	retval = MPU6050_write_reg_readback(reg_fifo_en, ACCEL_FIFO_EN);
	if (retval < 0) return retval - 20;

	// Configure INT pin to hold until reset and interrupts cleared on any read
	retval = MPU6050_write_reg_readback(reg_int_pin_cfg, LATCH_INT_EN | INT_RD_CLEAR);
	if (retval < 0) return retval - 24;

	// Make sure the user crtl register is cleared
	retval = MPU6050_write_reg_readback(reg_user_ctrl, 0);
	if (retval < 0) return retval - 28;

	// Reset the FIFO, signal paths and sensor registers (bits cleared internally after reset initiated)
	// Don't user MPU6050_write_reg_readback() since the bits may not be set on readback.
	retval = MPU6050_write_reg(reg_user_ctrl, FIFO_RESET | SIG_COND_RESET);
	if (retval < 0) return retval - 32;

	// Enable FIFO overflow and data ready interrupts
	retval = MPU6050_write_reg_readback(reg_int_enable, FIFO_OFLOW_EN | DATA_RDY_EN);
	if (retval < 0) return retval - 36;

	// Enable the FIFO
	retval = MPU6050_write_reg_readback(reg_user_ctrl, FIFO_EN);
	if (retval < 0) return retval - 40;

	return *mpu_status;
}

int MPU6050_write_reg(int *regaddr, uint8_t regval)
{
	int stat;

	*regaddr = regval;

	mpu_delay(600);

    do {
    	stat = *mpu_status;
    } while (stat & APB_BUSY);

    return (stat & REG_WR_OK);
}

int MPU6050_read_reg(int *regaddr, uint8_t *regval)
{
	int stat;

	// The first read initiates the I2C transfer.
	*regval = *regaddr;

	mpu_delay(600);

	do {
    	stat = *mpu_status;
    } while (stat & APB_BUSY);

    // The second read gets the value.
    *regval = *read_result;

	return (stat & REG_RD_OK);
}

int MPU6050_write_reg_readback(int *regaddr, uint8_t regval)
{
	uint8_t i2c_read_buf;

	if (MPU6050_write_reg(regaddr, regval) == 0) return -1;
	if (MPU6050_read_reg(regaddr, &i2c_read_buf) == 0) return -2;
	if (i2c_read_buf != regval) return -3;

	mpu_delay(100);

	return 0;
}

int MPU6050_reset_FIFO(void)
{
	uint8_t rdval, wrval;

	// read current register settings
	if (MPU6050_read_reg(reg_user_ctrl, &rdval) == 0) return -1;

	// disable FIFO
	wrval = rdval & ~FIFO_EN;
	if (MPU6050_write_reg(reg_user_ctrl, wrval) == 0) return -2;

	//reset FIFO (reset bit is cleared when reset completes)
	wrval |= FIFO_RESET;
	if (MPU6050_write_reg(reg_user_ctrl, wrval) == 0) return -3;

	// restore register contents (re-enables the FIFO)
	if (MPU6050_write_reg(reg_user_ctrl, rdval) == 0) return -4;

	return 0;
}

int MPU6050_clear_FIFO(void)
{
	uint8_t int_status = 0;
	uint16_t byte_count = 0;
	uint8_t buf[1024];

	// Disable FIFO interrupts
	int retval = MPU6050_write_reg_readback(reg_int_enable, 0);
	if (retval < 0) return retval;

	byte_count = MPU6050_get_FIFO_byte_count();

    int i;
    for (i = 0; i < byte_count; i++) {
		if (MPU6050_read_reg(reg_fifo_r_w, &buf[i]) == 0) return -5;
	}

	if (MPU6050_read_reg(reg_int_status, &int_status) == 0) return -6;

	byte_count = MPU6050_get_FIFO_byte_count();

	// Re-enable FIFO overflow and data ready interrupts
	retval = MPU6050_write_reg_readback(reg_int_enable, FIFO_OFLOW_EN | DATA_RDY_EN);
	if (retval < 0) return retval - 8;

	return byte_count;
}

int MPU6050_get_FIFO_byte_count(void)
{
	uint16_t bc = 0;
	uint8_t i2c_read_1 = 0, i2c_read_2 = 0;

	// get high FIFO count byte
	if (MPU6050_read_reg(reg_fifo_count_h, &i2c_read_1) == 0) return -2;
	bc = i2c_read_1 << 8;
int x = i2c_read_1;
	// get low FIFO count byte
	if (MPU6050_read_reg(reg_fifo_count_l, &i2c_read_2) == 0) return -3;
	bc += i2c_read_2;
int y = i2c_read_2;
int z = (x << 8);
z += y;

	return bc;
}

