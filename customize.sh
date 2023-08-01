# space
ui_print " "

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/sdcard/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
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
  ui_print "  at least SDK API $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# miuicore
if [ ! -d /data/adb/modules_update/MiuiCore ]\
&& [ ! -d /data/adb/modules/MiuiCore ]; then
  ui_print "! Miui Core Magisk Module is not installed."
  ui_print "  Please read github installation guide!"
  abort
else
  rm -f /data/adb/modules/MiuiCore/remove
  rm -f /data/adb/modules/MiuiCore/disable
fi

# recovery
mount_partitions_in_recovery

# optionals
OPTIONALS=/sdcard/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# global
FILE=$MODPATH/service.sh
if [ "`grep_prop miui.global $OPTIONALS`" == 1 ]; then
  ui_print "- Global mode"
  rm -rf `find $MODPATH/system -type d -name QuickSearchBox -o -name PersonalAssistant`
  sed -i 's|#g||g' $FILE
  ui_print " "
else
  rm -rf `find $MODPATH/system -type d -name GlobalMinusScreen`
fi

# code
NAME=ro.miui.ui.version.code
if [ "`grep_prop miui.code $OPTIONALS`" == 0 ]; then
  ui_print "- Removing $NAME..."
  sed -i "s|resetprop $NAME|#resetprop $NAME|g" $MODPATH/service.sh
  ui_print " "
fi

# cleaning
ui_print "- Cleaning..."
PKGS=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    RES=`pm uninstall $PKG 2>/dev/null`
  done
fi
remove_sepolicy_rule
ui_print " "

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
  rm -rf /metadata/magisk/$NAME
  rm -rf /mnt/vendor/persist/magisk/$NAME
  rm -rf /persist/magisk/$NAME
  rm -rf /data/unencrypted/magisk/$NAME
  rm -rf /cache/magisk/$NAME
  rm -rf /cust/magisk/$NAME
done
}

# conflict
NAMES=MiWallpaperCarousel
conflict

# recents
if [ "`grep_prop miui.recents $OPTIONALS`" == 1 ]; then
  RECENTS=true
  ui_print "- $MODNAME recents provider will be activated"
  ui_print "  Quick Switch module will be disabled"
  touch /data/adb/modules/quickstepswitcher/disable
  touch /data/adb/modules/quickswitch/disable
  sed -i 's|#r||g' $MODPATH/post-fs-data.sh
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
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's|^data.cleanup=1|data.cleanup=0|g' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
#elif [ -d $DIR ] && ! grep -q "$MODNAME" $FILE; then
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
  mv -f $MODPATH/system/product $MODPATH/system/vendor
  ui_print " "
fi

# media
if [ ! -d /product/media ] && [ -d /system/media ]; then
  ui_print "- Using /system/media instead of /product/media"
  mv -f $MODPATH/system/product/media $MODPATH/system
  rm -rf $MODPATH/system/product
  sed -i 's|/product|/system|g' $MODPATH/system/media/theme/.data/meta/*/*.mrm
  ui_print " "
elif [ ! -d /product/media ] && [ ! -d /system/media ]; then
  ui_print "! /product/media & /system/media not found"
  ui_print " "
fi










