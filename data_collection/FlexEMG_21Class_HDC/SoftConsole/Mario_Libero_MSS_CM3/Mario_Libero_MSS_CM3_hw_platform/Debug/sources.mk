################################################################################
# Automatically-generated file. Do not edit!
################################################################################

O_SRCS := 
C_SRCS := 
S_UPPER_SRCS := 
S_SRCS := 
OBJ_SRCS := 
OBJS := 
C_DEPS := 
ARCHIVES := 

# Every subdirectory with source files must be described here
SUBDIRS := \
hal/CortexM3 \
hal/CortexM3/GNU \
drivers_config/sys_config \
drivers/mss_uart \
drivers/mss_sys_services \
drivers/mss_spi \
drivers/mss_pdma \
drivers/mss_nvm \
drivers/mss_hpdma \
drivers/mss_gpio \
drivers/CoreGPIO \
CMSIS \
CMSIS/startup_gcc \

################################################################################
# Microsemi SoftConsole IDE Variables
################################################################################

BUILDCMD = arm-none-eabi-ar -r 
SHELL := cmd.exe
EXECUTABLE := Mario_Libero_MSS_CM3_hw_platform.a

# Target-specific items to be cleaned up in the top directory.
clean::
	-$(RM) $(wildcard ./*.map) 
