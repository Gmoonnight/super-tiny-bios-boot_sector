AS := nasm
ASFLAGS := -f elf64 -gdwarf -MD

LD := ld.lld
LDFLAGS = -nostdlib -m elf_x86_64

SRC_DIR := src
BUILD_DIR := .build
DEBUG_DIR := debug

BOOT_DIR := $(BUILD_DIR)/boot
TARGETS := $(BOOT_DIR)/boot_sector.bin
IMG := $(BUILD_DIR)/boot_sector.img

GDB_COMMANDS_FILE := $(DEBUG_DIR)/gdb_commands.txt

all: $(IMG)

debug: all
	qemu-system-x86_64 -display sdl -drive file=$(IMG),format=raw -boot c -S -s & \
	gdb -x $(GDB_COMMANDS_FILE); \
	kill $$!

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all debug clean

$(IMG): $(TARGETS)
	dd if=$(BOOT_DIR)/boot_sector.bin of=$(IMG) bs=512

$(BOOT_DIR)/boot_sector.bin: $(BOOT_DIR)/boot_sector.o $(BOOT_DIR)/print_string.o
	$(LD) $(LDFLAGS) --Ttext=0x7c00 -o $(@:.bin=.elf) $<
	objcopy -O binary $(@:.bin=.elf) $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $^