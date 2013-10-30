# boot-buddy.sh [--uninstall]

# Boot Buddy v1.3
# Licensed GNU GPL v2, Author Sepero - sepero 111 @ gmx . com
# https://github.com/Sepero/bootbuddy/

# Setup global variables.
ID=$(id | sed 's/[^=]*=//;s/\([0-9]*\).*/\1/')
BB_DIR="boot_buddy_scripts"
BB_FILE="/data/boot_buddy.sh"
IR_FILE="/system/etc/install-recovery.sh"
IR_HEAD="# bootbuddy boot script start"
IR_MAIN="chown 0.0 $BB_FILE
chmod 755 $BB_FILE
busybox sh $BB_FILE"
IR_TAIL="# bootbuddy boot script end"
[ -n $EXTERNAL_ADD_STORAGE ] && EXTERNAL_STORAGE=$EXTERNAL_ADD_STORAGE

# An Error function incase we need to abort the script.
exit_error () {
  echo "$@" >&2
	exit 127
}

# Check for shell.
SHELL="/system/xbin/sh"
[ -f $SHELL ] || SHELL="/system/bin/sh"
[ -f $SHELL ] || exit_error "System shell could not be found: $SHELL"

# Check for root.
[ $ID == "0" ] || exit_error "You're not root"

# Check for busybox
[ -f /system/bin/busybox -o -f /system/xbin/busybox ] || exit_error "Busybox was not found"

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
	echo "Finished"; exit # Exit after uninstalling.
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

# Creates or overwrites the file /data/boot_buddy.sh ($BB_FILE)
echo "Setting up $BB_FILE"
echo "#!$SHELL

BB_LOG=\"/data/boot_buddy.log\"
rm \$BB_LOG

delay_for_sd () {
	for i in \$(seq 0 180); do
		if [ -e \"$EXTERNAL_STORAGE/$BB_DIR/\" ]; then
			break
		fi
		busybox sleep 1
	done
	cd \"$EXTERNAL_STORAGE/$BB_DIR/\"
	ls * | sort | while read i; do
		echo \"RUNNING \$i:\" >> \$BB_LOG
		busybox sh \"\$i\" >> \$BB_LOG 2>> \$BB_LOG
		echo \"\" >> \$BB_LOG
	done
}

delay_for_sd&" > $BB_FILE
# Finished writing the file $BB_FILE


echo "Setting up folder $EXTERNAL_STORAGE/$BB_DIR"
mkdir "$EXTERNAL_STORAGE/$BB_DIR" 2> /dev/null

busybox echo -e "\nPut scripts you want to run at boot in the folder $BB_DIR"
busybox echo -e  "\nFinished"
