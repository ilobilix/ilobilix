# Ilobilix
Hobby OS in modern C++

## License: [EUPL v1.2](LICENSE)

## Building And Running
* ``git clone https://github.com/ilobilix/ilobilix --recursive``
* ``make all`` to build the kernel and userspace
* ``make run-iso`` to run the OS

## Configurable Environment Variables
### Build Options
* ``ILOBILIX_ARCH=[<x86_64>|aarch64]``
* ``ILOBILIX_PACKAGES=[<base>|coreutils|...]``
* ``ILOBILIX_BUILD_TYPE=[Release|<ReleaseDbg>|Debug]``
* ``ILOBILIX_SYSCALL_LOG=[ON|<OFF>]``
* ``ILOBILIX_EXTRA_PANIC_MSG=[<ON>|OFF]``
* ``ILOBILIX_MAX_UACPI_POINTS=[ON|<OFF>]``
* ``ILOBILIX_LIMINE_MP=[<ON>|OFF]``
* ``ILOBILIX_UBSAN=[ON|<OFF>]``

### Run Options
* ``QEMU_ACCEL=[<ON>|OFF]``
* ``QEMU_LOG=[ON|<OFF>]``
* ``QEMU_GDB=[ON|<OFF>]``

## Known Bugs
* ``aarch64`` basically doesn't work
* unconfirmed: sometimes sleeping thread doesn't wake up on bare metal
* unconfirmed: slab allocator mapping breaks on that one laptop