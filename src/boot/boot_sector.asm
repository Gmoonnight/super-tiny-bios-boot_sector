[bits 16]
section .text

	global _start

_start:
	; Don't assume the segment register are set properly by BIOS.
	; When the BIOS jumps to your code you can't rely on DS, ES, SS, SP registers having valid or expected values.
	; They should be set up appropriately when your bootloader starts. Even if you don't use them.
	; The CS:IP = 0x07C00 has been set properly by BIOS.
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ax, 0x9000
	mov ss, ax
	mov sp, 0xFFFF

	; Print welcome message.
	mov ax, 0x07C0
	mov ds, ax
	mov si, welcome_msg - 0x7C00
	%include "src/boot/print_string.asm"

	jmp $

welcome_msg: db "Welcome to boot sector.", 0x0A, 0x0D, 0x00

times 510 - ($ - $$) db 0	; Just fill the remain space of 512 B with 0
dw 0xAA55	; Magic number for telling BIOS that, this sector is a valid boot sector.