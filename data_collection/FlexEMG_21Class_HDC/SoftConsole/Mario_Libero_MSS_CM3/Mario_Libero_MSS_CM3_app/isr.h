/*
 * isr.h
 *
 *  Created on: Jun 22, 2017
 *      Author: flb
 */

#ifndef ISR_H_
#define ISR_H_

void GPIO5_IRQHandler(void);
void GPIO6_IRQHandler(void);
void GPIO7_IRQHandler(void);
void GPIO8_IRQHandler(void);
void PDMA_0_isr(void);
void PDMA_1_isr(void);
void PDMA_2_isr(void);
void PDMA_3_isr(void);
void Timer1_IRQHandler(void);

#endif /* ISR_H_ */
