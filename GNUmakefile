# Copyright (C) 2024-2026  ilobilo

ILOBILIX_ARCH ?= x86_64
ILOBILIX_BUILD_TYPE ?= ReleaseDbg
ILOBILIX_SYSCALL_LOG ?= OFF
ILOBILIX_LTO ?= OFF
ILOBILIX_LIMINE_MP ?= ON
ILOBILIX_UBSAN ?= OFF

ILOBILIX_VOID_ROOTFS_DATE ?= 20250202
ILOBILIX_VOID_INSTALL ?=
ILOBILIX_VOID_REMOVE ?=

QEMU_ACCEL ?= ON
QEMU_LOG ?= OFF
QEMU_GDB ?= OFF
QEMU_SMP ?= 6

override SOURCE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
override KERNEL_SOURCE_DIR := $(SOURCE_DIR)/kernel
override SUPPORT_DIR := $(SOURCE_DIR)/support

override BUILD_DIR := $(SOURCE_DIR)/build-$(ILOBILIX_ARCH)
override KERNEL_BUILD_DIR := $(BUILD_DIR)/kernel
override SYSROOT_DIR := $(BUILD_DIR)/sysroot
override SYSROOT_CACHE_DIR := $(BUILD_DIR)/sysroot-cache
override ISO_DIR := $(BUILD_DIR)/iso

ifdef ILOBILIX_SYSROOT_DIR
override SYSROOT_DIR := $(abspath $(ILOBILIX_SYSROOT_DIR))
endif

override VOID_ROOTFS_TARBALL := void-$(ILOBILIX_ARCH)-ROOTFS-$(ILOBILIX_VOID_ROOTFS_DATE).tar.xz
override VOID_ROOTFS_URL := https://repo-default.voidlinux.org/live/$(ILOBILIX_VOID_ROOTFS_DATE)/$(VOID_ROOTFS_TARBALL)
override VOID_ROOTFS_CACHE := $(SYSROOT_CACHE_DIR)/$(VOID_ROOTFS_TARBALL)

ifeq ($(ILOBILIX_ARCH),x86_64)
override VOID_REPO_URL := https://repo-default.voidlinux.org/current
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
override VOID_REPO_URL := https://repo-default.voidlinux.org/current/aarch64
endif

override XBPS_HOST_ARCH := $(shell uname -m)
override XBPS_DIR := $(BUILD_DIR)/xbps
override XBPS_BIN := $(XBPS_DIR)/usr/bin
override XBPS_TARBALL := $(SYSROOT_CACHE_DIR)/xbps-static-$(XBPS_HOST_ARCH).tar.xz
override XBPS_URL := https://repo-default.voidlinux.org/static/xbps-static-latest.$(XBPS_HOST_ARCH)-musl.tar.xz

override CA_BUNDLE := $(firstword $(wildcard \
	/etc/ssl/certs/ca-certificates.crt \
	/etc/ssl/certs/ca-bundle.crt \
	/etc/pki/tls/certs/ca-bundle.crt \
	/etc/ssl/cert.pem))
override XBPS_ENV := XBPS_TARGET_ARCH=$(ILOBILIX_ARCH)
ifneq ($(CA_BUNDLE),)
override XBPS_ENV += SSL_CA_CERT_FILE=$(CA_BUNDLE)
endif

override XBPS_INSTALL := $(XBPS_ENV) $(XBPS_BIN)/xbps-install -R $(VOID_REPO_URL) -r $(SYSROOT_DIR)
override XBPS_REMOVE := $(XBPS_ENV) $(XBPS_BIN)/xbps-remove -r $(SYSROOT_DIR)

override LIMINE_VERSION := 12.1.0
override LIMINE_CACHE_DIR := $(SUPPORT_DIR)/limine
override LIMINE_TARBALL := limine-binary-$(LIMINE_VERSION).tar.xz
override LIMINE_URL := https://github.com/Limine-Bootloader/Limine/releases/download/v$(LIMINE_VERSION)/limine-binary.tar.xz
override LIMINE_CACHE := $(LIMINE_CACHE_DIR)/$(LIMINE_TARBALL)
override LIMINE_DIR := $(LIMINE_CACHE_DIR)/limine-$(LIMINE_VERSION)
override LIMINE_EXEC := $(LIMINE_DIR)/limine
override LIMINE_CONF := $(SUPPORT_DIR)/limine.conf

override KERNEL_ELF := $(KERNEL_BUILD_DIR)/kernel/source/kernel_elf
override MODULES_DIR := $(KERNEL_BUILD_DIR)/modules/modules
override INITRAMFS_IMG := $(BUILD_DIR)/initramfs.tar
override ISO_IMG := $(BUILD_DIR)/image.iso

override KERNEL_VERSION := $(shell sed -n '/project(/,/)/{s/.*\bVERSION[[:space:]]\+\([0-9][0-9.]*\).*/\1/p;}' $(KERNEL_SOURCE_DIR)/CMakeLists.txt | head -1)
override KERNEL_GIT_COMMIT := $(shell git -C $(KERNEL_SOURCE_DIR) rev-parse --short HEAD 2>/dev/null)
override ILOBILIX_RELEASE := $(KERNEL_VERSION)$(if $(KERNEL_GIT_COMMIT),-$(KERNEL_GIT_COMMIT),)
override MODULES_INSTALL_DIR := $(SYSROOT_DIR)/usr/lib/modules/$(ILOBILIX_RELEASE)

override OVMF_DIR := $(SUPPORT_DIR)/ovmf-binaries
ifeq ($(ILOBILIX_ARCH),x86_64)
override OVMF_BIN := $(OVMF_DIR)/OVMF_X64.fd
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
override OVMF_BIN := $(OVMF_DIR)/OVMF_AA64.fd
endif

override QEMU_EXEC := qemu-system-$(ILOBILIX_ARCH)
override QEMU_ARGS += \
	-m 4G \
	-smp $(QEMU_SMP) \
	-no-reboot \
	-no-shutdown \
	-rtc base=utc \
	-boot order=d,menu=on,splash-time=0 \
	-device virtio-keyboard-pci \
	-device virtio-tablet-pci \
	-chardev stdio,id=char0,signal=off,mux=on \
	-serial chardev:char0 \
	-mon chardev=char0,mode=readline
# 	-debugcon file:$(BUILD_DIR)/syscall_log.txt

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
override QEMU_ARGS += -d int -D $(BUILD_DIR)/log.txt
endif
ifeq ($(QEMU_GDB),ON)
override QEMU_ARGS += -s -S
endif

.PHONY: all
all: $(ISO_IMG)

.PHONY: setup-kernel build-kernel kernel clean-kernel distclean-kernel
setup-kernel:
	cmake -S $(KERNEL_SOURCE_DIR) -B $(KERNEL_BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(ILOBILIX_BUILD_TYPE) \
		-DILOBILIX_ARCH=$(ILOBILIX_ARCH) \
		-DILOBILIX_SYSCALL_LOG=$(ILOBILIX_SYSCALL_LOG) \
		-DILOBILIX_LTO=$(ILOBILIX_LTO) \
		-DILOBILIX_LIMINE_MP=$(ILOBILIX_LIMINE_MP) \
		-DILOBILIX_UBSAN=$(ILOBILIX_UBSAN)

build-kernel: setup-kernel
	cmake --build $(KERNEL_BUILD_DIR)

kernel: build-kernel

$(KERNEL_ELF): build-kernel

clean-kernel:
	cmake --build $(KERNEL_BUILD_DIR) --target clean

distclean-kernel:
	@rm -rf $(KERNEL_BUILD_DIR)

ifndef ILOBILIX_SYSROOT_DIR

.PHONY: setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
        xbps-bootstrap clean-sysroot distclean-sysroot

$(VOID_ROOTFS_CACHE):
	@mkdir -p $(SYSROOT_CACHE_DIR)
	@find $(SYSROOT_CACHE_DIR) -maxdepth 1 -name 'void-*-ROOTFS-*.tar.xz' ! -name '$(VOID_ROOTFS_TARBALL)' -delete
	@echo "Downloading $(VOID_ROOTFS_TARBALL)"
	curl -fL --progress-bar -o $@ $(VOID_ROOTFS_URL)

setup-sysroot: $(VOID_ROOTFS_CACHE)

$(SYSROOT_DIR)/.extracted: $(VOID_ROOTFS_CACHE)
	@rm -rf $(SYSROOT_DIR)
	@mkdir -p $(SYSROOT_DIR)
	tar -xpf $(VOID_ROOTFS_CACHE) -C $(SYSROOT_DIR)
	@touch $@

build-sysroot: $(SYSROOT_DIR)/.extracted

INSTALL_DEPS := build-sysroot
ifneq ($(strip $(ILOBILIX_VOID_INSTALL))$(strip $(ILOBILIX_VOID_REMOVE)),)
INSTALL_DEPS += xbps-bootstrap
endif

install-sysroot: $(INSTALL_DEPS)
	$(SUPPORT_DIR)/sysroot-overlay.sh $(SOURCE_DIR)/base-files $(SYSROOT_DIR)
ifneq ($(strip $(ILOBILIX_VOID_INSTALL))$(strip $(ILOBILIX_VOID_REMOVE)),)
	$(XBPS_INSTALL) -Syu xbps
endif
ifneq ($(strip $(ILOBILIX_VOID_REMOVE)),)
	$(XBPS_REMOVE) -Ry $(ILOBILIX_VOID_REMOVE)
endif
ifneq ($(strip $(ILOBILIX_VOID_INSTALL)),)
	$(XBPS_INSTALL) -y $(ILOBILIX_VOID_INSTALL)
endif

rebuild-sysroot:
	rm -rf $(SYSROOT_DIR)
	$(MAKE) install-sysroot

xbps-bootstrap: $(XBPS_BIN)/xbps-install

$(XBPS_BIN)/xbps-install:
	@mkdir -p $(XBPS_DIR) $(SYSROOT_CACHE_DIR)
	@if [ ! -f $(XBPS_TARBALL) ]; then \
		echo "Downloading xbps-static for $(XBPS_HOST_ARCH)"; \
		curl -fL --progress-bar -o $(XBPS_TARBALL) $(XBPS_URL); \
	fi
	tar -xf $(XBPS_TARBALL) -C $(XBPS_DIR)

clean-sysroot:
	rm -rf $(SYSROOT_DIR)

distclean-sysroot:
	@rm -rf $(SYSROOT_DIR) $(SYSROOT_CACHE_DIR) $(XBPS_DIR)

else

.PHONY: setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
        xbps-bootstrap clean-sysroot distclean-sysroot
setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
xbps-bootstrap clean-sysroot distclean-sysroot:
	@:

endif

.PHONY: sysroot
sysroot: install-sysroot

$(INITRAMFS_IMG): $(KERNEL_ELF) install-sysroot
	@rm -rf $(SYSROOT_DIR)/usr/lib/modules
	@mkdir -p $(MODULES_INSTALL_DIR)
	@-cp -r $(MODULES_DIR)/noarch/. $(MODULES_INSTALL_DIR)/
	@-cp -r $(MODULES_DIR)/$(ILOBILIX_ARCH)/. $(MODULES_INSTALL_DIR)/
	tar --format gnu --owner=0 --group=0 --numeric-owner \
		--exclude='./.extracted' --exclude='./home/ilobilix' \
		-cf $@ -C $(SYSROOT_DIR) ./
	tar --format gnu --owner=1000 --group=1000 --numeric-owner \
		-cf $(BUILD_DIR)/initramfs-ilobilix.tar -C $(SYSROOT_DIR) ./home/ilobilix
	tar --concatenate -f $@ $(BUILD_DIR)/initramfs-ilobilix.tar
	@rm -f $(BUILD_DIR)/initramfs-ilobilix.tar

.PHONY: initramfs clean-initramfs distclean-initramfs
initramfs: $(INITRAMFS_IMG)

clean-initramfs:
	@rm -f $(INITRAMFS_IMG)

distclean-initramfs:
	@rm -rf $(INITRAMFS_IMG) $(MODULES_DIR)

$(LIMINE_CACHE):
	@mkdir -p $(LIMINE_CACHE_DIR)
	@find $(LIMINE_CACHE_DIR) -maxdepth 1 -name 'limine-binary-*.tar.xz' ! -name '$(LIMINE_TARBALL)' -delete
	@echo "Downloading $(LIMINE_TARBALL)"
	curl -fL --progress-bar -o $@ $(LIMINE_URL)

$(LIMINE_DIR)/.extracted: $(LIMINE_CACHE)
	@rm -rf $(LIMINE_DIR)
	@mkdir -p $(LIMINE_DIR)
	tar -xpf $(LIMINE_CACHE) -C $(LIMINE_DIR) --strip-components=1
	@touch $@

$(LIMINE_EXEC): $(LIMINE_DIR)/.extracted
	$(MAKE) -C $(LIMINE_DIR)
	@touch $@

.PHONY: limine clean-limine distclean-limine
limine: $(LIMINE_EXEC)

clean-limine:
	@rm -rf $(LIMINE_DIR)

distclean-limine:
	@rm -rf $(LIMINE_CACHE_DIR)

$(ISO_IMG): $(KERNEL_ELF) $(INITRAMFS_IMG) $(LIMINE_CONF) $(LIMINE_EXEC)
	@rm -rf $(ISO_DIR)
	@mkdir -p $(ISO_DIR)/boot/limine $(ISO_DIR)/EFI/BOOT
	@cp $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	@cp $(INITRAMFS_IMG) $(ISO_DIR)/boot/initramfs.img
	@cp $(LIMINE_CONF) $(ISO_DIR)/boot
ifeq ($(ILOBILIX_ARCH),x86_64)
	@cp $(LIMINE_DIR)/limine-bios.sys $(LIMINE_DIR)/limine-bios-cd.bin $(LIMINE_DIR)/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	@cp $(LIMINE_DIR)/BOOTX64.EFI $(ISO_DIR)/EFI/BOOT/
	@cp $(LIMINE_DIR)/BOOTIA32.EFI $(ISO_DIR)/EFI/BOOT/
	xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
		-apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $@
	$(LIMINE_EXEC) bios-install $@
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
	@cp $(LIMINE_DIR)/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	@cp $(LIMINE_DIR)/BOOTAA64.EFI $(ISO_DIR)/EFI/BOOT/
	xorriso -as mkisofs -R -r -J \
		-hfsplus -apm-block-size 2048 \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $@
endif

.PHONY: iso clean-iso
iso: $(ISO_IMG)

clean-iso:
	@rm -f $(ISO_IMG)

# .PHONY: distclean
# distclean: distclean-kernel distclean-sysroot

.PHONY: run-iso run-iso-uefi run-iso-bios
run-iso: run-iso-uefi

run-iso-uefi:
	$(QEMU_EXEC) $(QEMU_ARGS) -bios $(OVMF_BIN) -cdrom $(ISO_IMG)

run-iso-bios:
	$(QEMU_EXEC) $(QEMU_ARGS) -cdrom $(ISO_IMG)
