EDK2_DIR = $(HOME)/edk2

.PHONY: loader
loader: Main.c
	cd $(EDK2_DIR) && build

.PHONY: clean
clean:
	rm -rf $(EDK2_DIR)/Build/*