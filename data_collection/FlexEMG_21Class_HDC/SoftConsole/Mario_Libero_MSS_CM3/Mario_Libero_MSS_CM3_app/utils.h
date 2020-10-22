/*
 * utils.h
 *
 *  Created on: Jun 22, 2017
 *      Author: flb
 */

#ifndef UTILS_H_
#define UTILS_H_

#define NM0_VEC_63to48 0xffff
#define NM0_VEC_47to32 0xffff
#define NM0_VEC_31to16 0xffff
#define NM0_VEC_15to0  0xffff

#define NM1_VEC_63to48 0xffff
#define NM1_VEC_47to32 0xffff
#define NM1_VEC_31to16 0x0000
#define NM1_VEC_15to0  0x0000

#define SF2_CLK_MHZ 20

// Time to wait after PDMA complete ISR before setting GUI poll flag
#define PDMA_TO_SPI_RDY_DELAY (SF2_CLK_MHZ * 100) // ~100us with a 20MHz PCLK

// Time to wait between polls if PDMA transfers are not occuring (idle).
//#define GUI_POLL_DELAY_IDLE (PDMA_TO_SPI_RDY_DELAY * 20)  // ~2ms with 20MHz PCLK
#define GUI_POLL_DELAY_IDLE (SF2_CLK_MHZ * 10000)  // ~10ms with 20MHz PCLK

// Number of poll_delay_ticks between GUI polls.
// The actual time is a function of poll delay which is:
// poll_delay_ticks * PDMA_TO_SPI_RDY_DELAY when PDMA is active and
// poll_delay_ticks * GUI_POLL_DELAY_IDLE when it is not.
#define GUI_POLL_WAIT_CNT 10

#define POLL_TX_BUF_SIZE 199
#define POLL_RX_BUF_SIZE 6
#define PDMA_TX_FRAME_SIZE 205
#define PDMA_RX_FRAME_SIZE 205

// Mode set macro
#define set_system_mode(newmode) (*mode = ((uint32_t) newmode) | (*mode & 0xffff0000))

// Scope trigger debug signal
#define scope_trigger() {*command = 0x10000; *command = 0x00000;}

// start_measure() asserts the scope trigger debug signal and stop_meaasure() deasserts it.
// Use these macros to measure an event duration along with advanced scope triggering.
#define start_measure() {*command = 0x10000}
#define stop_measure()  {*command = 0x00000}

// Function prototypes
void gpio_init(void);
void init_ADC_vectors(void);
void update_ADC_vectors(int nmid, int nm_addr, int data);
int set_FFT_channel(int nmid, int chan);
void postNMregRead(int nmid, int regaddr);
int readNMreg(int nmid, int regaddr);
void readAllNMregs(int nmid);
void writeNMreg(int nmid, int regaddr, int regdata);
void sendNMcmd(int nmid, int cmd);
void NMon(int nmid);
void NMoff(int nmid);
void NMreset(int nmid);
void delay_us(int us);

#endif /* UTILS_H_ */
