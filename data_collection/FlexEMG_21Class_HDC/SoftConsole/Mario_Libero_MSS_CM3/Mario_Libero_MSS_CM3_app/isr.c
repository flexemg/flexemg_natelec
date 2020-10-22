/*
 * isr.c
 *
 *  Created on: Jun 22, 2017
 *      Author: flb
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "mss_timer.h"
#include "mss_pdma.h"
#include "mss_spi.h"
#include "mss_gpio.h"
#include "core_gpio.h"
#include "utils.h"
#include "hdl.h"
#include "nm.h"
#include "mpu6050.h"
#include "isr.h"
#include "utils.h"

extern bool poll_tx_start;		// Set in Timer 1 ISR
extern bool pdma_tx_start;		// Set in GPIO5 ISR
extern bool pdma_rx_done;		// Set in PDMA_1 ISR
extern bool ack_rdy;			// Set in GPIO6 ISR
extern bool fft_rdy;			// Set in GPIO7 ISR

extern gpio_instance_t gpio_core_handle;

//
// Main SPI-PDMA ISR
// The PDMA block informs the CoreGPIO block that data is ready for transfer.
// The CoreGPIO block interrupts the M3 via MSS GPIO5.
//
void GPIO5_IRQHandler()
{
	MSS_GPIO_clear_irq(MSS_GPIO_5);
	GPIO_clear_irq(&gpio_core_handle, GPIO_0);

	pdma_tx_start = true;
}

//
// ACK ready ISR
// Called when an ACK arrives from one or more NMs.
//
void GPIO6_IRQHandler()
{
	MSS_GPIO_clear_irq(MSS_GPIO_6);
	GPIO_clear_irq(&gpio_core_handle, GPIO_1);

	ack_rdy = true;
}

//
// FFT ready ISR
// Called when an FFT block has completed conversion.
//
void GPIO7_IRQHandler()
{
	MSS_GPIO_clear_irq(MSS_GPIO_7);
	GPIO_clear_irq(&gpio_core_handle, GPIO_2);

	fft_rdy = true;
}

//
// Accelerometer FIFO overflow ISR
// This is an error condition - need to drain the FIFO before continuing.
// DOES NOT WORK VERY WELL!!
//
void GPIO8_IRQHandler()
{
	MSS_GPIO_clear_irq(MSS_GPIO_8);
	GPIO_clear_irq(&gpio_core_handle, GPIO_3);

	MPU6050_clear_FIFO();
}

//
// PDMA --> SPI complete ISR
// When the SPI block completes a transfer on channel 0 (PDMA Tx) it calls this handler.
// Currently not used.
//
void PDMA_0_isr(void)
{
    PDMA_clear_irq(PDMA_CHANNEL_0);
}

//
// SPI --> PDMA complete ISR
// When the SPI block completes a transfer on channel 1 (PDMA Rx) it calls this handler.
//
void PDMA_1_isr(void)
{
    PDMA_clear_irq(PDMA_CHANNEL_1);

    pdma_rx_done = true;
 }

//
// Idle timer.
// Ensures that an SPI poll will occur even if NM ADC data streaming is off.
// This can occur when either the PDMA block is disabled or record is not enabled in both NMs.
//
void Timer1_IRQHandler()
{
 	MSS_TIM1_clear_irq();

	poll_tx_start = true;
}


