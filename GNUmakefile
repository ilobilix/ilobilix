# Copyright (C) 2024-2025  ilobilo

ILOBILIX_ARCH ?= x86_64
ILOBILIX_BUILD_TYPE ?= Release
ILOBILIX_SYSCALL_LOG ?= OFF
ILOBILIX_EXTRA_PANIC_MSG ?= ON
ILOBILIX_MAX_UACPI_POINTS ?= OFF
ILOBILIX_LIMINE_MP ?= ON
ILOBILIX_UBSAN ?= OFF

ILOBILIX_PACKAGES ?= base

override SOURCE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
override KERNEL_SOURCE_DIR := $(SOURCE_DIR)/kernel
override JINX_EXEC := $(SOURCE_DIR)/jinx/jinx

override KERNEL_BUILD_DIR := $(SOURCE_DIR)/build-kernel-$(ILOBILIX_ARCH)
override JINX_BUILD_DIR := $(SOURCE_DIR)/build-jinx-$(ILOBILIX_ARCH)
override JINX_DEST_DIR := $(JINX_BUILD_DIR)/sysroot

.PHONY: error
error:
	@echo "please specify a valid target"
	@exit 1

.PHONY: all
all:
	$(MAKE) kernel
	$(MAKE) jinx

.PHONY: kernel
kernel:
	$(MAKE) setup-kernel
	$(MAKE) build-kernel

.PHONY: jinx
jinx:
	$(MAKE) setup-jinx
	$(MAKE) build-jinx
	$(MAKE) install-jinx

.PHONY: setup-kernel
setup-kernel:
	cmake -S $(KERNEL_SOURCE_DIR) -B $(KERNEL_BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(ILOBILIX_BUILD_TYPE) \
		-DILOBILIX_ARCH=$(ILOBILIX_ARCH) \
		-DILOBILIX_SYSCALL_LOG=$(ILOBILIX_SYSCALL_LOG) \
		-DILOBILIX_EXTRA_PANIC_MSG=$(ILOBILIX_EXTRA_PANIC_MSG) \
		-DILOBILIX_MAX_UACPI_POINTS=$(ILOBILIX_MAX_UACPI_POINTS) \
		-DILOBILIX_LIMINE_MP=$(ILOBILIX_LIMINE_MP) \
		-DILOBILIX_UBSAN=$(ILOBILIX_UBSAN)

.PHONY: build-kernel
build-kernel:
	cmake --build $(KERNEL_BUILD_DIR)

.PHONY: clean-kernel
clean-kernel:
	cmake --build $(KERNEL_BUILD_DIR) --target clean

.PHONY: setup-jinx
setup-jinx:
	mkdir -p $(JINX_BUILD_DIR)
	-cd $(JINX_BUILD_DIR) && $(JINX_EXEC) init $(SOURCE_DIR) JINX_ARCH=$(ILOBILIX_ARCH)

.PHONY: build-jinx
build-jinx:
	cd $(JINX_BUILD_DIR) && $(JINX_EXEC) build $(ILOBILIX_PACKAGES)

.PHONY: rebuild-jinx
rebuild-jinx:
	cd $(JINX_BUILD_DIR) && $(JINX_EXEC) rebuild $(ILOBILIX_PACKAGES)

.PHONY: install-jinx
install-jinx:
	cd $(JINX_BUILD_DIR) && $(JINX_EXEC) install $(JINX_DEST_DIR) $(ILOBILIX_PACKAGES)

.PHONY: distclean-kernel
distclean-kernel:
	rm -rf $(KERNEL_BUILD_DIR)

.PHONY: distclean-jinx
distclean-jinx:
	rm -rf $(JINX_BUILD_DIR)