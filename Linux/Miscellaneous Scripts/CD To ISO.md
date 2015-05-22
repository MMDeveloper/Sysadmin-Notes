```
#!/bin/bash

device=/dev/sr0

## Get Block size of CD
blocksize=`isoinfo -d -i $device | grep "^Logical block size is:" | cut -d " " -f 5`
if test "$blocksize" = ""; then
    echo catdevice FATAL ERROR: Blank blocksize >&2
    exit
fi

## Get Block count of CD
blockcount=`isoinfo -d -i $device | grep "^Volume size is:" | cut -d " " -f 4`
if test "$blockcount" = ""; then
    echo catdevice FATAL ERROR: Blank blockcount >&2
    exit
fi

usage()
{
cat <<EOF

usage: $0 options
-h      Show this message
-m      Check your MD5Hash of CD against Image (Run AFTER making Image)
-l      Location and name of ISO Image (/path/to/image.iso)
-r      Rip CD to ISO image

Example 2: Rip a CD to ISO
archiveCD.sh -l /path/to/isoimage.iso -r

Example 3: Check MD5Hash (Run AFTER ripping CD to ISO)
archiveCD.sh -l /path/to/isoimage.iso -m


EOF
}



while getopts "hml:r" OPTION; do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        m)
            echo "Checking MD5Sum of CD and New ISO Image"
            md5cd=`dd if=$device bs=$blocksize count=$blockcount | md5sum` >&2
            md5iso=`cat $LFLAG | md5sum` >&2
            echo "CD MD5 is:" $md5cd
            echo "ISO MD5 is:" $md5iso
            ;;
        l)
            LFLAG="$OPTARG"
            ;;
        r)
            dd if=$device bs=$blocksize count=$blockcount of=$LFLAG
            echo "Archiving Complete.  ISO Image located at:"$LFLAG
            ;;
    esac
done
```
