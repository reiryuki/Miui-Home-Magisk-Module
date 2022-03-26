copy_library() {
if echo "$PROP" | grep 64; then
  DES="`find /data/app -type d -name *$PKG*`/lib/*64"
  if echo $DES | grep $PKG; then
    for NAMES in $NAME; do
      if [ -f /system/lib64/$NAMES ]; then
        cp -f /system/lib64/$NAMES $DES
      else
        cp -f /system/apex/*/lib64/$NAMES $DES
      fi
    done
    chmod 0755 $DES/*
    chown 1000.1000 $DES/*
  fi
else
  DES="`find /data/app -type d -name *$PKG*`/lib/*"
  if echo $DES | grep $PKG; then
    for NAMES in $NAME; do
      if [ -f /system/lib/$NAMES ]; then
        cp -f /system/lib/$NAMES $DES
      else
        cp -f /system/apex/*/lib/$NAMES $DES
      fi
    done
    chmod 0755 $DES/*
    chown 1000.1000 $DES/*
  fi
fi
}

PROP=`getprop ro.product.cpu.abi`

PKG=com.miui.home
NAME="libmiuinative.so
      libthemeutils_jni.so
      libshell_jni.so
      libshell.so
      libnativehelper.so"
copy_library

PKG=com.mfashiongallery.emag
NAME="libmiuinative.so
      libnativehelper.so"
copy_library

PKG=com.miui.miwallpaper
NAME="libmiuinative.so
      libnativehelper.so"
copy_library

PKG=com.android.quicksearchbox
NAME="libmiuinative.so
      libnativehelper.so"
copy_library


