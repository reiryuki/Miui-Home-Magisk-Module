mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`

# function
permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if ! setenforce 0; then
    echo 0 > /sys/fs/selinux/enforce
  fi
fi
}
magisk_permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
	magiskpolicy --live "permissive *"
  else
	$MODPATH/$ABI/libmagiskpolicy.so --live "permissive *"
  fi
fi
}
sepolicy_sh() {
if [ -f $FILE ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
    magiskpolicy --live --apply $FILE 2>/dev/null
  else
    $MODPATH/$ABI/libmagiskpolicy.so --live --apply $FILE 2>/dev/null
  fi
fi
}

# selinux
SELINUX=`getenforce`
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#1permissive
#2magisk_permissive
#kFILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

# list
(
PKGS="`cat $MODPATH/package.txt`
       com.miui.home:res_can_worker
       com.mfashiongallery.emag:gallery_wallpaper
       com.mfashiongallery.emag:pushservice
       com.miui.miwallpaper:daemon
       com.miui.miwallpaper:mamlSuperWallpaper
       com.miui.miwallpaper:settings
       com.mi.android.globalminusscreen:playcore_missing_splits_activity
       com.android.quicksearchbox:widgetProvider
       com.android.quicksearchbox:pushservice"
for PKG in $PKGS; do
  magisk --denylist rm $PKG
  magisk --sulist add $PKG
done
FILE=$MODPATH/tmp_file
magisk --hide sulist 2>$FILE
if [ "`cat $FILE`" == 'SuList is enforced' ]; then
  for PKG in $PKGS; do
    magisk --hide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk --hide rm $PKG
  done
fi
rm -f $FILE
) 2>/dev/null

# conflict
#rtouch /data/adb/modules/quickstepswitcher/disable
#rtouch /data/adb/modules/quickswitch/disable

# directory
DIR=/data/system/theme
mkdir -p $DIR
#chmod 0775 $DIR
#chown oem_9801.oem_9801 $DIR
#chcon u:object_r:theme_data_file:s0 $DIR
chmod 0777 $DIR
chown 1000.1000 $DIR
chcon u:object_r:app_data_file:s0 $DIR

# directory
DIR=/data/system/theme_magic
mkdir -p $DIR
#chmod 0775 $DIR
#chown oem_9801.oem_9801 $DIR
#chcon u:object_r:theme_data_file:s0 $DIR
chmod 0777 $DIR
chown 1000.1000 $DIR
chcon u:object_r:app_data_file:s0 $DIR

# permission
if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/vendor\
             $MODPATH/system/vendor -type d`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  if [ -L $MODPATH/system/product ]\
  && [ -d $MODPATH/product ]; then
    chcon -R u:object_r:vendor_overlay_file:s0 $MODPATH/product/overlay
  else
    chcon -R u:object_r:vendor_overlay_file:s0 $MODPATH/system/product/overlay
  fi
  if [ -L $MODPATH/system/vendor ]\
  && [ -d $MODPATH/vendor ]; then
    chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
    chcon -R u:object_r:vendor_overlay_file:s0 $MODPATH/vendor/overlay
  else
    chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
    chcon -R u:object_r:vendor_overlay_file:s0 $MODPATH/system/vendor/overlay
  fi
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE\.txt
fi










