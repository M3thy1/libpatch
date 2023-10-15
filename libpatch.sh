#!/bin/bash
# @filename: libpatch.sh
# @author: M3thy1
# @date: 2023-10-14
# @desciption: a script helps to patch the binary file with specific libraries...
# WIP...maybe?
elf_path=$1
libc_path=$2
patchelf_bin_path="/usr/bin/patchelf"

if [ -z "$1" ] && [ -z "$2" ]; then
    echo "[*] Usage: $0 <elf_path> [libc_path]" >&2
    exit 1
fi

if [ "${2: -1}" = "/" ]; then
    libc_path="${2%/}"
else
    libc_path="$2"
fi

if [ -e "$1" ]; then
    ldd "$1" | awk '$0 ~ /ld/ {print "[+] Info: original ld: " $1}'
    old_libc=$(ldd "$1" | awk '$0 ~ /=>/ {print $1}')
    echo "[+] Info: original libc: $old_libc"
else
    echo "[-] Error: elf file not found." >&2
fi

if [ -d "$2" ]; then
    if [ -f ${libc_path}/ld-[2].[0-9][0-9].so ]; then
        $patchelf_bin_path --set-interpreter $libc_path/ld-[2].[0-9][0-9].so $elf_path
    elif [ -f $libc_path/ld-linux-x86-64.so.2 ]; then
        $patchelf_bin_path --set-interpreter $libc_path/ld-linux-x86-64.so.2 $elf_path
    elif [ -f $libc_path/ld-linux.so.2 ]; then
        $patchelf_bin_path --set-interpreter $libc_path/ld-linux.so.2 $elf_path
    else
        echo "[-] Error: ld.so.2 not found." >&2
    fi
    if [ -f $libc_path/libc-[2].[0-9][0-9].so ]; then
        $patchelf_bin_path --replace-needed $old_libc $libc_path/libc-[2].[0-9][0-9].so $elf_path
    elif [ -f $libc_path/libc.so.6 ]; then
        $patchelf_bin_path --replace-needed $old_libc $libc_path/libc.so.6 $elf_path
    else
        echo "[-] Error: libc.so.6 not found." >&2
    fi
else
    echo "[-] $2 is not a directory." >&2
fi
