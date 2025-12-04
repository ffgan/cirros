#! /bin/bash

MEM=${MEM:-512}
POWEROFF=${POWEROFF:-false}

GUESTARCH="${GUESTARCH:-riscv64}"
IMG=./output/riscv64/images/disk.img

echo '{"instance-id": "9068aef2-213e-4e43-830f-accdbadde897"}' > meta-data

if [ "$POWEROFF" != "true" ]; then
    echo "" > user-data
else
    cat >user-data <<"EOF"
#!/bin/sh
rclocal="/etc/rc.local"
cat >>$rclocal <<"END_RC_LOCAL"
#!/bin/sh
read up idle </proc/uptime
echo "[$up] Hello and goodbye from inside $0"
poweroff
END_RC_LOCAL
chmod 755 $rclocal
EOF
fi

cloud-localds -d qcow2 seed.img user-data meta-data

qemu-img create -f qcow2 -b "$IMG" -F qcow2 disk1.img >/dev/null 2>&1

MACHINE=virt
EXTRA_OPTS="-kernel ./output/riscv64/images/kernel -initrd ./output/riscv64/images/initramfs"

set -x  # show next command

qemu-system-$GUESTARCH -m $MEM -machine $MACHINE \
   -device virtio-net-pci,netdev=net00 \
   -device virtio-rng-pci \
   -netdev type=user,id=net00,net=10.0.12.0/24,host=10.0.12.2 \
   -drive if=virtio,file=disk1.img \
   -drive if=virtio,file=seed.img \
   $EXTRA_OPTS \
   -nographic \
   -vga none
