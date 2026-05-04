#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
    echo "usage: $0 <base-files-dir> <sysroot-dir>" >&2
    exit 2
fi

src=$1
dst=$2

if [ ! -d "$dst" ]; then
    echo "sysroot does not exist: $dst" >&2
    exit 1
fi

if [ -d "$src/overlay" ]; then
    cp -af "$src/overlay/." "$dst/"
    find "$dst" -name .keep -type f -delete
fi

if [ -d "$src/append" ]; then
    find "$src/append" -type f | while IFS= read -r file; do
        rel=${file#"$src/append/"}
        target=$dst/$rel

        mkdir -p "$(dirname "$target")"
        if [ -e "$target" ]; then
            saved_mode=$(stat -c %a "$target")
            chmod u+rw "$target"
        else
            saved_mode=
            : > "$target"
        fi

        while IFS= read -r line || [ -n "$line" ]; do
            [ -z "$line" ] && continue
            grep -qxF -- "$line" "$target" 2>/dev/null && continue
            printf '%s\n' "$line" >> "$target"
        done < "$file"

        [ -n "$saved_mode" ] && chmod "$saved_mode" "$target"
    done
fi

[ -f "$dst/etc/sudoers" ] && chmod 0440 "$dst/etc/sudoers"
[ -d "$dst/etc/sudoers.d" ] && find "$dst/etc/sudoers.d" -maxdepth 1 -type f -exec chmod 0440 {} +

if [ -f "$dst/etc/shadow" ]; then
    saved_mode=$(stat -c %a "$dst/etc/shadow")
    chmod u+rw "$dst/etc/shadow"
    sed -i \
        -e 's|^root:\$[^:]*:|root::|' \
        -e 's|^\(root:.*\):/bin/sh$|\1:/bin/bash|' \
        "$dst/etc/shadow" "$dst/etc/passwd"
    chmod "$saved_mode" "$dst/etc/shadow"
fi
