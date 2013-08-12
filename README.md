# BootBuddy

Boot Buddy will allow you to run Linux shell scripts when your Android device is booting up. It will run your scripts early in the boot process, before the home screen appears.

The intended audience is generally intermediate to advanced users, and those who want to play with shell scripting on their device.

Author: Sepero - Remote Python developer and Linux administrator for hire.  
Email: sepero 111 @ gmail . com  
URL: https://github.com/Sepero/bootbuddy/  

## FEATURES
BootBuddy is similar to init.d scripts, but with a core difference that it stores boot scripts on your SDcard instead of the internal system. This allows for several interesting enhancements. Feature listing-

+ Boot Buddy is designed from the start to run scripts right from your SDcard. Just download any scripts to your **boot_buddy_scripts** directory and they're ready to run. (No more screwing around with permissions and files in your /system/etc/init.d/*)
+ SDcard storage allows you to copy a script to another device, or multiple devices easily.
+ If you have a script that is malfunctioning, just boot your device with the sdcard out, and put the sdcard back in after your device reaches home screen. No Problem!
+ Boot Buddy's author has several years of scripting and programming experience. It is streamlined, fast, and doesn't perform worthless functions like repeatedly logging the authors name and time (*hint to a t-init author*).
+ Clear goals of making operation simple, intuitive, and clean.
+ If you're currently using an "init.d" solution, BootBuddy can integrate seamlessly with it.
+ If you try BootBuddy and you don't like it, the installer also works as an uninstaller for easy clean removal.
+ BootBuddy is Open Source GNU GPL. Open for anyone to modify and improve upon.

As a developer, I make software to operate the way I would want if I were an end user, because I actually do use it, and I am an end user like you.


## REQUIREMENTS
+ Rooted device
+ An sdcard
+ [Script Manager Free](https://play.google.com/store/apps/details?id=os.tools.scriptmanager) (or any other app that can run scripts as root)
+ Boot Buddy Installer bb_install.sh


## INSTALL
1. Start [Script Manager](https://play.google.com/store/apps/details?id=os.tools.scriptmanager), and allow/grant root access.
1. Navigate to the bb_install.sh file.
1. Tap on the file to show the menu options.
1. At the top, highlight the "Su" icon.
1. On the top-left, tap "Run".

The script will run quickly and create a folder on your sdcard named "boot_buddy_scripts". In that folder, you put the scripts you want to run at system boot.

If you need your scripts to run in order, they are ordered by filename using the busybox "sort" program. They will run in alphabetical order using this format 0-9A-Za-z.


## YOUR FIRST SCRIPTS (OPTIONAL)
Here are a couple example scripts you may use.

The Android /system is normally mounted with read-only permissions by default. We will change that with the first script listed below. It will cause /system to be remounted to read-write permissions during boot.

The second script will create a file at every boot named /mnt/sdcard/sys_mount_info.txt. That txt file will give us information about how /system is currently mounted.

1. Download the file [00rw_system.sh](http://www.mediafire.com/?x85kikhcbidikhd) into your boot_buddy_scripts folder.
1. Download the file [99sys_mount_info.sh](http://www.mediafire.com/?gr0rauxcm4ked49) into your boot_buddy_scripts folder.
1. Reboot your phone.

That's it, you just installed 2 new scripts and had them run at boot. It's Really just that simple to add startup scripts to your system.

To verify they are running, use any text viewer to open the file /mnt/sdcard/sys_mount_info.txt. It may show more than one line of text. There should be a line similar to this:
/dev/block/(device specific text) **/system** (fstype) **rw**,(more text)

The **rw** means that /system was successfully remounted as read-write during boot.

At any time you can delete either script if you choose. Easy!


## UNINSTALL
If for any reason you find you don't want or don't like Boot Buddy, you can cleanly uninstall it using the installer bb_install.sh. These instructions are almost identical to installing. (All match the installation steps, except step 4)

1. Start [Script Manager](https://play.google.com/store/apps/details?id=os.tools.scriptmanager), and allow/grant root access.
1. Navigate to the bb_install.sh file.
1. Tap on the file to show the menu options.
1. Type **--uninstall** in the text area labeled Arguments.
1. At the top, highlight the "Su" icon.
1. On the top-left, tap "Run".

Boot Buddy will be uninstalled. It will not remove the contents of your boot_buddy_scripts folder. If you have an "init.d" system installed, it will cleanly remove only Boot Buddy parts and leave the rest.


## ADVANCED NOTES
Boot Buddy will not cause harm to your system, but it may not work on custom roms. Also, it may fail to detect the real location of your SDcard. It requires that /system/etc/install-recovery.sh is run during the boot process, and that file will be created if it does not exist. Also the file /data/boot_buddy.sh will be created. The script /system/etc/install-recovery.sh will run /data/boot_buddy.sh. The script /data/boot_buddy.sh will run the scripts on the sdcard.

For Windows and Mac users- If you download the installer to your pc first, do not edit the installer with a text editor. Your computer will add hidden markers at the ends of each line that will prevent the installer from running. If you want to edit it, you should do so on a Linux pc or directly on your Android device with a text editor.
