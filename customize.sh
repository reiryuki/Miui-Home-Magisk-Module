ui_print " "

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
ui_print " MagiskVersion=$MAGISK_VER"
ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
ui_print " "

# sdk
NUM=21
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK API $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# sepolicy.rule
if [ "$BOOTMODE" != true ]; then
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi
FILE=$MODPATH/sepolicy.sh
DES=$MODPATH/sepolicy.rule
if [ -f $FILE ] && ! getprop | grep -Eq "sepolicy.sh\]: \[1"; then
  mv -f $FILE $DES
  sed -i 's/magiskpolicy --live "//g' $DES
  sed -i 's/"//g' $DES
fi

# miuicore
if [ ! -d /data/adb/modules_update/MiuiCore ] && [ ! -d /data/adb/modules/MiuiCore ]; then
  ui_print "! Miui Core Magisk Module is not installed."
  ui_print "  Please read github installation guide!"
  abort
else
  rm -f /data/adb/modules/MiuiCore/remove
  rm -f /data/adb/modules/MiuiCore/disable
fi

# miuisettingsmod
if [ ! -d /data/adb/modules_update/MiuiSettingsMod ] && [ ! -d /data/adb/modules/MiuiSettingsMod ]; then
  ui_print "! Miui Settings Mod Magisk Module is not installed."
  ui_print "  Please read github installation guide!"
  abort
else
  rm -f /data/adb/modules/MiuiSettingsMod/remove
  rm -f /data/adb/modules/MiuiSettingsMod/disable
fi

# global
FILE=$MODPATH/service.sh
if getprop | grep -Eq "miui.global\]: \[1"; then
  ui_print "- Global mode"
  rm -rf `find $MODPATH/system -type d -name QuickSearchBox -o -name PersonalAssistant`
  sed -i 's/#g//g' $FILE
  ui_print " "
else
  rm -rf `find $MODPATH/system -type d -name GlobalMinusScreen`
fi

# code
NAME=ro.miui.ui.version.code
if getprop | grep -Eq "miui.code\]: \[0"; then
  ui_print "- Removing $NAME..."
  sed -i "s/resetprop $NAME/#resetprop $NAME/g" $FILE2
  ui_print " "
fi

# cleaning
ui_print "- Cleaning..."
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
PKG="com.miui.home
     com.miui.miwallpaper
     com.mfashiongallery.emag
     com.android.quicksearchbox
     com.miui.personalassistant
     com.mi.android.globalminusscreen"
if [ "$BOOTMODE" == true ]; then
  for PKGS in $PKG; do
    RES=`pm uninstall $PKGS`
  done
fi
for APPS in $APP; do
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APPS*.apk`
done
rm -rf /metadata/magisk/$MODID
rm -rf /mnt/vendor/persist/magisk/$MODID
rm -rf /persist/magisk/$MODID
rm -rf /data/unencrypted/magisk/$MODID
rm -rf /cache/magisk/$MODID
ui_print " "

# function
conflict() {
for NAMES in $NAME; do
  DIR=/data/adb/modules_update/$NAMES
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAMES
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAMES/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAMES
  rm -rf /mnt/vendor/persist/magisk/$NAMES
  rm -rf /persist/magisk/$NAMES
  rm -rf /data/unencrypted/magisk/$NAMES
  rm -rf /cache/magisk/$NAMES
done
}

# conflict
NAME=MiWallpaperCarousel
conflict

# recents
if getprop | grep -Eq "miui.recents\]: \[1"; then
  ui_print "- $MODNAME recents provider will be activated"
  NAME=quickstepswitcher
  conflict
  ui_print " "
else
  rm -rf $MODPATH/system/product
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
if getprop | grep -Eq "miui.cleanup\]: \[1"; then
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
elif [ -d $DIR ] && ! grep -Eq "$MODNAME" $FILE; then
  ui_print "- Different version detected"
  ui_print "  Cleaning-up $MODID data..."
  cleanup
  ui_print " "
fi

# function
permissive() {
  SELINUX=`getenforce`
  if [ "$SELINUX" == Enforcing ]; then
    setenforce 0
    SELINUX=`getenforce`
    if [ "$SELINUX" == Enforcing ]; then
      ui_print "  ! Your device can't be turned to Permissive state."
    fi
    setenforce 1
  fi
  sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  setenforce 0\
fi\' $MODPATH/post-fs-data.sh
}

# permissive
if getprop | grep -Eq "permissive.mode\]: \[1"; then
  ui_print "- Using permissive method"
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif getprop | grep -Eq "permissive.mode\]: \[2"; then
  ui_print "- Using both permissive and SE policy patch"
  permissive
  ui_print " "
fi

# function
extract_lib() {
  for APPS in $APP; do
    ui_print "- Extracting..."
    FILE=`find $MODPATH/system -type f -name $APPS.apk`
    if [ $APPS == QuickSearchBox ] && [ "$ARCH" == x64 ]; then
      DIR=`find $MODPATH/system -type d -name $APPS`/lib/x86
    else
      DIR=`find $MODPATH/system -type d -name $APPS`/lib/"$ARCH"
    fi
    mkdir -p $DIR
    rm -rf $TMPDIR/*
    if [ $APPS == QuickSearchBox ] && [ "$ARCH" == x64 ]; then
      unzip -d $TMPDIR -o $FILE lib/x86/*
      cp -f $TMPDIR/lib/x86/* $DIR
    else
      unzip -d $TMPDIR -o $FILE $DES
      cp -f $TMPDIR/$DES $DIR
    fi
    ui_print " "
  done
}

# extract
DES=lib/`getprop ro.product.cpu.abi`/*
extract_lib

# function
hide_oat() {
for APPS in $APP; do
  mkdir -p `find $MODPATH/system -type d -name $APPS`/oat
  touch `find $MODPATH/system -type d -name $APPS`/oat/.replace
done
}

# hide
hide_oat

# permission
if [ "$API" -ge 26 ]; then
  ui_print "- Setting permission..."
  magiskpolicy --live "type vendor_overlay_file"
  magiskpolicy --live "dontaudit vendor_overlay_file labeledfs filesystem associate"
  magiskpolicy --live "allow     vendor_overlay_file labeledfs filesystem associate"
  magiskpolicy --live "dontaudit init vendor_overlay_file dir relabelfrom"
  magiskpolicy --live "allow     init vendor_overlay_file dir relabelfrom"
  magiskpolicy --live "dontaudit init vendor_overlay_file file relabelfrom"
  magiskpolicy --live "allow     init vendor_overlay_file file relabelfrom"
  chcon -R u:object_r:vendor_overlay_file:s0 $MODPATH/system/product/overlay
  ui_print " "
fi






