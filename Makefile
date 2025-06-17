ASM = nasm
QEMU = qemu-system-x86_64
BOOT_SECTOR = bin/boot.bin
KERNEL_SECTOR = bin/kernel.bin
OS_IMAGE = img/os.img
OS_DIR = img


all: prepare_dirs $(OS_IMAGE)

prepare_dirs:
	mkdir -p bin img

$(BOOT_SECTOR): src/boot.asm
	$(ASM) -f bin src/boot.asm -o $(BOOT_SECTOR)

$(KERNEL_SECTOR): src/kernel.asm
	$(ASM) -f bin src/kernel.asm -o $(KERNEL_SECTOR)

$(OS_IMAGE): $(BOOT_SECTOR) $(KERNEL_SECTOR)
	cat $(BOOT_SECTOR) $(KERNEL_SECTOR) > $(OS_IMAGE)

run: all
	$(QEMU) -fda $(OS_IMAGE)

clean:
	rm -f $(BOOT_SECTOR) $(KERNEL_SECTOR) $(OS_IMAGE) 
