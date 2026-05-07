# Copyright (C) 2024-2026  ilobilo

ILOBILIX_ARCH ?= x86_64
ILOBILIX_BUILD_TYPE ?= ReleaseDbg
ILOBILIX_SYSCALL_LOG ?= OFF
ILOBILIX_LTO ?= OFF
ILOBILIX_LIMINE_MP ?= ON
ILOBILIX_UBSAN ?= OFF

ifeq ($(ILOBILIX_ARCH),x86_64)
override _GENTOO_ARCH := amd64
ILOBILIX_GENTOO_STAGE3_DATE ?= 20260503T164604Z
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
override _GENTOO_ARCH := arm64
ILOBILIX_GENTOO_STAGE3_DATE ?= 20260503T230109Z
endif

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

override GENTOO_STAGE3_TARBALL := stage3-$(_GENTOO_ARCH)-openrc-$(ILOBILIX_GENTOO_STAGE3_DATE).tar.xz
override GENTOO_STAGE3_URL := https://distfiles.gentoo.org/releases/$(_GENTOO_ARCH)/autobuilds/$(ILOBILIX_GENTOO_STAGE3_DATE)/$(GENTOO_STAGE3_TARBALL)
override GENTOO_STAGE3_CACHE := $(SYSROOT_CACHE_DIR)/$(GENTOO_STAGE3_TARBALL)

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
	-m 8G \
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
        clean-sysroot distclean-sysroot

$(GENTOO_STAGE3_CACHE):
	@mkdir -p $(SYSROOT_CACHE_DIR)
	@find $(SYSROOT_CACHE_DIR) -maxdepth 1 -name 'stage3-*-openrc-*.tar.xz' ! -name '$(GENTOO_STAGE3_TARBALL)' -delete
	@echo "Downloading $(GENTOO_STAGE3_TARBALL)"
	curl -fL --progress-bar -o $@ $(GENTOO_STAGE3_URL)

setup-sysroot: $(GENTOO_STAGE3_CACHE)

$(SYSROOT_DIR)/.extracted: $(GENTOO_STAGE3_CACHE)
	@rm -rf $(SYSROOT_DIR)
	@mkdir -p $(SYSROOT_DIR)
	tar -xpf $(GENTOO_STAGE3_CACHE) -C $(SYSROOT_DIR) --exclude='./dev/*'
	@touch $@

build-sysroot: $(SYSROOT_DIR)/.extracted

install-sysroot: build-sysroot
	$(SUPPORT_DIR)/sysroot-overlay.sh $(SOURCE_DIR)/base-files $(SYSROOT_DIR)

rebuild-sysroot:
	rm -rf $(SYSROOT_DIR)
	$(MAKE) install-sysroot

clean-sysroot:
	rm -rf $(SYSROOT_DIR)

distclean-sysroot:
	@rm -rf $(SYSROOT_DIR) $(SYSROOT_CACHE_DIR)

else

.PHONY: setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
        clean-sysroot distclean-sysroot
setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
clean-sysroot distclean-sysroot:
	@:

endif

.PHONY: sysroot
sysroot: install-sysroot

.PHONY: chroot-sysroot
chroot-sysroot:
	@if [ ! -d "$(SYSROOT_DIR)" ]; then \
		echo "sysroot not built; run 'make install-sysroot'" >&2; exit 1; \
	fi
	@command -v bwrap >/dev/null 2>&1 || { \
		echo "bwrap not found; install bubblewrap" >&2; exit 1; \
	}
	bwrap \
		--bind $(SYSROOT_DIR) / \
		--proc /proc --dev /dev \
		--bind /sys /sys \
		--tmpfs /tmp --tmpfs /run \
		--ro-bind /etc/resolv.conf /etc/resolv.conf \
		--ro-bind-try /etc/hosts /etc/hosts \
		--uid 0 --gid 0 \
		--unshare-all --share-net \
		--die-with-parent --chdir / \
		--setenv HOME /root \
		--setenv LANG C.UTF-8 \
		--setenv LC_ALL C.UTF-8 \
		--setenv PORTAGE_USERNAME root \
		--setenv PORTAGE_GRPNAME root \
		--setenv FEATURES "-userpriv -usersandbox -userfetch -usersync -ipc-sandbox -mount-sandbox -network-sandbox -pid-sandbox -sandbox" \
		/bin/bash

$(INITRAMFS_IMG): $(KERNEL_ELF) install-sysroot
	@rm -rf $(SYSROOT_DIR)/usr/lib/modules
	@mkdir -p $(MODULES_INSTALL_DIR)
	@-cp -r $(MODULES_DIR)/noarch/. $(MODULES_INSTALL_DIR)/
	@-cp -r $(MODULES_DIR)/$(ILOBILIX_ARCH)/. $(MODULES_INSTALL_DIR)/
	tar --format gnu --owner=0 --group=0 --numeric-owner \
		--exclude='./.extracted' --exclude='./home/ilobilix' \
		--exclude='./var/db' --exclude='./var/cache' \
		--exclude='./usr/lib/python3.13/site-packages/portage' \
		--exclude='./usr/lib/python3.13/site-packages/_emerge' \
		--exclude='./usr/lib/python3.14/site-packages/portage' \
		--exclude='./usr/lib/python3.14/site-packages/_emerge' \
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
