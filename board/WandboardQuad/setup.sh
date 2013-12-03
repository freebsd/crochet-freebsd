KERNCONF=WANDBOARD-QUAD
TARGET_ARCH=arm
IMAGE_SIZE=$((1024 * 1000 * 1000))

# create a MBR disk with a single UFS partition
# based on instructions here: http://www.wonkity.com/~wblock/docs/html/disksetup.html
#
wandboardquad_partition_image ( ) {
        BOOTFILES=${OBJFILES}sys/boot/i386
        echo "Boot files are at: "${BOOTFILES}

        # basic setup
        disk_partition_mbr
        disk_ufs_create

        # boot loader
        echo "Installing bootblocks"
        gpart bootcode -b ${BOOTFILES}/mbr/mbr ${DISK_MD} || exit 1
        gpart set -a active -i 1 ${DISK_MD} || exit 1
        bsdlabel -B -b ${BOOTFILES}/boot2/boot ${DISK_UFS_PARTITION} || exit 1

        #show the disk
        gpart show ${DISK_MD}
}

strategy_add $PHASE_PARTITION_LWW wandboardquad_partition_image

# Kernel installs in UFS partition
strategy_add $PHASE_FREEBSD_BOARD_INSTALL freebsd_installkernel .

