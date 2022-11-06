mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  . $FILE
fi

# context
if [ "$API" -ge 26 ]; then
  chcon -R u:object_r:vendor_overlay_file:s0 $MODPATH/system/product/overlay
fi

# conflict
#rtouch /data/adb/modules/quickstepswitcher/remove
#rtouch /data/adb/modules/quickswitch/remove

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

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  rm -f $FILE
fi


