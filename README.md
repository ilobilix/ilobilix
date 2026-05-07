# Ilobilix
Monolithic Hobby OS in modern C++ 23 utilising modules where possible. It has support for custom loadable kernel modules. Its userspace aims to be ABI compatible with GNU/Linux.

Contributors are welcome! Feel free to open issues or submit pull requests.

> [!NOTE]
> This repo contains files needed to build and run the OS. Kernel source code is located in [ilobilix/kernel](https://github.com/ilobilix/kernel)

## License: [EUPL v1.2](LICENSE)

![x86_64](screenshots/x86_64.png "x86_64")

## Building And Running
* Make sure you are running an up-to-date Linux system and have following programs installed:
  * ``clang`` (21+)
  * ``clang-scan-deps`` (``clang-tools-extra``)
  * ``lld``
  * ``llvm``
  * ``make``
  * ``cmake``
  * ``ninja``
  * ``xorriso``
  * ``qemu-system``
  * ``curl``
  * ``tar``
  * ``bubblewrap`` (only needed for ``make chroot-sysroot``)
* Clone this repository:
  * ``git clone https://github.com/ilobilix/ilobilix --recursive``
* Build Ilobilix:
  * ``make all``
* Run the OS in QEMU:
  * ``make run-iso``
  * You can exit QEMU in the terminal with: ``ctrl+a x``
* Add packages to the sysroot (unprivileged):
  * ``make chroot-sysroot`` drops you into a ``bwrap`` chroot of the Gentoo sysroot as root, with networking
  * Inside, run ``getuto`` once, then ``emerge --sync && emerge -avG <pkg>``

## Configurable Environment Variables
> [!NOTE]
> Default values are enclosed in ``<>``

### Shared Options
* ``ILOBILIX_ARCH=[<x86_64>|aarch64]``

### Build-Only Options
* ``ILOBILIX_BUILD_TYPE=[Release|<ReleaseDbg>|Debug]``
* ``ILOBILIX_LTO=[ON|<OFF>]`` (Requires 'Release' build type)
* ``ILOBILIX_SYSCALL_LOG=[ON|<OFF>]``
* ``ILOBILIX_LIMINE_MP=[<ON>|OFF]``
* ``ILOBILIX_UBSAN=[ON|<OFF>]``
* ``ILOBILIX_GENTOO_STAGE3_DATE=<stage3 timestamp>``
* ``ILOBILIX_SYSROOT_DIR=<unset>``

### Run-Only Options
* ``QEMU_SMP=<6>``
* ``QEMU_ACCEL=[<ON>|OFF]``
* ``QEMU_LOG=[ON|<OFF>]``
* ``QEMU_GDB=[ON|<OFF>]``

### Directory Structure
```text
ilobilix/
├── kernel/                # Ilobilix kernel repository
├──── kernel/kernel/       # ─ Kernel source code
├──── kernel/modules/      # ─ Loadable kernel modules
├── base-files/            # Customisations applied on top of the Gentoo stage3 sysroot
├──── base-files/overlay/  # ─ Files copied onto the sysroot
├──── base-files/append/   # ─ Files whose lines are appended to the ones in the sysroot
├──── base-files/remove    # ─ Paths to delete from the sysroot
├── support/               # Various files for the build system
```

### Notable Projects Used:
* [Limine](https://codeberg.org/Limine/Limine)
* [uACPI](https://github.com/uACPI/uACPI)
* [Fmtlib](https://github.com/fmtlib/fmt)
* [Gentoo](https://www.gentoo.org/)

## Known Bugs
* mp booting not working on ``aarch64``
* unconfirmed: sometimes sleeping thread doesn't wake up on bare metal
* unconfirmed: slab allocator memory mapping breaks on that one laptop
