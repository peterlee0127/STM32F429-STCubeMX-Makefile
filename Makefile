TARGET=demo.hex
EXECUTABLE=demo.elf

CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld
#LD=arm-none-eabi-gcc
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
CP=arm-none-eabi-objcopy
OD=arm-none-eabi-objdump

BIN=$(CP) -O ihex

# MDK-ARM
# -c --cpu Cortex-M4.fp -D__MICROLIB -g -O3 --apcs=interwork --split_sections
# -I..\Inc -I..\..\..\..\..\..
# \Drivers\CMSIS\Device\ST\STM32F4xx\Include
# -I..\..\..\..\..\..\Drivers\STM32F4xx_HAL_Driver\Inc
# -I..\..\..\..\..\..\Drivers\BSP\STM32F429I-Discovery --C99
# -I X:\Documents\ARM\Stm32f4\STM32Cube_FW_F4_V1.8.0\Projects\STM32F429I-Discovery\Examples\GPIO\GPIO_EXTI\MDK-ARM\RTE
# -I C:\Keil_v5\ARM\PACK\ARM\CMSIS\4.3.0\CMSIS\Include
# -I C:\Keil_v5\ARM\PACK\Keil\STM32F4xx_DFP\2.5.0\Drivers\CMSIS\Device\ST\STM32F4xx\Include
# -D__UVISION_VERSION="515" -D_RTE_ -DSTM32F429xx -DUSE_HAL_DRIVER -DSTM32F429xx -DUSE_STM32F429I_DISCO -o "STM32F429I-Discovery\*.o" --omf_browse "STM32F429I-Discovery\*.crf" --depend "STM32F429I-Discovery\*.d"

HAL_Driver_Dir = ./Drivers/STM32F4xx_HAL_Driver

DEFS = -D_RTE_ -DSTM32F429xx -DUSE_HAL_DRIVER -DSTM32F429xx -DUSE_STM32F429I_DISCO

MCU = cortex-m4
MCFLAGS = -mcpu=$(MCU) -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
STM32_INCLUDES = -I./inc \
	       -I./Drivers/CMSIS/Device/ST/STM32F4xx/Include \
				 -I ./$(HAL_Driver_Dir)/Inc \
				 -I./Drivers/BSP/STM32F429I-Discovery \
			   -I./Drivers/CMSIS/Include \

#OPTIMIZE       = -Os
OPTIMIZE       = -g -O0

CFLAGS	= $(MCFLAGS)  $(OPTIMIZE)  $(DEFS) -I./ $(STM32_INCLUDES)  -Wl,-T,stm32_flash.ld
AFLAGS	= $(MCFLAGS)
#-mapcs-float use float regs. small increase in code size

SRC = $(HAL_Driver_Dir)/Src/*.c \
  ./Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery.c \
	./src/stm32f4xx_it.c \
	./src/system_stm32f4xx.c \
	./src/_exit.c \
	./src/main.c

STARTUP = ./src/startup_stm32f429xx.s

OBJDIR = .
OBJ = $(SRC:%.c=$(OBJDIR)/%.o)
OBJ += Startup.o

all: $(TARGET)

$(TARGET): $(EXECUTABLE)
	$(CP) -O ihex $^ $@
	$(CP) -O binary $(EXECUTABLE) demo.bin

$(EXECUTABLE): $(SRC) $(STARTUP)
	$(CC) $(CFLAGS) $^ -o $@

flash:
	st-flash write demo.bin 0x8000000
clean:
	rm -f Startup.lst  $(TARGET)  $(TARGET).lst $(OBJ) $(AUTOGEN)  $(TARGET).out  $(TARGET).hex  $(TARGET).map demo.elf \
	 $(TARGET).dmp  $(TARGET).elf
