# Ilobilix
Monolithic Hobby OS in modern C++ 23 utilising modules where possible. It has support for custom loadable kernel modules. Its userspace aims to be ABI compatible with GNU/Linux.

Contributors are welcome! Feel free to open issues or submit pull requests.

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
  * [Jinx dependencies](https://codeberg.org/mintsuki/jinx#dependencies)
* Clone this repository:
  * ``git clone https://github.com/ilobilix/ilobilix --recursive``
* Build Ilobilix:
  * This command will build the kernel, cross-compiler and userspace:
  * ``make all``
* Run the OS in QEMU:
  * ``make run-iso``

## Configurable Environment Variables
> [!NOTE]
> Default values are enclosed in ``<>``

### Shared Options
* ``ILOBILIX_ARCH=[<x86_64>|aarch64]``

### Build-Only Options
* ``ILOBILIX_PACKAGES=[<base>|coreutils|...]``
* ``ILOBILIX_BUILD_TYPE=[Release|<ReleaseDbg>|Debug]``
* ``ILOBILIX_LTO=[ON|<OFF>]`` (Requires 'Release' build type)
* ``ILOBILIX_SYSCALL_LOG=[ON|<OFF>]``
* ``ILOBILIX_LIMINE_MP=[<ON>|OFF]``
* ``ILOBILIX_UBSAN=[ON|<OFF>]``

### Run-Only Options
* ``QEMU_SMP=<6>``
* ``QEMU_ACCEL=[<ON>|OFF]``
* ``QEMU_LOG=[ON|<OFF>]``
* ``QEMU_GDB=[ON|<OFF>]``

### Directory Structure
```text
ilobilix/
├── kernel/           # Ilobilix kernel repository
├──── kernel/kernel/  # ─ Kernel source code
├──── kernel/modules/ # ─ Loadable kernel modules
├── base-files/       # Sysroot skeleton
├── host-recipes/     # Recipes for the toolchain used to build sysroot
├── patches/          # Patches for host and target recipes
├── recipes/          # Target sysroot recipes
├── source-recipes/   # Sources for host and target recipes
├── support/          # Various files for userspace and the build system
```

### Notable Pojects Used:
* [Limine](https://codeberg.org/Limine/Limine)
* [Jinx](https://codeberg.org/mintsuki/jinx)
* [uACPI](https://github.com/uACPI/uACPI)
* [Fmtlib](https://github.com/fmtlib/fmt)

## Known Bugs
* mp booting not working on ``aarch64``
* unconfirmed: sometimes sleeping thread doesn't wake up on bare metal
* unconfirmed: slab allocator memory mapping breaks on that one laptop

## Initgraph
```mermaid
---
config:
  layout: elk
---
flowchart TD
  subgraph presched-engine
    output.init
    timers.acpipm
    timers.acpipm.create-thread
    timers
    acpi.early-tables
    sched.pid0.create
    arch.bsp.initialise
    arch.cpus.initialise
    timers.arch.hpet
    timers.arch.hpet.create-thread
    timers.arch.kvm
    timers.arch.pit
    timers.arch
    timers.arch.tsc
  end
  subgraph postsched-engine
    uacpi.create-workers
    vfs.dev.memfiles.register
    vfs.dev.tty.current.register
    vfs.devtmpfs.register
    vfs.devtmpfs.mount
    vfs.fs.register
    vfs.tmpfs.register
    vfs.initramfs.extract
    acpi.initialise
    bin.exec.elf.register
    bin.elf.load-modules
    bin.exec.script.register
    pci.acpi.discover-ios
    pci.acpi.discover-rbs
    pci.enumerate
    vfs.mount-root
    output.arch.uart8250.tty.register
    pci.arch.discover-ios
    pci.arch.discover-rbs
  end
  output.init --> acpi.early-tables
  timers.acpipm --> timers.acpipm.create-thread
  timers.acpipm --> timers
  timers --> sched.pid0.create
  timers --> arch.cpus.initialise
  acpi.early-tables --> timers.acpipm
  acpi.early-tables --> pci.acpi.discover-ios
  acpi.early-tables --> arch.bsp.initialise
  acpi.early-tables --> timers.arch.hpet
  sched.pid0.create --> uacpi.create-workers
  sched.pid0.create --> timers.acpipm.create-thread
  sched.pid0.create --> timers.arch.hpet.create-thread
  arch.bsp.initialise --> arch.cpus.initialise
  arch.bsp.initialise --> timers.arch.kvm
  arch.bsp.initialise --> timers.arch.pit
  arch.bsp.initialise --> timers.arch.tsc
  arch.cpus.initialise --> sched.pid0.create
  timers.arch.hpet --> timers.arch.hpet.create-thread
  timers.arch.hpet --> timers.arch
  timers.arch.kvm --> timers.arch
  timers.arch.kvm --> timers.arch.tsc
  timers.arch.pit --> timers.arch
  timers.arch --> timers
  timers.arch.tsc --> timers.arch
  uacpi.create-workers --> acpi.initialise
  vfs.devtmpfs.register --> vfs.devtmpfs.mount
  vfs.devtmpfs.register --> vfs.fs.register
  vfs.devtmpfs.mount --> vfs.dev.memfiles.register
  vfs.devtmpfs.mount --> vfs.dev.tty.current.register
  vfs.devtmpfs.mount --> output.arch.uart8250.tty.register
  vfs.fs.register --> vfs.mount-root
  vfs.tmpfs.register --> vfs.fs.register
  vfs.initramfs.extract --> bin.elf.load-modules
  acpi.initialise --> pci.acpi.discover-rbs
  pci.acpi.discover-ios --> acpi.initialise
  pci.acpi.discover-ios --> pci.enumerate
  pci.acpi.discover-ios --> pci.arch.discover-ios
  pci.acpi.discover-rbs --> pci.enumerate
  pci.acpi.discover-rbs --> pci.arch.discover-rbs
  vfs.mount-root --> vfs.devtmpfs.mount
  vfs.mount-root --> vfs.initramfs.extract
  pci.arch.discover-ios --> pci.enumerate
  pci.arch.discover-rbs --> pci.enumerate
```