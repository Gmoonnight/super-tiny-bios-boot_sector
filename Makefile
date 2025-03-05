AS := nasm
ASFLAGS := -f elf64 -gdwarf -MD

LD := ld.lld
LDFLAGS = -nostdlib -m elf_x86_64

SRC_DIR := src
BUILD_DIR := .build
TMP_DIR := .tmp

BOOT_DIR := $(BUILD_DIR)/boot

TARGETS := $(BOOT_DIR)/boot_sector.bin

IMG := $(BUILD_DIR)/boot_sector.img

QEMU_PID_FILE := $(TMP_DIR)/qemu.pid

all: $(IMG)

debug: all
	mkdir -p $(dir $(QEMU_PID_FILE))
	qemu-system-x86_64 -display sdl -drive file=$(IMG),format=raw -boot c -S -s & \
		echo $$! > $(QEMU_PID_FILE)
	gdb $(BUILD_DIR)/boot/boot_sector.elf \
		-ex "set pagination off" \
		-ex "set confirm off" \
		-ex "set osabi none" \
		-ex "target remote localhost:1234" \
		-ex "br _start" \
		-ex "layout src" \
		-ex "layout regs" \
		-ex "continue"
	cat $(QEMU_PID_FILE) | xargs kill

clean:
	rm -rf $(BUILD_DIR) $(TMP_DIR)

.PHONY: all debug clean

$(IMG): $(TARGETS)
	dd if=$(BOOT_DIR)/boot_sector.bin of=$(IMG) bs=512

$(BOOT_DIR)/boot_sector.bin: $(BOOT_DIR)/boot_sector.o $(BOOT_DIR)/print_string.o
	$(LD) $(LDFLAGS) --Ttext=0x7c00 -o $(@:.bin=.elf) $<
	objcopy -O binary $(@:.bin=.elf) $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $^