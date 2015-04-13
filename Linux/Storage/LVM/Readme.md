#Introduction#
So, what are Logical Volumes? Think of logical volumes on Linux as multiple disks and/or partitions working together, pooling their storage, for you. If you have two 10gb disks, together they can provide a single 20gb "disk" for you to mount and use. If you're running out of space on that 20gb disk, you can (on the fly) add a new disk and expand that 20gb even larger without rebooting or unmounting the disk at all.

The LVM is broken down into 3 pieces:

 - Volume Groups: Mainly used for categorization, there's nothing wrong with have all of
   your LV's in one group, or one LV per group. Think of it as two neighbors tossing a
   ball back and forth. Each neighbor can be in their own respective yard, or both in the
   same yard, does not matter.

 - Physical Volumes: These are the disk partitions assigned to a particular volume group

 - Logical Volumes: Slices of the pool of PVs formatted and mounted as disks for the OS.


If you plan on using LVMs for Big Data storage, I advise you google on planning ahead for VG/PV/LV layouts as they do have limitations that need to be considered before starting as these parameters cannot be modified once set for a VG/PV/LV, you'd have to destroy them and re-create from scratch. One article for example is http://www.walkernews.net/2007/07/02/maximum-size-of-a-logical-volume-in-lvm/

For this tutorial, we have a linux machine that does not utilize LVM yet and you want to start going so. If this is a bare-metal server with physical drives being used, you must first power down the machine and add the drives. If this is a virtual server being allocated a new virtual disk or a bare-metal server being allocated a new LUN from a SAN, you don't have to reboot, you may instead just need to issue a rescan of the scsi bus via, if an existing disk is simply being expanded, you just need to issue a rescan of the existing devices. OR just reboot the server, either way.


####To hot-rescan the SCSI bus for NEW disks (no reboot required). First let's find the disk naming convention this OS is using####
```
mount | grep '/boot'
```
This should return something that starts with /dev/sda1 or /dev/sdb2 or /dev/xvda1, etc. Once you know the naming scheme for the disks, we want to inventory which disks we already have. I'll assume the naming convention here is /dev/sd*, so let's see what block devices we already have.
```
ls -lh /dev/sd*
```

That would return a list of disk and partitions (partition entries end with a number, like sda1, sda2, etc). We only care about the letters, so let's pretend we already have a /dev/sda and /dev/sdb

generate a list of host devices from this command
```
ls -lh /sys/class/scsi_host
```

For each result (should be named host#, such as host0, host1, etc), run this
```
echo "- - -" > /sys/class/scsi_host/host#/scan
```
Where "#" is the host number
```
###     echo "- - -" > /sys/class/scsi_host/host0/scan
###     echo "- - -" > /sys/class/scsi_host/host1/scan
```

Give the scan up to 5 minutes to run (go to the bathroom, water cooler, etc).

####To hot-rescan EXISTING devices that have simply been expanded####
```
echo 1 > /sys/class/scsi_device/device/rescan
```

If you had a new disk, and not simply expanded an existing one, continue, if you expanded an existing disk, skip ahead to the bottom of Managing Logical Volumes

#Prepping New Disks#
Now let's see what new disks appear on the system, lets re-run this previous command
```
ls -lh /dev/sd*
```

You should now see a new disk that wasn't present the last time we did this, we'll assume it is now /dev/sdc. We need to fdisk/prep this drive to be used in LVM
```
fdisk /dev/sdc
```

Make sure there are no partitions on this drive
```
p
```

If there are any partitions, remove them, else continue this key sequence will create a single partition, of type Linux-LVM spanning the entire disk.
```
n
p
1
[enter]
[enter]
t
8e
w
```

Now we need to "initialize" the new disk partition as a LVM's PV.
```
pvcreate /dev/sdc1
pvdisplay
```

You should see your newly created sdc1 PV. Now run this command to get the UID of the partition as we will use that from now on
```
ls -lh /dev/disk/by-id | grep sdc1
```

For the purposes of this documentation, we'll assume it was
```
/dev/disk/by-id/lvm-pv-uuid-JK60sV-Mc1e-RZlD-eeeB-h4qK-xFtn-iyZfHV
```

#Managing Volume Groups#
If you are creating a new Volume Group and not expanding an existing one think of a name for your VG, it must be unique amongst future VGs on this vg_server_0 and should describe the purpose of the PVs within it
```
vgcreate vg_www /dev/disk/by-id/lvm-pv-uuid-JK60sV-Mc1e-RZlD-eeeB-h4qK-xFtn-iyZfHV
```

If you were adding this partition to an EXISTING volume group, you would first need to know the exact name of the volume group which you can obtain by running
```
vgdisplay
```

I'll assume we're adding this new partition to an existing VG named "vg_www"
```
vgextend vg_www /dev/disk/by-id/lvm-pv-uuid-JK60sV-Mc1e-RZlD-eeeB-h4qK-xFtn-iyZfHV
```

#Managing Logical Volumes#
Now that we have our VG full of a pool of PVs (or in this case, only one PV), we need to start carving out LVs to be mounted as disks. If you want a fixed size LV from the vg_www's pool, and we'll name it www
```
lvcreate --size 10G --name www vg_www
```

If you wanted to create an LV that uses up ALL of the space from the VG this would be if you created single-purpose VGs, for example, a VG solely for your /var/www directory and you don't want to fool around with specific PV sizes to make sure you don't waste space by guessing the size incorrectly
```
lvcreate --extents 100%FREE --name www vg_www
```

Now that you've created your LV, we need to format it.
```
mkfs.ext4 /dev/vg_www/www
```

Now we can mount it
```
mount /dev/vg_www/www /var/www
```

####IF YOU ARE ADDING SPACE TO AN EXISTING LV####
Once you've run pvcreate, and vgextend to prep the new disk partition. You simply need to "lvextend" the LV and then resize the filesystem. You can do this HOT without unmounting. We'll assume the disk you're adding to an existing LV is /dev/disk/by-id/lvm-pv-uuid-JK60sV-Mc1e-RZlD-eeeB-h4qK-xFtn-iyZfHA
```
lvextend /dev/vg_www/www /dev/disk/by-id/lvm-pv-uuid-JK60sV-Mc1e-RZlD-eeeB-h4qK-xFtn-iyZfHA
resize2fs /dev/vg_www/www
```