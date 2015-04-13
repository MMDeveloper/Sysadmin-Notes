### For this tutorial, we have a linux machine that does not utilize LVM yet and you want to start going so.
### If this is a bare-metal server with physical drives being used, you must first power down the machine
### and add the drives. If this is a virtual server being allocated a new virtual disk or a bare-metal
### server being allocated a new LUN from a SAN, you don't have to reboot, you may instead just need to
### issue a rescan of the scsi bus via, if an existing disk is simply being expanded, you just need to
### issue a rescan of the existing devices. OR just reboot the server, either way.




### To hot-rescan the SCSI bus for NEW disks (no reboot required)

### first let's find the disk naming convention this OS is using
mount | grep '/boot'
### this should return something that starts with /dev/sda1 or /dev/sdb2 or /dev/xvda1, etc
### once you know the naming scheme for the disks, we want to inventory which disks we already have.
### I'll assume the naming convention here is /dev/sd*, so let's see what block devices we already have.
ls -lh /dev/sd*

### that would return a list of disk and partitions (partition entries end with a number, like sda1, sda2, etc)
### we only care about the letters, so let's pretend we already have a /dev/sda and /dev/sdb

### generate a list of host devices from this command
ls -lh /sys/class/scsi_host

### for each result (should be named host#, such as host0, host1, etc), run this
echo "- - -" > /sys/class/scsi_host/host#/scan
### where "#" is the host number
###     echo "- - -" > /sys/class/scsi_host/host0/scan
###     echo "- - -" > /sys/class/scsi_host/host1/scan

### Give the scan up to 5 minutes to run (go to the bathroom, water cooler, etc).




### To hot-rescan EXISTING devices that have simply been expanded
echo 1 > /sys/class/scsi_device/device/rescan




### If you had a new disk, and not simply expanded an existing one, continue, if you expanded an
### existing disk, skip ahead to the bottom of
Managing Logical Volumes