# Makefile for MyOS
AS = nasm
CC = i686-elf-gcc
LD = i686-elf-ld

# 컴파일러 플래그
CFLAGS = -ffreestanding -m32 -fno-pie -O2 -Wall -Wextra -nostdlib
LDFLAGS = -T linker.ld

all: os.bin

boot.bin: boot/boot.asm
	$(AS) -f bin boot/boot.asm -o boot.bin

kernel/kernel_entry.o: kernel/kernel_entry.asm
	$(AS) -f elf32 kernel/kernel_entry.asm -o kernel/kernel_entry.o

kernel/kernel.o: kernel/kernel.c kernel/screen.h
	$(CC) $(CFLAGS) -c kernel/kernel.c -o kernel/kernel.o

kernel/screen.o: kernel/screen.c kernel/screen.h
	$(CC) $(CFLAGS) -c kernel/screen.c -o kernel/screen.o

kernel.bin: kernel/kernel_entry.o kernel/kernel.o kernel/screen.o linker.ld
	$(LD) $(LDFLAGS) -o kernel.bin kernel/kernel_entry.o kernel/kernel.o kernel/screen.o --oformat binary
	@echo "Kernel size: `ls -l kernel.bin | awk '{print $$5}'` bytes"

os.bin: boot.bin kernel.bin
	cat boot.bin kernel.bin > os.bin
	@echo "OS image created successfully"

run: os.bin
	qemu-system-x86_64 -drive format=raw,file=os.bin

debug: os.bin
	qemu-system-x86_64 -drive format=raw,file=os.bin -d int,cpu_reset -no-reboot -no-shutdown

clean:
	rm -f *.bin kernel/*.o

.PHONY: all run debug clean