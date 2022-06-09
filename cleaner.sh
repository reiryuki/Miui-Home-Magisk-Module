MODPATH=${0%/*}
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
PKG="com.miui.home*
     com.miui.miwallpaper
     com.mfashiongallery.emag
     com.android.quicksearchbox
     com.miui.personalassistant
     com.mi.android.globalminusscreen"
for APPS in $APP; do
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APPS*.apk`
done
for PKGS in $PKG; do
  rm -rf /data/user/*/$PKGS/cache/*
done


