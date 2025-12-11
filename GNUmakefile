# Copyright (C) 2024-2025  ilobilo

ILOBILIX_ARCH ?= x86_64
ILOBILIX_BUILD_TYPE ?= ReleaseDbg
ILOBILIX_SYSCALL_LOG ?= OFF
ILOBILIX_EXTRA_PANIC_MSG ?= ON
ILOBILIX_MAX_UACPI_POINTS ?= OFF
ILOBILIX_LIMINE_MP ?= ON
ILOBILIX_UBSAN ?= OFF

ILOBILIX_PACKAGES ?= base

QEMU_ACCEL ?= ON
QEMU_LOG ?= OFF
QEMU_GDB ?= OFF
QEMU_SMP ?= 6

override SOURCE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
override KERNEL_SOURCE_DIR := $(SOURCE_DIR)/kernel/
override BUILDROOT_SOURCE_DIR := $(SOURCE_DIR)/buildroot/

override BUILD_DIR := $(SOURCE_DIR)/build-$(ILOBILIX_ARCH)
override KERNEL_BUILD_DIR := $(BUILD_DIR)/kernel/
override BUILDROOT_BUILD_DIR := $(BUILD_DIR)/buildroot/
override SYSROOT_DIR := $(BUILD_DIR)/sysroot/
override ISO_DIR := $(BUILD_DIR)/iso/

ifdef OVERRIDE_SYSROOT_DIR
override SYSROOT_DIR := $(abspath $(OVERRIDE_SYSROOT_DIR))
endif

override SYSROOT_SKELETON_DIR := $(SOURCE_DIR)/support/skeleton/

override BUILDROOT := make -C $(BUILDROOT_SOURCE_DIR) O=$(BUILDROOT_BUILD_DIR)
override BUILDROOT_CONFIG :=  $(SOURCE_DIR)/support/buildroot-$(ILOBILIX_ARCH).config
override BUILDROOT_OUT_TAR := $(BUILDROOT_BUILD_DIR)/images/rootfs.tar

override LIMINE_DIR := $(KERNEL_SOURCE_DIR)/dependencies/limine/limine/
override LIMINE_EXEC := $(KERNEL_BUILD_DIR)/dependencies/limine/limine
override LIMINE_CONF := $(SOURCE_DIR)/support/limine.conf

override KERNEL_ELF := $(KERNEL_BUILD_DIR)/kernel/source/kernel_elf
override MODULES_DIR := $(KERNEL_BUILD_DIR)/modules/modules/
override INITRAMFS_IMG := $(BUILD_DIR)/initramfs.tar
override ISO_IMG := $(BUILD_DIR)/image.iso

override OVMF_DIR := $(SOURCE_DIR)/ovmf-binaries/
ifeq ($(ILOBILIX_ARCH),x86_64)
override OVMF_BIN := $(OVMF_DIR)/OVMF_X64.fd
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
override OVMF_BIN := $(OVMF_DIR)/OVMF_AA64.fd
endif

override CXXFILT_EXE := llvm-cxxfilt --no-params

override QEMU_EXEC := qemu-system-$(ILOBILIX_ARCH)
override QEMU_ARGS += \
	-m 512M \
	-smp $(QEMU_SMP) \
	-no-reboot \
	-no-shutdown \
    -rtc base=localtime \
	-serial stdio \
    -boot order=d,menu=on,splash-time=0

ifeq ($(ILOBILIX_ARCH),x86_64)
override QEMU_ARGS += \
	-cpu max,migratable=off,+invtsc,+tsc-deadline \
	-M q35,smm=off
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
override QEMU_ARGS += \
	-cpu cortex-a72 \
	-M virt \
	-device ramfb
endif

ifeq ($(QEMU_ACCEL),ON)
ifneq ($(QEMU_LOG),ON)
ifneq ($(QEMU_GDB),ON)
override QEMU_ARGS += -M accel=kvm:hvf:whpx:haxm:tcg
endif
endif
endif
ifeq ($(QEMU_LOG),ON)
override QEMU_ARGS += -d int -D log.txt
endif
ifeq ($(QEMU_GDB),ON)
override QEMU_ARGS += -s -S
endif

.PHONY: error
error:
	@echo "Please RTFM"
	@exit 1

.PHONY: all
all: $(ISO_IMG)

.PHONY: kernel
kernel:
	$(MAKE) setup-kernel
	$(MAKE) build-kernel

$(KERNEL_ELF): kernel

.PHONY: sysroot
sysroot:
	$(MAKE) setup-sysroot
	$(MAKE) build-sysroot
	$(MAKE) install-sysroot

$(SYSROOT_DIR):
	$(MAKE) sysroot

.PHONY: initramfs
.NOTPARALLEL:
initramfs: $(SYSROOT_DIR) kernel # $(KERNEL_ELF)
	@rm -rvf $(SYSROOT_DIR)/usr/lib/modules
	@mkdir -vp $(SYSROOT_DIR)/usr/lib/modules
	@-cp -rv $(MODULES_DIR)/noarch $(SYSROOT_DIR)/usr/lib/modules/
	@-cp -rv $(MODULES_DIR)/$(ILOBILIX_ARCH) $(SYSROOT_DIR)/usr/lib/modules/
	tar --format ustar -cf $(INITRAMFS_IMG) -C $(SYSROOT_DIR) ./

$(INITRAMFS_IMG):
	$(MAKE) initramfs

.PHONY: iso
iso: initramfs # $(INITRAMFS_IMG)
	@rm -rvf $(ISO_DIR)
	@mkdir -vp $(ISO_DIR)/boot/limine
	@mkdir -vp $(ISO_DIR)/EFI/BOOT

	@cp -v $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	@cp -v $(INITRAMFS_IMG) $(ISO_DIR)/boot/initramfs.img
	@cp -v $(LIMINE_CONF) $(ISO_DIR)/boot

ifeq ($(ILOBILIX_ARCH),x86_64)
	@cp -v $(LIMINE_DIR)/limine-bios.sys $(LIMINE_DIR)/limine-bios-cd.bin $(LIMINE_DIR)/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	@cp -v $(LIMINE_DIR)/BOOTX64.EFI $(ISO_DIR)/EFI/BOOT/
	@cp -v $(LIMINE_DIR)/BOOTIA32.EFI $(ISO_DIR)/EFI/BOOT/
	@xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
		-apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $(ISO_IMG)
	$(LIMINE_EXEC) bios-install $(ISO_IMG)
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
	@cp -v $(LIMINE_DIR)/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	@cp -v $(LIMINE_DIR)/BOOTAA64.EFI $(ISO_DIR)/EFI/BOOT/
	@xorriso -as mkisofs -R -r -J \
		-hfsplus -apm-block-size 2048 \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $(ISO_IMG)
endif

$(ISO_IMG):
	$(MAKE) iso

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

.PHONY: config-sysroot
config-sysroot:
	$(BUILDROOT) menuconfig
	sed -i 's|^BR2_ROOTFS_SKELETON_CUSTOM_PATH=".*"$$|BR2_ROOTFS_SKELETON_CUSTOM_PATH="$(SYSROOT_SKELETON_DIR)"|' $(BUILDROOT_BUILD_DIR)/.config
	@cp -v $(BUILDROOT_BUILD_DIR)/.config $(BUILDROOT_CONFIG)

.PHONY: setup-sysroot
setup-sysroot:
ifndef OVERRIDE_SYSROOT_DIR
	@mkdir -vp $(BUILDROOT_BUILD_DIR)
	@cp -v $(BUILDROOT_CONFIG) $(BUILDROOT_BUILD_DIR)/.config
	$(BUILDROOT) oldconfig
endif

.PHONY: build-sysroot
build-sysroot:
ifndef OVERRIDE_SYSROOT_DIR
	$(BUILDROOT) all
endif

.PHONY: install-sysroot
install-sysroot:
ifndef OVERRIDE_SYSROOT_DIR
	@mkdir -vp $(SYSROOT_DIR)
	tar xf $(BUILDROOT_OUT_TAR) -C $(SYSROOT_DIR)
endif

.PHONY: clean-sysroot
clean-sysroot:
ifndef OVERRIDE_SYSROOT_DIR
	$(BUILDROOT) clean
endif

.PHONY: distclean-kernel
distclean-kernel:
	@rm -rvf $(KERNEL_BUILD_DIR)

.PHONY: distclean-sysroot
distclean-sysroot:
	$(BUILDROOT) distclean

.PHONY: clean-initramfs
clean-initramfs:
	@rm -v $(INITRAMFS_IMG)

.PHONY: clean-initramfs
distclean-initramfs:
	@rm -rvf $(INITRAMFS_IMG) $(MODULES_DIR)

.PHONY: clean-iso
clean-iso:
	@rm -v $(ISO_IMG)

# .PHONY: distclean
# distclean: distclean-kernel distclean-sysroot

.PHONY: run-iso
run-iso: run-iso-uefi

.PHONY: run-iso-uefi
run-iso-uefi:
	$(QEMU_EXEC) $(QEMU_ARGS) -bios $(OVMF_BIN) -cdrom $(ISO_IMG) | $(CXXFILT_EXE)

.PHONY: run-iso-bios
run-iso-bios:
	$(QEMU_EXEC) $(QEMU_ARGS) -cdrom $(ISO_IMG) | $(CXXFILT_EXE)