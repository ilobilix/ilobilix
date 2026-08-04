# Copyright (C) 2024-2026  ilobilo

# this file was heavily modified with the help of a clanker

ILOBILIX_ARCH ?= x86_64
ILOBILIX_BUILD_TYPE ?= ReleaseDbg
ILOBILIX_LTO ?= OFF
ILOBILIX_LIMINE_MP ?= ON
ILOBILIX_UBSAN ?= OFF
ILOBILIX_SCCACHE ?= OFF

ILOBILIX_DISK_ESP_SIZE_MB ?= 256
ILOBILIX_DISK_ROOT_SIZE_MB ?= 4096
ILOBILIX_DISK_PART_TABLE ?= gpt
ILOBILIX_ROOT_FSTYPE ?= ext2

ILOBILIX_VOID_ROOTFS_DATE ?= 20250202
ILOBILIX_VOID_INSTALL ?=
ILOBILIX_VOID_REMOVE ?=

ILOBILIX_FAKEROOT_BIN ?= $(if $(shell command -v fakeroot-sysv 2>/dev/null),fakeroot-sysv,fakeroot)

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
override STATE_DIR := $(BUILD_DIR)/state

ifdef ILOBILIX_SYSROOT_DIR
override SYSROOT_DIR := $(abspath $(ILOBILIX_SYSROOT_DIR))
endif

override FAKEROOT_SAVE := $(BUILD_DIR)/fakeroot.save
override FAKEROOT := $(ILOBILIX_FAKEROOT_BIN) $$(test -s $(FAKEROOT_SAVE) && echo -i $(FAKEROOT_SAVE)) -s $(FAKEROOT_SAVE) --
override FAKEROOT_LOAD := $(ILOBILIX_FAKEROOT_BIN) $$(test -s $(FAKEROOT_SAVE) && echo -i $(FAKEROOT_SAVE)) --

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
override LIMINE_URL := https://github.com/limine-bootloader/limine/releases/download/v$(LIMINE_VERSION)/limine-binary.tar.xz
override LIMINE_CACHE := $(LIMINE_CACHE_DIR)/$(LIMINE_TARBALL)
override LIMINE_DIR := $(LIMINE_CACHE_DIR)/limine-$(LIMINE_VERSION)
override LIMINE_EXEC := $(LIMINE_DIR)/limine
override LIMINE_CONF := $(SUPPORT_DIR)/limine.conf

override KERNEL_ELF := $(KERNEL_BUILD_DIR)/kernel/source/kernel_elf
override MODULES_BUILTIN := $(KERNEL_BUILD_DIR)/modules.builtin
override MODULES_BUILTIN_MODINFO := $(KERNEL_BUILD_DIR)/kernel/source/modules.builtin.modinfo
override MODULES_DIR := $(KERNEL_BUILD_DIR)/modules/modules
override MODULES_SOURCE_DIRS := $(MODULES_DIR)/noarch $(MODULES_DIR)/$(ILOBILIX_ARCH)

override INITRAMFS_IMG := $(BUILD_DIR)/initramfs.img
override INITRAMFS_FULL_IMG := $(BUILD_DIR)/initramfs-full.img
override ISO_IMG := $(BUILD_DIR)/image.iso
override DISK_IMG := $(BUILD_DIR)/image.img
override DISK_ESP_IMG := $(BUILD_DIR)/disk-esp.img
override DISK_ROOT_IMG := $(BUILD_DIR)/disk-root.img

override KERNEL_VERSION := $(shell sed -n '/project(/,/)/{s/.*\bVERSION[[:space:]]\+\([0-9][0-9.]*\).*/\1/p;}' $(KERNEL_SOURCE_DIR)/CMakeLists.txt | head -1)
ifeq ($(strip $(KERNEL_VERSION)),)
$(error unable to determine kernel version)
endif
override KERNEL_GIT_COMMIT := $(shell git -C $(KERNEL_SOURCE_DIR) rev-parse --short HEAD 2>/dev/null)
override ILOBILIX_RELEASE := $(KERNEL_VERSION)$(if $(KERNEL_GIT_COMMIT),-$(KERNEL_GIT_COMMIT),)
override MODULES_INSTALL_DIR := $(SYSROOT_DIR)/usr/lib/modules/$(ILOBILIX_RELEASE)

override DRACUT := $(SYSROOT_DIR)/usr/bin/dracut
override DRACUT_MODULES := base bash udev-rules kernel-modules rootfs-block fs-lib
override DRACUT_OMIT := drm resume
override DRACUT_RUN := $(DRACUT) --sysroot $(SYSROOT_DIR)
ifneq ($(ILOBILIX_ARCH),$(XBPS_HOST_ARCH))
override QEMU_USER := qemu-$(ILOBILIX_ARCH) -L $(SYSROOT_DIR)
override DRACUT_RUN := \
	DRACUT_INSTALL="$(QEMU_USER) $(SYSROOT_DIR)/usr/lib/dracut/dracut-install" \
	DRACUT_LDCONFIG="$(QEMU_USER) $(SYSROOT_DIR)/usr/bin/ldconfig" \
	$(DRACUT_RUN)
endif

override INITRAMFS_OVERLAY := /tmp/ilobilix-initramfs-overlay-$(ILOBILIX_ARCH)

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
	-rtc base=utc \
	-boot order=d,menu=on,splash-time=0 \
	-device virtio-keyboard-pci \
	-device virtio-tablet-pci \
	-chardev stdio,id=char0,signal=off,mux=on \
	-serial chardev:char0 \
	-mon chardev=char0,mode=readline
# 	-no-reboot \
# 	-no-shutdown \

override QEMU_DISK_ARGS := \
	-drive file=$(DISK_IMG),format=raw,if=none,id=drive-nvme0,cache=none \
	-device nvme,serial=deadbeef,drive=drive-nvme0
# 	-drive file=$(DISK_IMG),format=raw,if=none,id=drive-virtio0 \
# 	-device virtio-blk-pci,drive=drive-virtio0

ifeq ($(ILOBILIX_ARCH),x86_64)
override QEMU_ARGS += \
	-cpu max,migratable=off,+invtsc,+tsc-deadline \
	-M q35,smm=off \
	-debugcon file:$(BUILD_DIR)/kernel_log.txt
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
override QEMU_ARGS += -d int -D $(BUILD_DIR)/qemu_log.txt
endif
ifeq ($(QEMU_GDB),ON)
override QEMU_ARGS += -s -S
endif

.DEFAULT_GOAL := all

# helpers

.PHONY: FORCE
FORCE:

override COMMIT_STATE = if cmp -s "$@.tmp" "$@" 2>/dev/null; then rm -f "$@.tmp"; else mv -f "$@.tmp" "$@"; fi

override define REQUIRE_SYSROOT
@test -d "$(SYSROOT_DIR)" || { \
	echo "error: sysroot '$(SYSROOT_DIR)' is gone but its stamps remain;" >&2; \
	echo "       run 'make clean-sysroot' first" >&2; \
	exit 1; \
}
endef

override KERNEL_STATE := $(STATE_DIR)/kernel.state
override MODULES_STATE := $(STATE_DIR)/modules.state
override SYSROOT_INSTALL_STATE := $(STATE_DIR)/sysroot-install.state
override SYSROOT_EXTRACTED := $(STATE_DIR)/sysroot-extracted.stamp
override SYSROOT_INSTALLED := $(STATE_DIR)/sysroot-installed.stamp
override DRACUT_INSTALLED := $(STATE_DIR)/dracut-installed.stamp
override MODULES_INSTALLED := $(STATE_DIR)/modules-installed.stamp

.PHONY: all
all: $(DISK_IMG)

# kernel

.PHONY: setup-kernel build-kernel kernel clean-kernel distclean-kernel

setup-kernel:
	cmake -S $(KERNEL_SOURCE_DIR) -B $(KERNEL_BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(ILOBILIX_BUILD_TYPE) \
		-DILOBILIX_ARCH=$(ILOBILIX_ARCH) \
		-DILOBILIX_LTO=$(ILOBILIX_LTO) \
		-DILOBILIX_LIMINE_MP=$(ILOBILIX_LIMINE_MP) \
		-DILOBILIX_UBSAN=$(ILOBILIX_UBSAN) \
		-DILOBILIX_SCCACHE=$(ILOBILIX_SCCACHE)

$(KERNEL_STATE): FORCE | setup-kernel
	cmake --build $(KERNEL_BUILD_DIR)
	@test -f "$(KERNEL_ELF)"
	@mkdir -p $(STATE_DIR)
	@sha256sum "$(KERNEL_ELF)" > "$@.tmp"
	@$(COMMIT_STATE)

build-kernel: $(KERNEL_STATE)

kernel: build-kernel

clean-kernel:
	cmake --build $(KERNEL_BUILD_DIR) --target clean

distclean-kernel:
	@rm -rf $(KERNEL_BUILD_DIR) $(KERNEL_STATE) $(MODULES_STATE)

$(MODULES_STATE): FORCE | $(KERNEL_STATE)
	@mkdir -p $(STATE_DIR)
	@{ \
		sha256sum "$(MODULES_BUILTIN)" "$(MODULES_BUILTIN_MODINFO)"; \
		for dir in $(MODULES_SOURCE_DIRS); do \
			test -d "$$dir" || continue; \
			(cd "$$dir" && find . -type f -name '*.ko' -exec sha256sum {} +); \
		done; \
	} | LC_ALL=C sort > "$@.tmp"
	@$(COMMIT_STATE)

# sysroot

ifndef ILOBILIX_SYSROOT_DIR

.PHONY: setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
        xbps-bootstrap clean-sysroot distclean-sysroot

$(VOID_ROOTFS_CACHE):
	@mkdir -p $(SYSROOT_CACHE_DIR)
	@find $(SYSROOT_CACHE_DIR) -maxdepth 1 \
		-name 'void-*-ROOTFS-*.tar.xz' ! -name '$(VOID_ROOTFS_TARBALL)' -delete
	@echo "Downloading $(VOID_ROOTFS_TARBALL)"
	curl -fL --progress-bar -o $@ $(VOID_ROOTFS_URL)

setup-sysroot: $(VOID_ROOTFS_CACHE)

$(SYSROOT_EXTRACTED): $(VOID_ROOTFS_CACHE)
	@rm -rf $(SYSROOT_DIR)
	@mkdir -p $(SYSROOT_DIR) $(STATE_DIR)
	@: > $(FAKEROOT_SAVE)
	$(FAKEROOT) tar -xpf $(VOID_ROOTFS_CACHE) -C $(SYSROOT_DIR)
	@touch $@

build-sysroot: $(SYSROOT_EXTRACTED)

$(SYSROOT_INSTALL_STATE): FORCE
	@mkdir -p $(STATE_DIR)
	@{ \
		printf 'void-install=%s\n' '$(strip $(ILOBILIX_VOID_INSTALL))'; \
		printf 'void-remove=%s\n' '$(strip $(ILOBILIX_VOID_REMOVE))'; \
		if test -d "$(SOURCE_DIR)/base-files"; then \
			cd "$(SOURCE_DIR)/base-files" && \
			find . -printf '%y %m %P -> %l\n' | LC_ALL=C sort && \
			find . -type f -exec sha256sum {} + | LC_ALL=C sort; \
		fi; \
	} > "$@.tmp"
	@$(COMMIT_STATE)

override INSTALL_DEPS := $(SYSROOT_EXTRACTED) $(SYSROOT_INSTALL_STATE)
ifneq ($(strip $(ILOBILIX_VOID_INSTALL))$(strip $(ILOBILIX_VOID_REMOVE)),)
override INSTALL_DEPS += $(XBPS_BIN)/xbps-install
endif

$(SYSROOT_INSTALLED): $(INSTALL_DEPS)
	$(REQUIRE_SYSROOT)
	$(FAKEROOT) $(SUPPORT_DIR)/sysroot-overlay.sh $(SOURCE_DIR)/base-files $(SYSROOT_DIR)
ifneq ($(strip $(ILOBILIX_VOID_INSTALL))$(strip $(ILOBILIX_VOID_REMOVE)),)
	$(FAKEROOT) sh -c '$(XBPS_INSTALL) -Syu xbps'
endif
ifneq ($(strip $(ILOBILIX_VOID_REMOVE)),)
	$(FAKEROOT) sh -c '$(XBPS_REMOVE) -Ry $(ILOBILIX_VOID_REMOVE)'
endif
ifneq ($(strip $(ILOBILIX_VOID_INSTALL)),)
	$(FAKEROOT) sh -c '$(XBPS_INSTALL) -y $(ILOBILIX_VOID_INSTALL)'
endif
	@touch $@

install-sysroot: $(SYSROOT_INSTALLED)

$(DRACUT_INSTALLED): $(SYSROOT_EXTRACTED) $(XBPS_BIN)/xbps-install | $(SYSROOT_INSTALLED)
	$(REQUIRE_SYSROOT)
	$(FAKEROOT) sh -c '$(XBPS_INSTALL) -Syu xbps'
	@set -e; \
	upgrades="$$($(XBPS_INSTALL) -Syun \
		| awk '$$2 == "update" { print $$1 }' \
		| sed 's/-[^-]*$$//' | tr '\n' ' ')"; \
	$(FAKEROOT) env $(XBPS_ENV) $(XBPS_BIN)/xbps-install \
		-R $(VOID_REPO_URL) -r $(SYSROOT_DIR) -Syu; \
	if test -n "$$upgrades"; then \
		$(FAKEROOT) env $(XBPS_ENV) $(XBPS_BIN)/xbps-install \
			-R $(VOID_REPO_URL) -r $(SYSROOT_DIR) -yf $$upgrades; \
	fi
	$(FAKEROOT) sh -c '$(XBPS_INSTALL) -Sy dracut'
	@mkdir -p $(SYSROOT_DIR)/usr/lib/systemd
	@ln -sfn ../../bin/udevd $(SYSROOT_DIR)/usr/lib/systemd/systemd-udevd
	@touch $@

rebuild-sysroot: clean-sysroot
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
	rm -rf $(SYSROOT_DIR) $(FAKEROOT_SAVE) $(SYSROOT_EXTRACTED) \
		$(SYSROOT_INSTALLED) $(DRACUT_INSTALLED) $(MODULES_INSTALLED) \
		$(SYSROOT_INSTALL_STATE)

distclean-sysroot: clean-sysroot
	@rm -rf $(SYSROOT_CACHE_DIR) $(XBPS_DIR)

else # ILOBILIX_SYSROOT_DIR

override SYSROOT_EXTRACTED :=
override SYSROOT_INSTALLED :=
override DRACUT_INSTALLED :=

.PHONY: setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
        xbps-bootstrap clean-sysroot distclean-sysroot
setup-sysroot build-sysroot install-sysroot rebuild-sysroot \
xbps-bootstrap clean-sysroot distclean-sysroot:
	@:

endif # ILOBILIX_SYSROOT_DIR

.PHONY: sysroot
sysroot: install-sysroot

# modules

$(MODULES_INSTALLED): $(MODULES_STATE) $(SYSROOT_EXTRACTED) | $(DRACUT_INSTALLED)
	$(REQUIRE_SYSROOT)
	$(FAKEROOT) sh -c ' \
		rm -rf "$(SYSROOT_DIR)/usr/lib/modules" && \
		mkdir -p "$(MODULES_INSTALL_DIR)" && \
		for dir in $(MODULES_SOURCE_DIRS); do \
			test -d "$$dir" || continue; \
			(cd "$$dir" && find . -type f -name "*.ko" \
				-exec cp -a --parents {} "$(MODULES_INSTALL_DIR)" \;); \
		done && \
		cp "$(MODULES_BUILTIN)" "$(MODULES_BUILTIN_MODINFO)" "$(MODULES_INSTALL_DIR)/" && \
		(cd "$(MODULES_INSTALL_DIR)" && \
			find . -type f -name "*.ko" -printf "%P\n" | LC_ALL=C sort > modules.order) && \
		depmod -b "$(SYSROOT_DIR)" "$(ILOBILIX_RELEASE)"'
	@touch $@

.PHONY: modules
modules: $(MODULES_INSTALLED)

# initramfs

$(INITRAMFS_IMG): $(MODULES_INSTALLED) $(SYSROOT_INSTALLED) $(DRACUT_INSTALLED)
	$(REQUIRE_SYSROOT)
	@set -e; \
	mkdir -p "$(INITRAMFS_OVERLAY)/usr/lib64" "$(SYSROOT_DIR)$(INITRAMFS_OVERLAY)/usr/lib64"; \
	ln -sfn ../lib/udev "$(SYSROOT_DIR)$(INITRAMFS_OVERLAY)/usr/lib64/udev"; \
	drivers="$$(find "$(MODULES_INSTALL_DIR)" -type f -name '*.ko' -printf '%f\n' \
		| sed 's/\.ko$$//' | LC_ALL=C sort -u | tr '\n' ' ')"; \
	fsdrivers="$$(awk '$$1 == "alias" && $$2 ~ /^fs-/ { print $$3 }' \
		"$(MODULES_INSTALL_DIR)/modules.alias" | LC_ALL=C sort -u | tr '\n' ' ')"; \
	set --; \
	if test -n "$$drivers"; then set -- --add-drivers "$$drivers"; fi; \
	if test -n "$$fsdrivers"; then set -- "$$@" --force-drivers "$$fsdrivers"; fi; \
	rc=0; \
	$(DRACUT_RUN) --force --no-hostonly --no-compress \
		--add "$(DRACUT_MODULES)" --omit "$(DRACUT_OMIT)" \
		--include "$(INITRAMFS_OVERLAY)" / \
		"$$@" --kver "$(ILOBILIX_RELEASE)" "$@" || rc=$$?; \
	rm -rf "$(SYSROOT_DIR)$(INITRAMFS_OVERLAY)"; \
	exit $$rc

$(INITRAMFS_FULL_IMG): $(MODULES_INSTALLED) $(SYSROOT_INSTALLED)
	$(REQUIRE_SYSROOT)
	@rm -f $@
	$(FAKEROOT_LOAD) sh -c ' \
		if [ -d "$(SYSROOT_DIR)/home/ilobilix" ]; then \
			chown -R 1000:1000 "$(SYSROOT_DIR)/home/ilobilix"; \
		fi; \
		tar --format gnu --numeric-owner -cf "$@" -C "$(SYSROOT_DIR)" ./'

.PHONY: initramfs initramfs-full clean-initramfs distclean-initramfs
initramfs: $(INITRAMFS_IMG)
initramfs-full: $(INITRAMFS_FULL_IMG)

clean-initramfs:
	@rm -f $(INITRAMFS_IMG) $(INITRAMFS_FULL_IMG)

distclean-initramfs: clean-initramfs
	@rm -rf $(MODULES_DIR) $(MODULES_STATE) $(MODULES_INSTALLED)

# limine

$(LIMINE_CACHE):
	@mkdir -p $(LIMINE_CACHE_DIR)
	@find $(LIMINE_CACHE_DIR) -maxdepth 1 \
		-name 'limine-binary-*.tar.xz' ! -name '$(LIMINE_TARBALL)' -delete
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

# iso

$(ISO_IMG): $(KERNEL_STATE) $(INITRAMFS_FULL_IMG) $(LIMINE_CONF) $(LIMINE_EXEC)
	@rm -rf $(ISO_DIR)
	@mkdir -p $(ISO_DIR)/boot/limine $(ISO_DIR)/EFI/BOOT
	@cp $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	@cp $(INITRAMFS_FULL_IMG) $(ISO_DIR)/boot/initramfs.img
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

# disk

$(DISK_ESP_IMG): $(KERNEL_STATE) $(INITRAMFS_IMG) $(LIMINE_CONF) $(LIMINE_EXEC)
	@rm -f $@
	truncate -s $(ILOBILIX_DISK_ESP_SIZE_MB)M $@
	mformat -i $@ -F -v ESP ::
	mmd -i $@ ::/boot ::/boot/limine ::/EFI ::/EFI/BOOT
	mcopy -i $@ $(KERNEL_ELF) ::/boot/kernel.elf
	mcopy -i $@ $(INITRAMFS_IMG) ::/boot/initramfs.img
	mcopy -i $@ $(LIMINE_CONF) ::/boot/
ifeq ($(ILOBILIX_ARCH),x86_64)
	mcopy -i $@ $(LIMINE_DIR)/limine-bios.sys ::/boot/limine/
	mcopy -i $@ $(LIMINE_DIR)/BOOTX64.EFI ::/EFI/BOOT/
	mcopy -i $@ $(LIMINE_DIR)/BOOTIA32.EFI ::/EFI/BOOT/
endif
ifeq ($(ILOBILIX_ARCH),aarch64)
	mcopy -i $@ $(LIMINE_DIR)/BOOTAA64.EFI ::/EFI/BOOT/
endif

$(DISK_ROOT_IMG): $(MODULES_INSTALLED) $(SYSROOT_INSTALLED) | $(INITRAMFS_IMG)
	$(REQUIRE_SYSROOT)
	@rm -f $@
	truncate -s $(ILOBILIX_DISK_ROOT_SIZE_MB)M $@
	$(FAKEROOT_LOAD) sh -c ' \
		if [ -d "$(SYSROOT_DIR)/home/ilobilix" ]; then \
			chown -R 1000:1000 "$(SYSROOT_DIR)/home/ilobilix"; \
		fi; \
		mke2fs -q -t $(ILOBILIX_ROOT_FSTYPE) -F -L ilobilix-root -d "$(SYSROOT_DIR)" "$@"'

$(DISK_IMG): $(DISK_ESP_IMG) $(DISK_ROOT_IMG) $(LIMINE_EXEC)
	@rm -f $(DISK_IMG)
	truncate -s $$(( ($(ILOBILIX_DISK_ESP_SIZE_MB) + $(ILOBILIX_DISK_ROOT_SIZE_MB) + 3) * 1024 * 1024 )) $(DISK_IMG)
ifeq ($(ILOBILIX_DISK_PART_TABLE),gpt)
	sgdisk --clear \
		--new=1:2048:+1M --typecode=1:ef02 --change-name=1:"BIOS boot" \
		--attributes=1:set:2 \
		--new=2:0:+$(ILOBILIX_DISK_ESP_SIZE_MB)M --typecode=2:ef00 --change-name=2:"EFI System" \
		--attributes=2:set:0 \
		--new=3:0:+$(ILOBILIX_DISK_ROOT_SIZE_MB)M --typecode=3:8300 --change-name=3:"ilobilix-root" \
		$(DISK_IMG)
else ifeq ($(ILOBILIX_DISK_PART_TABLE),mbr)
	parted -s $(DISK_IMG) \
		mklabel msdos \
		mkpart primary fat32 2MiB $$(( $(ILOBILIX_DISK_ESP_SIZE_MB) + 2 ))MiB \
		set 1 boot on \
		type 1 0xef \
		mkpart primary ext2 $$(( $(ILOBILIX_DISK_ESP_SIZE_MB) + 2 ))MiB 100% \
		type 2 0x83
else
	$(error unsupported partition table format '$(ILOBILIX_DISK_PART_TABLE)', use 'gpt' or 'mbr')
endif
	dd if=$(DISK_ESP_IMG) of=$(DISK_IMG) bs=4M oflag=seek_bytes seek=$$(( 2 * 1024 * 1024 )) conv=notrunc,sparse status=none
	dd if=$(DISK_ROOT_IMG) of=$(DISK_IMG) bs=4M oflag=seek_bytes seek=$$(( ($(ILOBILIX_DISK_ESP_SIZE_MB) + 2) * 1024 * 1024 )) conv=notrunc,sparse status=none
ifeq ($(ILOBILIX_ARCH),x86_64)
	$(LIMINE_EXEC) bios-install $(DISK_IMG)
endif

.PHONY: disk disk-esp disk-root clean-disk
disk: $(DISK_IMG)
disk-esp: $(DISK_ESP_IMG)
disk-root: $(DISK_ROOT_IMG)

clean-disk:
	@rm -f $(DISK_IMG) $(DISK_ESP_IMG) $(DISK_ROOT_IMG)

.PHONY: clean distclean
clean: clean-kernel clean-initramfs clean-iso clean-disk clean-limine

distclean: distclean-kernel distclean-sysroot distclean-initramfs \
           distclean-limine clean-iso clean-disk
	@rm -rf $(STATE_DIR)

.PHONY: run run-uefi run-bios
run: run-uefi

run-uefi:
	$(QEMU_EXEC) $(QEMU_ARGS) $(QEMU_DISK_ARGS) -bios $(OVMF_BIN)

run-bios:
	$(QEMU_EXEC) $(QEMU_ARGS) $(QEMU_DISK_ARGS)

.PHONY: run-iso run-iso-uefi run-iso-bios
run-iso: run-iso-uefi

run-iso-uefi:
	$(QEMU_EXEC) $(QEMU_ARGS) -bios $(OVMF_BIN) -cdrom $(ISO_IMG)

run-iso-bios:
	$(QEMU_EXEC) $(QEMU_ARGS) -cdrom $(ISO_IMG)
