# boot-buddy.sh [--uninstall]

# Boot Buddy v1.3.2
# Licensed GNU GPL v2, Author Sepero - sepero 111 @ gmx . com
# https://github.com/Sepero/bootbuddy/

# An Error function incase we need to abort the script.
exit_error () {
    echo "$@" >&2
    exit 127
}

# An Exit function to successfully complete the script.
exit_success () {
    sync
    echo "Remounting /system as read only"
    $BUSYB mount -o remount,ro /system
    $BUSYB echo -e "\nFinished"
    $BUSYB echo -e "\nPut scripts you want to run at boot in the folder $BB_DIR"
    exit
}


### Start setting up global variables.
# Try to verify location of shell.
SHELL="/system/xbin/sh"
[ -f $SHELL ] || SHELL="/system/bin/sh"
[ -f $SHELL ] || exit_error "System shell could not be found: $SHELL"

# Verify busybox location.
BUSYB="/system/bin/busybox"
[ -f $BUSYB ] || BUSYB="/system/xbin/busybox"
[ -f $BUSYB ] || exit_error "Busybox was not found"

# Get user id number.
ID=$(id | sed 's/[^=]*=//;s/\([0-9]*\).*/\1/')
# Name of the BB directory for running scripts. 
BB_DIR="boot_buddy_scripts"
# The BB executable script file. This will run user scripts.
BB_FILE="/data/boot_buddy.sh"
# Location of the Install Recovery file. This file is used to run the BB executable.
IR_FILE="/system/etc/install-recovery.sh"

# Text to insert into the Install Recovery file.
IR_HEAD="# bootbuddy boot script start"
IR_MAIN="chown 0.0 $BB_FILE
chmod 755 $BB_FILE
busybox sh $BB_FILE"
IR_TAIL="# bootbuddy boot script end"

# Try to find location of the real sdcard. It should be in $EXTERNAL_STORAGE, 
# but some manufacturers put it under other names.
# "$EXTERNAL_STORAGE"       # Kyocera, Motorola
# "$EXTERNAL_STORAGE2"      # ?
# "$EXTERNAL_ADD_STORAGE"   # LG Esteem, LG L9
# "$SECONDARY_STORAGE"      # Samsung Galaxy S4
# "$SECOND_VOLUME_STORAGE"  # Insignia Flex 8
# "$USBHOST_STORAGE"        # ?
# "$PHONE_STORAGE"          # ?
for i in    "$EXTERNAL_STORAGE"      \
            "$EXTERNAL_STORAGE2"     \
            "$EXTERNAL_ADD_STORAGE"  \
            "$SECONDARY_STORAGE"     \
            "$SECOND_VOLUME_STORAGE" \
            "$USBHOST_STORAGE"       \
            "$PHONE_STORAGE"         \
; do
    [ -n "$i" ] && SDCARD="$i" # If the variable is set, then use it as our sdcard.
done

if [ "$1" == "-s" ]; do # Change $SDCARD to user specified sdcard location.
    SDCARD="$2"
    shift; shift
fi
### End setting up global variables.


# Check for root.
[ "$ID" == "0" ] || exit_error "You're not root"

# Remount the system as writable.
echo "Remounting /system as writable"
busybox mount -o remount,rw /system

# If uninstalling, then remove file traces and exit.
if [ "$1" == "--uninstall" ]; then
    echo "Deleting $BB_FILE"
    rm $BB_FILE 2> /dev/null
    if [ -e $IR_FILE ]; then
        echo "Cleaning $IR_FILE"
        match=$(sed "/$IR_HEAD/,/$IR_TAIL/d" $IR_FILE)
        remain=$(echo "$match" | busybox grep -v "^[[:space:]]$")
        if [ "$remain" == "#!$SHELL" ]; then
            rm $IR_FILE
        else
            echo "$match" > $IR_FILE
        fi
    fi
    echo "== UNINSTALLED BOOT BUDDY =="
    exit_success
fi

# Install script files.
text="$IR_HEAD\n$IR_MAIN\n$IR_TAIL"
echo "Setting up $IR_FILE"
if [ ! -e $IR_FILE ]; then
    busybox echo -e "#!$SHELL\n" > $IR_FILE
    busybox echo -e "$text" >> $IR_FILE
else
    # Remove text if it's already in the file.
    match=$(sed "/$IR_HEAD/,/$IR_TAIL/d" $IR_FILE)
    # Re-add text at end of file.
    busybox echo -e "$match\n\n$text" > $IR_FILE
fi
chown 0.0 $IR_FILE
chmod 755 $IR_FILE

# Creates or overwrites the exectuable file /data/boot_buddy.sh ($BB_FILE)
echo "Setting up $BB_FILE"
echo "#!$SHELL

BB_LOG=\"/data/boot_buddy.log\"
rm \$BB_LOG

delay_for_sd () {
    for i in \$(seq 0 180); do
        if [ -e \"$SDCARD/$BB_DIR/\" ]; then
            break
        fi
        busybox sleep 1
    done
    cd \"$SDCARD/$BB_DIR/\"
    ls * | sort | while read i; do
        echo \"RUNNING \$i:\" >> \$BB_LOG
        busybox sh \"\$i\" >> \$BB_LOG 2>> \$BB_LOG
        echo \"\" >> \$BB_LOG
    done
}

delay_for_sd&" > $BB_FILE
# Finished writing the file $BB_FILE


echo "Setting up folder $SDCARD/$BB_DIR"
mkdir "$SDCARD/$BB_DIR" 2> /dev/null

