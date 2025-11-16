RPI_VERSION ?= 4
BOOTMNT ?= /media/honta/boot
ARMGNU ?= aarch64-linux-gnu

COPS = -DRPI_VERSION=$(RPI_VERSION) -Wall -nostdlib -nostartfiles -ffreestanding \
       -Iinclude -mgeneral-regs-only

ASMOPS = -Iinclude

BUILD_DIR = build
SRC_DIR = src
ARMSTUB_DIR = armstub

all: kernel8.img armstub-new.bin

clean:
	rm -rf $(BUILD_DIR) $(ARMSTUB_DIR)/build *.img armstub-new.bin

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

kernel8.img: $(SRC_DIR)/linker.ld $(OBJ_FILES)
	@echo "Building for RPI $(value RPI_VERSION)"
	@echo "Deploy to $(value BOOTMNT)"
	@echo ""
	$(ARMGNU)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel8.elf $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
	cp kernel8.img $(BOOTMNT)/kernel8-rpi4.img
	cp config.txt $(BOOTMNT)/
	sync

# ARM Stub build rules
$(ARMSTUB_DIR)/build/armstub_s.o: $(ARMSTUB_DIR)/src/armstub.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

armstub-new.bin: $(ARMSTUB_DIR)/build/armstub_s.o
	$(ARMGNU)-ld --section-start=.text=0 -o $(ARMSTUB_DIR)/build/armstub.elf $(ARMSTUB_DIR)/build/armstub_s.o
	$(ARMGNU)-objcopy $(ARMSTUB_DIR)/build/armstub.elf -O binary armstub-new.bin
	cp armstub-new.bin $(BOOTMNT)/
	sync

.PHONY: all clean