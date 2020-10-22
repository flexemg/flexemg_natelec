/*******************************************************************************
 * (c) Copyright 2012-2014 Microsemi SoC Products Group.  All rights reserved.
 * 
 *  SmartFusion2 vector table and startup code for CodeSourcery G++.
 *
 * SVN $Revision: 6676 $
 * SVN $Date: 2014-07-06 15:06:13 +0100 (Sun, 06 Jul 2014) $
 */

    .syntax unified
    .cpu cortex-m3
    .thumb
    

/*==============================================================================
 * Vector table
 */
    .global     g_pfnVectors
    .section    .isr_vector,"a",%progbits
    .type       g_pfnVectors, %object
    .size       g_pfnVectors, .-g_pfnVectors
    
g_pfnVectors:
    .word  _estack
    .word  Reset_Handler
    .word  NMI_Handler
    .word  HardFault_Handler
    .word  MemManage_Handler
    .word  BusFault_Handler
    .word  UsageFault_Handler
    .word  0
    .word  0
    .word  0
    .word  0
    .word  SVC_Handler
    .word  DebugMon_Handler
    .word  0
    .word  PendSV_Handler
    .word  SysTick_Handler
    .word  WdogWakeup_IRQHandler
    .word  RTC_Wakeup_IRQHandler
    .word  SPI0_IRQHandler
    .word  SPI1_IRQHandler
    .word  I2C0_IRQHandler
    .word  I2C0_SMBAlert_IRQHandler
    .word  I2C0_SMBus_IRQHandler
    .word  I2C1_IRQHandler
    .word  I2C1_SMBAlert_IRQHandler
    .word  I2C1_SMBus_IRQHandler
    .word  UART0_IRQHandler
    .word  UART1_IRQHandler
    .word  EthernetMAC_IRQHandler
    .word  DMA_IRQHandler
    .word  Timer1_IRQHandler
    .word  Timer2_IRQHandler
    .word  CAN_IRQHandler
    .word  ENVM0_IRQHandler
    .word  ENVM1_IRQHandler
    .word  ComBlk_IRQHandler
    .word  USB_IRQHandler
    .word  USB_DMA_IRQHandler
    .word  PLL_Lock_IRQHandler
    .word  PLL_LockLost_IRQHandler
    .word  CommSwitchError_IRQHandler
    .word  CacheError_IRQHandler
    .word  DDR_IRQHandler
    .word  HPDMA_Complete_IRQHandler
    .word  HPDMA_Error_IRQHandler
    .word  ECC_Error_IRQHandler
    .word  MDDR_IOCalib_IRQHandler
    .word  FAB_PLL_Lock_IRQHandler
    .word  FAB_PLL_LockLost_IRQHandler
    .word  FIC64_IRQHandler
    .word  FabricIrq0_IRQHandler
    .word  FabricIrq1_IRQHandler
    .word  FabricIrq2_IRQHandler
    .word  FabricIrq3_IRQHandler
    .word  FabricIrq4_IRQHandler
    .word  FabricIrq5_IRQHandler
    .word  FabricIrq6_IRQHandler
    .word  FabricIrq7_IRQHandler
    .word  FabricIrq8_IRQHandler
    .word  FabricIrq9_IRQHandler
    .word  FabricIrq10_IRQHandler
    .word  FabricIrq11_IRQHandler
    .word  FabricIrq12_IRQHandler
    .word  FabricIrq13_IRQHandler
    .word  FabricIrq14_IRQHandler
    .word  FabricIrq15_IRQHandler    
    .word  GPIO0_IRQHandler
    .word  GPIO1_IRQHandler
    .word  GPIO2_IRQHandler
    .word  GPIO3_IRQHandler
    .word  GPIO4_IRQHandler
    .word  GPIO5_IRQHandler
    .word  GPIO6_IRQHandler
    .word  GPIO7_IRQHandler
    .word  GPIO8_IRQHandler
    .word  GPIO9_IRQHandler
    .word  GPIO10_IRQHandler
    .word  GPIO11_IRQHandler
    .word  GPIO12_IRQHandler
    .word  GPIO13_IRQHandler
    .word  GPIO14_IRQHandler
    .word  GPIO15_IRQHandler
    .word  GPIO16_IRQHandler
    .word  GPIO17_IRQHandler
    .word  GPIO18_IRQHandler
    .word  GPIO19_IRQHandler
    .word  GPIO20_IRQHandler
    .word  GPIO21_IRQHandler
    .word  GPIO22_IRQHandler
    .word  GPIO23_IRQHandler
    .word  GPIO24_IRQHandler
    .word  GPIO25_IRQHandler
    .word  GPIO26_IRQHandler
    .word  GPIO27_IRQHandler
    .word  GPIO28_IRQHandler
    .word  GPIO29_IRQHandler
    .word  GPIO30_IRQHandler
    .word  GPIO31_IRQHandler
    .word  0
    .word  0
    
/*==============================================================================
 * Reset_Handler
 * Register r11 is used to keep track of whether we need to initialize RAMs
 * because ECC/ SECDED is enabled.
 */
    .global Reset_Handler
    .section    .boot_code,"a",%progbits
    .type   Reset_Handler, %function
Reset_Handler:
_start:
/*------------------------------------------------------------------------------
 * Initialize stack RAM content to initialize the error detection and correction
 * (EDAC). This is done if EDAC is enabled for the eSRAM blocks or the
 * ECC/SECDED is enabled for the MDDR.
 * Register r11 is used to keep track of the RAM intialization decision outcome
 * for later use for heap RAM initialization at the end of the startup code.
 * Please note that the stack has to be located in eSRAM at this point and
 * cannot be located in MDDR since MDDR is not available at this point.
 * The bits of the content of register r11 have the foolwing meaning:
 *  reg11[0]: eSRAM EDAC enabled
 *  reg11[1]: MDDR ECC/SECDED enabled
 */
    mov r11, #0
    ldr r0, SF2_MDDR_MODE_CR
    ldr r0, [r0]
    ldr r1, SF2_EDAC_CR
    ldr r1, [r1]
    and r1, r1, #3
    and r0, r0, #0x1C
    cmp r0, #0x14
    bne check_esram_edac
    orr r11, r11, #2
check_esram_edac:
    cmp r1, #0
    beq check_stack_init
    orr r11, r11, #1
check_stack_init:
    cmp r11, #0
    beq system_init
clear_stack:
    ldr r0, =__stack_start__
    ldr r1, =_estack
    ldr r2, RAM_INIT_PATTERN
    ldr r3, RAM_INIT_PATTERN
    ldr r4, RAM_INIT_PATTERN
    ldr r5, RAM_INIT_PATTERN
clear_stack_loop:
    cmp r0, r1
    it ne
    stmne r0!, {r2-r5}
    bne clear_stack_loop
    
/*------------------------------------------------------------------------------
 * Call CMSIS system init function.
 */
 system_init:
    ldr r0, =SystemInit
    blx r0

/*------------------------------------------------------------------------------
 * Modify MDDR configuration if ECC/SECDED is enabled fo MDDR.
 * Enable write combining on MDDR bridge, disable non-bufferable regions.
 */
    and r10, r11, 0x2
    cmp r10, #0
    beq remap_memory
    ldr r0, SF2_DDRB_NB_SIZE
    ldr r1, SF2_DDRB_CR
    ldr r2, [r0]
    ldr r3, [r1]
    push {r0, r1, r2, r3}
    mov r2, #0
    mov r3, #0xFF
    str r2, [r0]
    str r3, [r1]
    
/*------------------------------------------------------------------------------
 * Perform memory remapping based on the value of __smartfusion2_memory_remap
 * set in the linker script.
 */
remap_memory:
    ldr r0, =__smartfusion2_memory_remap
    ldr r2, =0
    ldr r3, =1
    cmp r0, #2
    bne check_esram_remap
    /*
     * Remap external RAM to address 0x00000000
     */
    ldr r1, SF2_ESRAM_CR
    str r2, [r1]
    ldr r1, SF2_ENVM_REMAP_CR
    str r2, [r1]
    ldr r1, SF2_DDR_CR
    str r3, [r1]
check_esram_remap:
    cmp r0, #1
    bne check_mirrored_nvm
    /*
     * Remap internal eSRAM to address 0x00000000
     */
    ldr r1, SF2_DDR_CR
    str r2, [r1]
    ldr r1, SF2_ENVM_REMAP_CR
    str r2, [r1]
    ldr r1, SF2_ESRAM_CR
    str r3, [r1]
    
/*------------------------------------------------------------------------------
 * Check if the executable is built for NVM LMA mirrored to VMA address.
 * This is done for debugging executables running out of eNVM with SoftConsole.
 * The .text section should not be copied in this case since both the LMA and
 * VMA point at the eNVM despite the LMA and VMa having different values.
 */
 check_mirrored_nvm:
    ldr r0, =__mirrored_nvm
    cmp r0, #0
    bne copy_data
    
/*------------------------------------------------------------------------------
 * Copy vector table.
 */
    ldr r0, =__vector_table_load
    ldr r1, =__vector_table_start
    ldr r2, =_evector_table
    bl block_copy
    
/*------------------------------------------------------------------------------
 * Copy code section.
 */
copy_text:
    ldr r0, =__text_load
    ldr r1, =__text_start
    ldr r2, =_etext
    bl block_copy
    
/*------------------------------------------------------------------------------
 * Copy data section.
 */
 copy_data:
    ldr r0, =__data_load
    ldr r1, =__data_start
    ldr r2, =_edata
    bl block_copy
    
/*------------------------------------------------------------------------------
 * Clear .bss
 */
clear_bss:
    ldr r0, =__bss_start__
    ldr r1, =__bss_end__
    ldr r2, =0
    ldr r3, =0
    ldr r4, =0
    ldr r5, =0
clear_bss_loop:
    cmp r0, r1
    it ne
    stmne r0!, {r2-r5}
    bne clear_bss_loop
    
/*------------------------------------------------------------------------------
 * Initialize heap RAM content to initialize the error detection and correction
 * (EDAC). We use the decision made earlier in the startup code of whether or
 * not the stack RAM should be initialized. This decision is held in register
 * r11. A non-zero value indicates that the RAM content should be initialized.
 */
clear_heap:
    cmp r11, #0
    beq call_glob_ctor
    ldr r0, =__heap_start__
    ldr r1, =_eheap
    ldr r2, HEAP_INIT_PATTERN
    ldr r3, HEAP_INIT_PATTERN
    ldr r4, HEAP_INIT_PATTERN
    ldr r5, HEAP_INIT_PATTERN
clear_heap_loop:
    cmp r0, r1
    it ne
    stmne r0!, {r2-r5}
    bne clear_heap_loop
    
/*------------------------------------------------------------------------------
 * Restore MDDR configuration.
 */
    and r10, r11, 0x2
    cmp r10, #0
    beq call_glob_ctor
    pop {r0, r1, r2, r3}
    str r2, [r0]
    str r3, [r1]
    
/*------------------------------------------------------------------------------
 * Call global constructors
 */
    /*
     * Align to word and use 32-bits LDR instruction to ensure the ADD instruction
     * taking PC as argument is aligned on a word boundary.
     */
    .align 4
call_glob_ctor:
    ldr.w r0, =__libc_init_array
    add lr, pc, #3
    bx r0
    
/*------------------------------------------------------------------------------
 * branch to main.
 */
branch_to_main:
    mov r0, #0      /*  no arguments  */
    mov r1, #0      /*  no argv either */
    ldr pc, =main

ExitLoop:
    B ExitLoop

/*------------------------------------------------------------------------------
 * block copy.
 * Size of block to copy must be a multiple of 16 bytes. Source and Destination
 * addresses are expected to be aligned on 16-byte boundary.
 *
 * r0: source address
 * r1: target address
 * r2: end target address (non-inclusive)
 */
block_copy:
    push {r3, r4, r5, r6, r7, lr}
    cmp r0, r1
    beq block_copy_exit
    subs r2, r2, r1
    asrs r2,r2, #4
    tst r2, #15
    beq block_copy_loop
    adds r2, r2, #1
block_copy_loop:
    cmp r2, r3
    itt ne
    ldmne r0!, {r4, r5, r6, r7}
    stmne r1!, {r4, r5, r6, r7}
    add r3, #1
    bne block_copy_loop
block_copy_exit:
    pop {r3, r4, r5, r6, r7, pc}
    
/*==============================================================================
 * NMI_Handler
 */
    .weak   NMI_Handler
    .type   NMI_Handler, %function
NMI_Handler:
    B .

/*==============================================================================
 * HardFault_Handler
 */
    .weak   HardFault_Handler
    .type   HardFault_Handler, %function
HardFault_Handler:
    B .

/*==============================================================================
 * MemManage_Handler
 */
    .weak   MemManage_Handler
    .type   MemManage_Handler, %function
MemManage_Handler:
    B .

/*==============================================================================
 * BusFault_Handler
 */
    .weak   BusFault_Handler
    .type   BusFault_Handler, %function
BusFault_Handler:
    B .

/*==============================================================================
 * UsageFault_Handler
 */
    .weak   UsageFault_Handler
    .type   UsageFault_Handler, %function
UsageFault_Handler:
    B .

/*==============================================================================
 * SVC_Handler
 */
    .weak   SVC_Handler
    .type   SVC_Handler, %function
SVC_Handler:
    B .

/*==============================================================================
 * DebugMon_Handler
 */
    .weak   DebugMon_Handler
    .type   DebugMon_Handler, %function
DebugMon_Handler:
    B .

/*==============================================================================
 * PendSV_Handler
 */
    .weak   PendSV_Handler
    .type   PendSV_Handler, %function
PendSV_Handler:
    B .

/*==============================================================================
 * SysTick_Handler
 */
    .weak   SysTick_Handler
    .type   SysTick_Handler, %function
SysTick_Handler:
    B .

/*==============================================================================
 * WdogWakeup_IRQHandler
 */
    .weak   WdogWakeup_IRQHandler
    .type   WdogWakeup_IRQHandler, %function
WdogWakeup_IRQHandler:
    B .

/*==============================================================================
 * RTC_Wakeup_IRQHandler
 */
    .weak   RTC_Wakeup_IRQHandler
    .type   RTC_Wakeup_IRQHandler, %function
RTC_Wakeup_IRQHandler:
    B .

/*==============================================================================
 * SPI0_IRQHandler
 */
    .weak   SPI0_IRQHandler
    .type   SPI0_IRQHandler, %function
SPI0_IRQHandler:
    B .

/*==============================================================================
 * SPI1_IRQHandler
 */
    .weak   SPI1_IRQHandler
    .type   SPI1_IRQHandler, %function
SPI1_IRQHandler:
    B .

/*==============================================================================
 * I2C0_IRQHandler
 */
    .weak   I2C0_IRQHandler
    .type   I2C0_IRQHandler, %function
I2C0_IRQHandler:
    B .

/*==============================================================================
 * I2C0_SMBAlert_IRQHandler
 */
    .weak   I2C0_SMBAlert_IRQHandler
    .type   I2C0_SMBAlert_IRQHandler, %function
I2C0_SMBAlert_IRQHandler:
    B .

/*==============================================================================
 * I2C0_SMBus_IRQHandler
 */
    .weak   I2C0_SMBus_IRQHandler
    .type   I2C0_SMBus_IRQHandler, %function
I2C0_SMBus_IRQHandler:
    B .

/*==============================================================================
 * I2C1_IRQHandler
 */
    .weak   I2C1_IRQHandler
    .type   I2C1_IRQHandler, %function
I2C1_IRQHandler:
    B .

/*==============================================================================
 * I2C1_SMBAlert_IRQHandler
 */
    .weak   I2C1_SMBAlert_IRQHandler
    .type   I2C1_SMBAlert_IRQHandler, %function
I2C1_SMBAlert_IRQHandler:
    B .

/*==============================================================================
 * I2C1_SMBus_IRQHandler
 */
    .weak   I2C1_SMBus_IRQHandler
    .type   I2C1_SMBus_IRQHandler, %function
I2C1_SMBus_IRQHandler:
    B .

/*==============================================================================
 * UART0_IRQHandler
 */
    .weak   UART0_IRQHandler
    .type   UART0_IRQHandler, %function
UART0_IRQHandler:
    B .

/*==============================================================================
 * UART1_IRQHandler
 */
    .weak   UART1_IRQHandler
    .type   UART1_IRQHandler, %function
UART1_IRQHandler:
    B .
    
/*==============================================================================
 * EthernetMAC_IRQHandler
 */
    .weak   EthernetMAC_IRQHandler
    .type   EthernetMAC_IRQHandler, %function
EthernetMAC_IRQHandler:
    B .

/*==============================================================================
 * DMA_IRQHandler
 */
    .weak   DMA_IRQHandler
    .type   DMA_IRQHandler, %function
DMA_IRQHandler:
    B .

/*==============================================================================
 * Timer1_IRQHandler
 */
    .weak   Timer1_IRQHandler
    .type   Timer1_IRQHandler, %function
Timer1_IRQHandler:
    B .

/*==============================================================================
 * Timer2_IRQHandler
 */
    .weak   Timer2_IRQHandler
    .type   Timer2_IRQHandler, %function
Timer2_IRQHandler:
    B .
    
/*==============================================================================
 * CAN_IRQHandler
 */
    .weak   CAN_IRQHandler
    .type   CAN_IRQHandler, %function
CAN_IRQHandler:
    B .
    
/*==============================================================================
 * ENVM0_IRQHandler
 */
    .weak   ENVM0_IRQHandler
    .type   ENVM0_IRQHandler, %function
ENVM0_IRQHandler:
    B .

/*==============================================================================
 * ENVM1_IRQHandler
 */
    .weak   ENVM1_IRQHandler
    .type   ENVM1_IRQHandler, %function
ENVM1_IRQHandler:
    B .

/*==============================================================================
 * ComBlk_IRQHandler
 */
    .weak   ComBlk_IRQHandler
    .type   ComBlk_IRQHandler, %function
ComBlk_IRQHandler:
    B .
    
/*==============================================================================
 * USB_IRQHandler
 */
    .weak   USB_IRQHandler
    .type   USB_IRQHandler, %function
USB_IRQHandler:
    B .
    
/*==============================================================================
 * USB_DMA_IRQHandler
 */
    .weak   USB_DMA_IRQHandler
    .type   USB_DMA_IRQHandler, %function
USB_DMA_IRQHandler:
    B .

/*==============================================================================
 * PLL_Lock_IRQHandler
 */
    .weak   PLL_Lock_IRQHandler
    .type   PLL_Lock_IRQHandler, %function
PLL_Lock_IRQHandler:
    B .

/*==============================================================================
 * PLL_LockLost_IRQHandler
 */
    .weak   PLL_LockLost_IRQHandler
    .type   PLL_LockLost_IRQHandler, %function
PLL_LockLost_IRQHandler:
    B .

/*==============================================================================
 * CommSwitchError_IRQHandler
 */
    .weak   CommSwitchError_IRQHandler
    .type   CommSwitchError_IRQHandler, %function
CommSwitchError_IRQHandler:
    B .

/*==============================================================================
 * CacheError_IRQHandler
 */
    .weak   CacheError_IRQHandler
    .type   CacheError_IRQHandler, %function
CacheError_IRQHandler:
    B .

/*==============================================================================
 * DDR_IRQHandler
 */
    .weak   DDR_IRQHandler
    .type   DDR_IRQHandler, %function
DDR_IRQHandler:
    B .

/*==============================================================================
 * HPDMA_Complete_IRQHandler
 */
    .weak   HPDMA_Complete_IRQHandler
    .type   HPDMA_Complete_IRQHandler, %function
HPDMA_Complete_IRQHandler:
    B .

/*==============================================================================
 * HPDMA_Error_IRQHandler
 */
    .weak   HPDMA_Error_IRQHandler
    .type   HPDMA_Error_IRQHandler, %function
HPDMA_Error_IRQHandler:
    B .
    
/*==============================================================================
 * ECC_Error_IRQHandler
 */
    .weak   ECC_Error_IRQHandler
    .type   ECC_Error_IRQHandler, %function
ECC_Error_IRQHandler:
    B .

/*==============================================================================
 * MDDR_IOCalib_IRQHandler
 */
    .weak   MDDR_IOCalib_IRQHandler
    .type   MDDR_IOCalib_IRQHandler, %function
MDDR_IOCalib_IRQHandler:
    B .

/*==============================================================================
 * FAB_PLL_Lock_IRQHandler
 */
    .weak   FAB_PLL_Lock_IRQHandler
    .type   FAB_PLL_Lock_IRQHandler, %function    
FAB_PLL_Lock_IRQHandler:
    B .

/*==============================================================================
 * FAB_PLL_LockLost_IRQHandler
 */
    .weak   FAB_PLL_LockLost_IRQHandler
    .type   FAB_PLL_LockLost_IRQHandler, %function        
FAB_PLL_LockLost_IRQHandler:
    B .
    
/*==============================================================================
 * FIC64_IRQHandler
 */
    .weak   FIC64_IRQHandler
    .type   FIC64_IRQHandler, %function            
FIC64_IRQHandler:
    B .
    
/*==============================================================================
 * FabricIrq0_IRQHandler
 */
    .weak   FabricIrq0_IRQHandler
    .type   FabricIrq0_IRQHandler, %function
FabricIrq0_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq1_IRQHandler
 */
    .weak   FabricIrq1_IRQHandler
    .type   FabricIrq1_IRQHandler, %function
FabricIrq1_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq2_IRQHandler
 */
    .weak   FabricIrq2_IRQHandler
    .type   FabricIrq2_IRQHandler, %function
FabricIrq2_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq3_IRQHandler
 */
    .weak   FabricIrq3_IRQHandler
    .type   FabricIrq3_IRQHandler, %function
FabricIrq3_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq4_IRQHandler
 */
    .weak   FabricIrq4_IRQHandler
    .type   FabricIrq4_IRQHandler, %function
FabricIrq4_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq5_IRQHandler
 */
    .weak   FabricIrq5_IRQHandler
    .type   FabricIrq5_IRQHandler, %function
FabricIrq5_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq6_IRQHandler
 */
    .weak   FabricIrq6_IRQHandler
    .type   FabricIrq6_IRQHandler, %function
FabricIrq6_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq7_IRQHandler
 */
    .weak   FabricIrq7_IRQHandler
    .type   FabricIrq7_IRQHandler, %function
FabricIrq7_IRQHandler:
    B .
    
/*==============================================================================
 * FabricIrq8_IRQHandler
 */
    .weak   FabricIrq8_IRQHandler
    .type   FabricIrq8_IRQHandler, %function
FabricIrq8_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq9_IRQHandler
 */
    .weak   FabricIrq9_IRQHandler
    .type   FabricIrq9_IRQHandler, %function
FabricIrq9_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq10_IRQHandler
 */
    .weak   FabricIrq10_IRQHandler
    .type   FabricIrq10_IRQHandler, %function
FabricIrq10_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq11_IRQHandler
 */
    .weak   FabricIrq11_IRQHandler
    .type   FabricIrq11_IRQHandler, %function
FabricIrq11_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq12_IRQHandler
 */
    .weak   FabricIrq12_IRQHandler
    .type   FabricIrq12_IRQHandler, %function
FabricIrq12_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq13_IRQHandler
 */
    .weak   FabricIrq13_IRQHandler
    .type   FabricIrq13_IRQHandler, %function
FabricIrq13_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq14_IRQHandler
 */
    .weak   FabricIrq14_IRQHandler
    .type   FabricIrq14_IRQHandler, %function
FabricIrq14_IRQHandler:
    B .

/*==============================================================================
 * FabricIrq15_IRQHandler
 */
    .weak   FabricIrq15_IRQHandler
    .type   FabricIrq15_IRQHandler, %function
FabricIrq15_IRQHandler:
    B .    

/*==============================================================================
 * GPIO0_IRQHandler
 */
    .weak   GPIO0_IRQHandler
    .type   GPIO0_IRQHandler, %function
GPIO0_IRQHandler:
    B .

/*==============================================================================
 * GPIO1_IRQHandler
 */
    .weak   GPIO1_IRQHandler
    .type   GPIO1_IRQHandler, %function
GPIO1_IRQHandler:
    B .

/*==============================================================================
 * GPIO2_IRQHandler
 */
    .weak   GPIO2_IRQHandler
    .type   GPIO2_IRQHandler, %function
GPIO2_IRQHandler:
    B .

/*==============================================================================
 * GPIO3_IRQHandler
 */
    .weak   GPIO3_IRQHandler
    .type   GPIO3_IRQHandler, %function
GPIO3_IRQHandler:
    B .

/*==============================================================================
 * GPIO4_IRQHandler
 */
    .weak   GPIO4_IRQHandler
    .type   GPIO4_IRQHandler, %function
GPIO4_IRQHandler:
    B .

/*==============================================================================
 * GPIO5_IRQHandler
 */
    .weak   GPIO5_IRQHandler
    .type   GPIO5_IRQHandler, %function
GPIO5_IRQHandler:
    B .

/*==============================================================================
 * GPIO6_IRQHandler
 */
    .weak   GPIO6_IRQHandler
    .type   GPIO6_IRQHandler, %function
GPIO6_IRQHandler:
    B .

/*==============================================================================
 * GPIO7_IRQHandler
 */
    .weak   GPIO7_IRQHandler
    .type   GPIO7_IRQHandler, %function
GPIO7_IRQHandler:
    B .

/*==============================================================================
 * GPIO8_IRQHandler
 */
    .weak   GPIO8_IRQHandler
    .type   GPIO8_IRQHandler, %function
GPIO8_IRQHandler:
    B .

/*==============================================================================
 * GPIO9_IRQHandler
 */
    .weak   GPIO9_IRQHandler
    .type   GPIO9_IRQHandler, %function
GPIO9_IRQHandler:
    B .

/*==============================================================================
 * GPIO10_IRQHandler
 */
    .weak   GPIO10_IRQHandler
    .type   GPIO10_IRQHandler, %function
GPIO10_IRQHandler:
    B .

/*==============================================================================
 * GPIO11_IRQHandler
 */
    .weak   GPIO11_IRQHandler
    .type   GPIO11_IRQHandler, %function
GPIO11_IRQHandler:
    B .

/*==============================================================================
 * GPIO12_IRQHandler
 */
    .weak   GPIO12_IRQHandler
    .type   GPIO12_IRQHandler, %function
GPIO12_IRQHandler:
    B .

/*==============================================================================
 * GPIO13_IRQHandler
 */
    .weak   GPIO13_IRQHandler
    .type   GPIO13_IRQHandler, %function
GPIO13_IRQHandler:
    B .

/*==============================================================================
 * GPIO14_IRQHandler
 */
    .weak   GPIO14_IRQHandler
    .type   GPIO14_IRQHandler, %function
GPIO14_IRQHandler:
    B .

/*==============================================================================
 * GPIO15_IRQHandler
 */
    .weak   GPIO15_IRQHandler
    .type   GPIO15_IRQHandler, %function
GPIO15_IRQHandler:
    B .

/*==============================================================================
 * GPIO16_IRQHandler
 */
    .weak   GPIO16_IRQHandler
    .type   GPIO16_IRQHandler, %function
GPIO16_IRQHandler:
    B .

/*==============================================================================
 * GPIO17_IRQHandler
 */
    .weak   GPIO17_IRQHandler
    .type   GPIO17_IRQHandler, %function
GPIO17_IRQHandler:
    B .

/*==============================================================================
 * GPIO18_IRQHandler
 */
    .weak   GPIO18_IRQHandler
    .type   GPIO18_IRQHandler, %function
GPIO18_IRQHandler:
    B .

/*==============================================================================
 * GPIO19_IRQHandler
 */
    .weak   GPIO19_IRQHandler
    .type   GPIO19_IRQHandler, %function
GPIO19_IRQHandler:
    B .

/*==============================================================================
 * GPIO20_IRQHandler
 */
    .weak   GPIO20_IRQHandler
    .type   GPIO20_IRQHandler, %function
GPIO20_IRQHandler:
    B .

/*==============================================================================
 * GPIO21_IRQHandler
 */
    .weak   GPIO21_IRQHandler
    .type   GPIO21_IRQHandler, %function
GPIO21_IRQHandler:
    B .

/*==============================================================================
 * GPIO22_IRQHandler
 */
    .weak   GPIO22_IRQHandler
    .type   GPIO22_IRQHandler, %function
GPIO22_IRQHandler:
    B .

/*==============================================================================
 * GPIO23_IRQHandler
 */
    .weak   GPIO23_IRQHandler
    .type   GPIO23_IRQHandler, %function
GPIO23_IRQHandler:
    B .

/*==============================================================================
 * GPIO24_IRQHandler
 */
    .weak   GPIO24_IRQHandler
    .type   GPIO24_IRQHandler, %function
GPIO24_IRQHandler:
    B .

/*==============================================================================
 * GPIO25_IRQHandler
 */
    .weak   GPIO25_IRQHandler
    .type   GPIO25_IRQHandler, %function
GPIO25_IRQHandler:
    B .

/*==============================================================================
 * GPIO26_IRQHandler
 */
    .weak   GPIO26_IRQHandler
    .type   GPIO26_IRQHandler, %function
GPIO26_IRQHandler:
    B .

/*==============================================================================
 * GPIO27_IRQHandler
 */
    .weak   GPIO27_IRQHandler
    .type   GPIO27_IRQHandler, %function
GPIO27_IRQHandler:
    B .

/*==============================================================================
 * GPIO28_IRQHandler
 */
    .weak   GPIO28_IRQHandler
    .type   GPIO28_IRQHandler, %function
GPIO28_IRQHandler:
    B .

/*==============================================================================
 * GPIO29_IRQHandler
 */
    .weak   GPIO29_IRQHandler
    .type   GPIO29_IRQHandler, %function
GPIO29_IRQHandler:
    B .

/*==============================================================================
 * GPIO30_IRQHandler
 */
    .weak   GPIO30_IRQHandler
    .type   GPIO30_IRQHandler, %function
GPIO30_IRQHandler:
    B .

/*==============================================================================
 * GPIO31_IRQHandler
 */
    .weak   GPIO31_IRQHandler
    .type   GPIO31_IRQHandler, %function
GPIO31_IRQHandler:
    B .

/*==============================================================================
 * mscc_post_hw_cfg_init
 */
    .weak   mscc_post_hw_cfg_init
    .type   mscc_post_hw_cfg_init, %function
mscc_post_hw_cfg_init:
    BX LR

/*==============================================================================
 * Constants:
 */
RAM_INIT_PATTERN:       .word   0x00000000
HEAP_INIT_PATTERN:      .word   0xA2A2A2A2
SF2_ESRAM_CR:           .word   0x40038000
SF2_DDR_CR:             .word   0x40038008
SF2_ENVM_REMAP_CR:      .word   0x40038010
SF2_DDRB_NB_SIZE:       .word   0x40038030
SF2_DDRB_CR:            .word   0x40038034
SF2_EDAC_CR:            .word   0x40038038
SF2_MDDR_MODE_CR:       .word   0x40020818
 
.end
