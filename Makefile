EDK2_DIR=${HOME}/edk2
OSBOOK_DIR=${HOME}/osbook
LOADER=${EDK2_DIR}/Build/MikanLoaderX64/DEBUG_CLANG38/X64/Loader.efi
KERNEL=kernel/kernel.elf

.PHONY: qemu
qemu: loader kernel
	$(OSBOOK_DIR)/devenv/run_qemu.sh $(LOADER) $(KERNEL)

.PHONY: kernel
kernel:
	make -C kernel

.PHONY: loader
loader:
	make -C MikanLoaderPkg

.PHONY: clean
clean: clean_loader clean_kernel

.PHONY: clean_loader
clean_loader:
	make -C MikanLoaderPkg clean

.PHONY: clean_kernel
clean_kernel:
	make -C kernel clean