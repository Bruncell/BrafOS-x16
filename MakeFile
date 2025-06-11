ASM = nasm
QEMU = qemu-system-x86_64
BOOT_SECTOR = boot.bin
KERNEL_SECTOR = kernel.bin
OS_IMAGE = os.img

all: $(OS_IMAGE)

$(BOOT_SECTOR): boot.asm
	$(ASM) -f bin boot.asm -o $(BOOT_SECTOR)

$(KERNEL_SECTOR): kernel.asm
	$(ASM) -f bin kernel.asm -o $(KERNEL_SECTOR)

$(OS_IMAGE): $(BOOT_SECTOR) $(KERNEL_SECTOR)
	cat $(BOOT_SECTOR) $(KERNEL_SECTOR) > $(OS_IMAGE)

run: all
	$(QEMU) -fda $(OS_IMAGE)

clean:
	rm -f $(BOOT_SECTOR) $(KERNEL_SECTOR) $(OS_IMAGE)
