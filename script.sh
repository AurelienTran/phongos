#!/bin/bash

# This script can be used to quickly test MultiBoot-compliant
# kernels. The kernel filename is required to be kernel.bin.
# Also, this script requires the file 'stage1' and 'stage2'
# from GRUB to be in the current directory.

KERNEL=kernel.bin
IMAGE=harddrive.img
STAGE1=stage1
STAGE2=stage2

# config params here
image_size=$((4*1024*1024)) # 4 megabytes
qemu_cmdline="qemu -fda ${IMAGE}"

function fail() { echo "$1"; exit 1; }

stage1_size=`stat -c %s ${STAGE1}` || fail "file '${STAGE1}' required" # steal these from GRUB
stage2_size=`stat -c %s ${STAGE2}` || fail "file '${STAGE2}' required"
kernel_size=`stat -c %s ${KERNEL}` || fail "file '${KERNEL}' required"

kernel_begin_block=$(((stage1_size + stage2_size + 511) / 512 + 1))

padding_size=$((kernel_begin_block * 512 - stage1_size - stage2_size))
padding2_size=$((image_size - kernel_begin_block * 512 - kernel_size))

echo Stage1: ${stage1_size} bytes
echo Stage2: ${stage2_size} bytes
echo Kernel: ${kernel_size} bytes
echo Kernel begin block: ${kernel_begin_block}
echo Padding front: ${padding_size} bytes
echo Paddind back: ${padding2_size} bytes

dd if=/dev/zero of=padding.tmp  count=1 bs=$padding_size  2>/dev/null
dd if=/dev/zero of=padding2.tmp count=1 bs=$padding2_size 2>/dev/null

cat ${STAGE1} ${STAGE2} padding.tmp ${KERNEL} padding2.tmp > ${IMAGE}

rm padding.tmp padding2.tmp


( stty cbreak ; stty -echo ; python -c "`cat <<EOF
import sys, time

s="kernel ${kernel_begin_block}+$(((kernel_size+511) / 512))\nboot\n"

translate={
	"\n": "ret",
	"+": "kp_add",
	" ": "spc"
}

time.sleep(2)

try:
	sys.stderr.write(s);

	for c in s:
		if c in translate:
			c = translate[c]
		sys.stdout.write("sendkey "+c+"\n")
		sys.stdout.flush()
		time.sleep(0.05)
except IOError:
	pass
EOF`" ; cat ; ) | $qemu_cmdline -monitor stdio 

stty echo

echo
