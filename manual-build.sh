#!/bin/bash
export ARCH=riscv64
make ARCH=$ARCH br-source


make ARCH=$ARCH OUT_D=$PWD/output/$ARCH


export kver="5.15.0-1028.32"
./bin/grab-kernels "$kver" $ARCH


export gver="2.06-2ubuntu7.1"
./bin/grab-grub-efi "$gver" $ARCH


sudo ./bin/bundle -v --arch=$ARCH output/$ARCH/rootfs.tar \
      download/kernel-$ARCH.tar.gz download/grub-efi-$ARCH.tar.gz output/$ARCH/images