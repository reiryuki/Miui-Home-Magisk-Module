# boot mode
#if [ "$BOOTMODE" != true ]; then
#  abort "! Please install via Magisk/KernelSU app only!"
#fi

# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# sdk
NUM=21
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# miuicore
if [ ! -d /data/adb/modules/MiuiCore ]; then
  ui_print "! Miui Core Magisk Module is not installed."
  ui_print "  Please read github installation guide!"
  abort
else
  rm -f /data/adb/modules/MiuiCore/remove
  rm -f /data/adb/modules/MiuiCore/disable
fi

# recovery
mount_partitions_in_recovery

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# cleaning
ui_print "- Cleaning..."
PKGS=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    FILE=`find /data/app -name *$PKG*`
    if [ "$FILE" ]; then
      RES=`pm uninstall $PKG 2>/dev/null`
    fi
  done
fi
remove_sepolicy_rule
ui_print " "

# function
test_signature() {
FILE=`find $MODPATH/system -type f -name $APP.apk`
ui_print "- Testing signature..."
RES=`pm install -g -i com.android.vending $FILE`
if [ "$RES" ]; then
  ui_print "  $RES"
fi
if [ "$RES" == Success ]; then
  RES=`pm uninstall -k $PKG 2>/dev/null`
  ui_print "  Signature test is passed"
elif [ -d /data/adb/modules_update/luckypatcher ]\
|| [ -d /data/adb/modules/luckypatcher ]; then
  ui_print "  Enabling Patches to Android Lucky Patcher Module..."
  rm -f /data/adb/modules/luckypatcher/remove
  rm -f /data/adb/modules/luckypatcher/disable
elif echo "$RES" | grep -q INSTALL_FAILED_SHARED_USER_INCOMPATIBLE; then
  ui_print "  Signature test is failed"
  ui_print "  But installation is allowed for this case"
  ui_print "  Make sure you have deactivated your Android Signature"
  ui_print "  Verification, otherwise the app cannot be installed correctly."
  ui_print "  If you don't know what is it, please READ Troubleshootings!"
elif echo "$RES" | grep -q INSTALL_FAILED_INSUFFICIENT_STORAGE; then
  ui_print "  Please free-up your internal storage first!"
  abort
else
  ui_print "  ! Signature test is failed"
  ui_print "    You need to disable Signature Verification of your"
  ui_print "    Android first to use this module. READ Troubleshootings!"
  if [ "`grep_prop force.install $OPTIONALS`" != 1 ]; then
    abort
  fi
fi
ui_print " "
}

# test
APP=MiuiHome
PKG=com.miui.home
#if [ "$BOOTMODE" == true ]; then
#  if ! appops get $PKG > /dev/null 2>&1; then
#    test_signature
#  fi
#fi

# function
conflict() {
for NAME in $NAMES; do
  DIR=/data/adb/modules_update/$NAME
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAME
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAME/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAME\
   /mnt/vendor/persist/magisk/$NAME\
   /persist/magisk/$NAME\
   /data/unencrypted/magisk/$NAME\
   /cache/magisk/$NAME\
   /cust/magisk/$NAME
done
}

# recents
if [ "`grep_prop miui.recents $OPTIONALS`" == 1 ]; then
  RECENTS=true
  NAME=*RecentsOverlay.apk
  ui_print "- $MODNAME recents provider will be activated"
  ui_print "- Quick Switch module will be disabled"
  ui_print "- Renaming any other else module $NAME"
  ui_print "  to $NAME.bak"
  touch /data/adb/modules/quickstepswitcher/disable
  touch /data/adb/modules/quickswitch/disable
  sed -i 's|#r||g' $MODPATH/post-fs-data.sh
  FILES=`find /data/adb/modules* ! -path "*/$MODID/*" -type f -name $NAME`
  for FILE in $FILES; do
    mv -f $FILE $FILE.bak
  done
  ui_print " "
else
  RECENTS=false
  rm -rf $MODPATH/system/product/overlay
fi

# function
cleanup() {
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
DIR=/data/adb/modules_update/$MODID
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
}

# cleanup
DIR=/data/adb/modules/$MODID
FILE=$DIR/module.prop
PREVMODNAME=`grep_prop name $FILE`
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's|^data.cleanup=1|data.cleanup=0|g' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
#elif [ -d $DIR ]\
#&& [ "$PREVMODNAME" != "$MODNAME" ]; then
#  ui_print "- Different version detected"
#  ui_print "  Cleaning-up $MODID data..."
#  cleanup
#  ui_print " "
fi

# function
permissive_2() {
sed -i 's|#2||g' $MODPATH/post-fs-data.sh
}
permissive() {
FILE=/sys/fs/selinux/enforce
SELINUX=`cat $FILE`
if [ "$SELINUX" == 1 ]; then
  if ! setenforce 0; then
    echo 0 > $FILE
  fi
  SELINUX=`cat $FILE`
  if [ "$SELINUX" == 1 ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    if ! setenforce 1; then
      echo 1 > $FILE
    fi
    sed -i 's|#1||g' $MODPATH/post-fs-data.sh
  fi
else
  sed -i 's|#1||g' $MODPATH/post-fs-data.sh
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# function
extract_lib() {
for APP in $APPS; do
  FILE=`find $MODPATH/system -type f -name $APP.apk`
  if [ -f `dirname $FILE`/extract ]; then
    rm -f `dirname $FILE`/extract
    ui_print "- Extracting..."
    if [ $APP == QuickSearchBox ] && [ "$ARCH" == x64 ]; then
      DIR=`dirname $FILE`/lib/x86
    else
      DIR=`dirname $FILE`/lib/"$ARCH"
    fi
    mkdir -p $DIR
    rm -rf $TMPDIR/*
    if [ $APP == QuickSearchBox ] && [ "$ARCH" == x64 ]; then
      DES=lib/x86/*
    else
      DES=lib/"$ABI"/*
    fi
    unzip -d $TMPDIR -o $FILE $DES
    cp -f $TMPDIR/$DES $DIR
    ui_print " "
  fi
done
}
hide_oat() {
for APP in $APPS; do
  REPLACE="$REPLACE
  `find $MODPATH/system -type d -name $APP | sed "s|$MODPATH||g"`/oat"
done
}

# extract
APPS="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
extract_lib
# hide
hide_oat

# overlay
if [ "$RECENTS" == true ] && [ ! -d /product/overlay ]; then
  ui_print "- Using /vendor/overlay/ instead of /product/overlay/"
  mkdir -p $MODPATH/system/vendor
  mv -f $MODPATH/system/product/overlay $MODPATH/system/vendor
  ui_print " "
fi

# media
if [ ! -d /product/media ] && [ -d /system/media ]; then
  ui_print "- Using /system/media instead of /product/media"
  mv -f $MODPATH/system/product/media $MODPATH/system
  sed -i 's|/product|/system|g' $MODPATH/system/media/theme/.data/meta/*/*.mrm
  ui_print " "
elif [ ! -d /product/media ] && [ ! -d /system/media ]; then
  ui_print "! /product/media & /system/media not found"
  ui_print " "
fi

# function
warning() {
ui_print "  If you are disabling this module,"
ui_print "  then you need to reinstall this module, reboot,"
ui_print "  & reinstall again to re-grant permissions."
}
warning_2() {
ui_print "  Granting permissions at the first installation"
ui_print "  doesn't work. You need to reinstall this module again"
ui_print "  after reboot to grant permissions."
}
patch_runtime_permisions() {
FILE=`find /data/system /data/misc* -type f -name runtime-permissions.xml`
chmod 0600 $FILE
if grep -q '<package name="com.miui.home" />' $FILE; then
  sed -i 's|<package name="com.miui.home" />|\
<package name="com.miui.home">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.REAL_GET_TASKS" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="miui.autoinstall.config.permission.AUTOINSTALL" granted="true" flags="0" />\
<permission name="android.permission.SET_PROCESS_LIMIT" granted="true" flags="0" />\
<permission name="android.permission.READ_CALENDAR" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_FINE_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="miui.os.permisson.INIT_MIUI_ENVIRONMENT" granted="true" flags="0" />\
<permission name="android.miui.permission.SHELL" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="miui.permission.USE_INTERNAL_GENERAL_API" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.BIND_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.START_ANY_ACTIVITY" granted="true" flags="0" />\
<permission name="com.android.SystemUI.permission.TIGGER_TOGGLE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.FOREGROUND_SERVICE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="com.miui.personalassistant.permission.ACCESS_ACTIVITY" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.miui.home.launcher.permission.LOADING_STATUS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_CONNECT" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH" granted="true" flags="0" />\
<permission name="com.android.alarm.permission.SET_ALARM" granted="true" flags="0" />\
<permission name="miui.personalassistant.ACCESS_PROVIDER" granted="true" flags="0" />\
<permission name="android.permission.GET_TASKS" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="miui.permission.ACCESS_ALARM_PROVIDER" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_ADMIN" granted="true" flags="0" />\
<permission name="android.permission.UPDATE_DEVICE_STATS" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.PACKAGE_USAGE_STATS" granted="true" flags="0" />\
<permission name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_COARSE_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.SET_ACTIVITY_WATCHER" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.systemui.permission.NOTIFICATION" granted="true" flags="0" />\
<permission name="android.permission.READ_PHONE_STATE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_DOWNLOAD_MANAGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_STICKY" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CAMERA" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_CALENDAR" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_AUDIO" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VIDEO" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_ADVERTISE" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.READ_SYNC_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.FORCE_STOP_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.CREATE_USERS" granted="true" flags="0" />\
<permission name="android.permission.GET_DETAILED_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_INSTALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.DUMP" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.WAKE_LOCK" granted="true" flags="0" />\
<permission name="android.permission.READ_CONTACTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.UPDATE_APP_OPS_STATS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_SCAN" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_MEDIA_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.MEDIA_CONTENT_CONTROL" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</package>\n|g' $FILE
  warning
elif grep -q '<package name="com.miui.home"/>' $FILE; then
  sed -i 's|<package name="com.miui.home"/>|\
<package name="com.miui.home">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.REAL_GET_TASKS" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="miui.autoinstall.config.permission.AUTOINSTALL" granted="true" flags="0" />\
<permission name="android.permission.SET_PROCESS_LIMIT" granted="true" flags="0" />\
<permission name="android.permission.READ_CALENDAR" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_FINE_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="miui.os.permisson.INIT_MIUI_ENVIRONMENT" granted="true" flags="0" />\
<permission name="android.miui.permission.SHELL" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="miui.permission.USE_INTERNAL_GENERAL_API" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.BIND_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.START_ANY_ACTIVITY" granted="true" flags="0" />\
<permission name="com.android.SystemUI.permission.TIGGER_TOGGLE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.FOREGROUND_SERVICE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="com.miui.personalassistant.permission.ACCESS_ACTIVITY" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.miui.home.launcher.permission.LOADING_STATUS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_CONNECT" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH" granted="true" flags="0" />\
<permission name="com.android.alarm.permission.SET_ALARM" granted="true" flags="0" />\
<permission name="miui.personalassistant.ACCESS_PROVIDER" granted="true" flags="0" />\
<permission name="android.permission.GET_TASKS" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="miui.permission.ACCESS_ALARM_PROVIDER" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_ADMIN" granted="true" flags="0" />\
<permission name="android.permission.UPDATE_DEVICE_STATS" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.PACKAGE_USAGE_STATS" granted="true" flags="0" />\
<permission name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_COARSE_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.SET_ACTIVITY_WATCHER" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.systemui.permission.NOTIFICATION" granted="true" flags="0" />\
<permission name="android.permission.READ_PHONE_STATE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_DOWNLOAD_MANAGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_STICKY" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CAMERA" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_CALENDAR" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_AUDIO" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VIDEO" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_ADVERTISE" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.READ_SYNC_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.FORCE_STOP_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.CREATE_USERS" granted="true" flags="0" />\
<permission name="android.permission.GET_DETAILED_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_INSTALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.DUMP" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.WAKE_LOCK" granted="true" flags="0" />\
<permission name="android.permission.READ_CONTACTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.UPDATE_APP_OPS_STATS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_SCAN" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_MEDIA_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.MEDIA_CONTENT_CONTROL" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</package>\n|g' $FILE
  warning
elif grep -q '<package name="com.miui.home">' $FILE; then
  COUNT=1
  LIST=`cat $FILE | sed 's|><|>\n<|g'`
  RES=`echo "$LIST" | grep -A$COUNT '<package name="com.miui.home">'`
  until echo "$RES" | grep -q '</package>'; do
    COUNT=`expr $COUNT + 1`
    RES=`echo "$LIST" | grep -A$COUNT '<package name="com.miui.home">'`
  done
  if ! echo "$RES" | grep -q 'name="android.permission.DEVICE_POWER" granted="true"'\
  || ! echo "$RES" | grep -q 'name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true"'; then
    PATCH=true
  else
    PATCH=false
  fi
  if [ "$PATCH" == true ]; then
    sed -i 's|<package name="com.miui.home">|\
<package name="com.miui.home">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.REAL_GET_TASKS" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="miui.autoinstall.config.permission.AUTOINSTALL" granted="true" flags="0" />\
<permission name="android.permission.SET_PROCESS_LIMIT" granted="true" flags="0" />\
<permission name="android.permission.READ_CALENDAR" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_FINE_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="miui.os.permisson.INIT_MIUI_ENVIRONMENT" granted="true" flags="0" />\
<permission name="android.miui.permission.SHELL" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="miui.permission.USE_INTERNAL_GENERAL_API" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.BIND_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.START_ANY_ACTIVITY" granted="true" flags="0" />\
<permission name="com.android.SystemUI.permission.TIGGER_TOGGLE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.FOREGROUND_SERVICE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="com.miui.personalassistant.permission.ACCESS_ACTIVITY" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.miui.home.launcher.permission.LOADING_STATUS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_CONNECT" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH" granted="true" flags="0" />\
<permission name="com.android.alarm.permission.SET_ALARM" granted="true" flags="0" />\
<permission name="miui.personalassistant.ACCESS_PROVIDER" granted="true" flags="0" />\
<permission name="android.permission.GET_TASKS" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="miui.permission.ACCESS_ALARM_PROVIDER" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_ADMIN" granted="true" flags="0" />\
<permission name="android.permission.UPDATE_DEVICE_STATS" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.PACKAGE_USAGE_STATS" granted="true" flags="0" />\
<permission name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_COARSE_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.SET_ACTIVITY_WATCHER" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.systemui.permission.NOTIFICATION" granted="true" flags="0" />\
<permission name="android.permission.READ_PHONE_STATE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_DOWNLOAD_MANAGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_STICKY" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CAMERA" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_CALENDAR" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_AUDIO" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VIDEO" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_ADVERTISE" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.READ_SYNC_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.FORCE_STOP_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.CREATE_USERS" granted="true" flags="0" />\
<permission name="android.permission.GET_DETAILED_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_INSTALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.DUMP" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.WAKE_LOCK" granted="true" flags="0" />\
<permission name="android.permission.READ_CONTACTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.UPDATE_APP_OPS_STATS" granted="true" flags="0" />\
<permission name="android.permission.BLUETOOTH_SCAN" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_MEDIA_LOCATION" granted="true" flags="0" />\
<permission name="android.permission.MEDIA_CONTENT_CONTROL" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</package>\n<package name="removed">|g' $FILE
    warning
  fi
else
  warning_2
fi
}

# patch runtime-permissions.xml
ui_print "- Granting permissions"
ui_print "  Please wait..."
patch_runtime_permisions
ui_print " "







