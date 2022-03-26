(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
fi

# dependency
#rm -f /data/adb/modules/MiuiCore/remove
#rm -f /data/adb/modules/MiuiCore/disable

# directory
DIR=/data/system/theme
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi
#chmod 0775 $DIR
#chown oem_9801.oem_9801 $DIR
#magiskpolicy "dontaudit theme_data_file labeledfs filesystem associate"
#magiskpolicy "allow     theme_data_file labeledfs filesystem associate"
#magiskpolicy "dontaudit init theme_data_file dir relabelfrom"
#magiskpolicy "allow     init theme_data_file dir relabelfrom"
#chcon u:object_r:theme_data_file:s0 $DIR
#magiskpolicy --live "type theme_data_file"
chmod 0777 $DIR
chown 1000.1000 $DIR
magiskpolicy "dontaudit app_data_file labeledfs filesystem associate"
magiskpolicy "allow     app_data_file labeledfs filesystem associate"
magiskpolicy "dontaudit init app_data_file dir relabelfrom"
magiskpolicy "allow     init app_data_file dir relabelfrom"
chcon u:object_r:app_data_file:s0 $DIR
magiskpolicy --live "type app_data_file"

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi

) 2>/dev/null






