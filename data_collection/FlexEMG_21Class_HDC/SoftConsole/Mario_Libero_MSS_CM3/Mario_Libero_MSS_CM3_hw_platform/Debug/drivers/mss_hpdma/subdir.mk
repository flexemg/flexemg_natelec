################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../drivers/mss_hpdma/mss_hpdma.c 

OBJS += \
./drivers/mss_hpdma/mss_hpdma.o 

C_DEPS += \
./drivers/mss_hpdma/mss_hpdma.d 


# Each subdirectory must supply rules for building sources it contributes
drivers/mss_hpdma/%.o: ../drivers/mss_hpdma/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU C Compiler'
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m3 -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\CMSIS -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\CMSIS\startup_gcc -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_gpio -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_hpdma -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_nvm -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_pdma -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_spi -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_sys_services -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_timer -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers\mss_uart -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers_config -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\drivers_config\sys_config -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\hal -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\hal\CortexM3 -IP:\Libero\Mario-CM_Flex-EMG_newarch\Mario-CM_Flex-EMG_noam\SoftConsole\Mario_Libero_MSS_CM3\Mario_Libero_MSS_CM3_hw_platform\hal\CortexM3\GNU -O0 -ffunction-sections -fdata-sections -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


