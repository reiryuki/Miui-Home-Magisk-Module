MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug.log
set -x

# property
PROP=`getprop ro.product.device`
resetprop --delete ro.product.mod_device
#gresetprop ro.product.mod_device "$PROP"_global
resetprop ro.miui.ui.version.code 14

# wait
until [ "`getprop sys.boot_completed`" == "1" ]; do
  sleep 10
done

# function
grant_permission() {
appops set $PKG WRITE_SETTINGS allow
appops set $PKG SYSTEM_ALERT_WINDOW allow
pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE
if [ "$API" -ge 29 ]; then
  pm grant $PKG android.permission.ACCESS_MEDIA_LOCATION 2>/dev/null
  appops set $PKG ACCESS_MEDIA_LOCATION allow
fi
if [ "$API" -ge 33 ]; then
  (
  pm grant $PKG android.permission.READ_MEDIA_AUDIO
  pm grant $PKG android.permission.READ_MEDIA_VIDEO
  pm grant $PKG android.permission.READ_MEDIA_IMAGES
  ) 2>/dev/null
  appops set $PKG ACCESS_RESTRICTED_SETTINGS allow
fi
appops set $PKG LEGACY_STORAGE allow
appops set $PKG READ_EXTERNAL_STORAGE allow
appops set $PKG WRITE_EXTERNAL_STORAGE allow
appops set $PKG READ_MEDIA_AUDIO allow
appops set $PKG READ_MEDIA_VIDEO allow
appops set $PKG READ_MEDIA_IMAGES allow
appops set $PKG WRITE_MEDIA_AUDIO allow
appops set $PKG WRITE_MEDIA_VIDEO allow
appops set $PKG WRITE_MEDIA_IMAGES allow
if [ "$API" -ge 30 ]; then
  appops set $PKG MANAGE_EXTERNAL_STORAGE allow
  appops set $PKG NO_ISOLATED_STORAGE allow
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi
if [ "$API" -ge 31 ]; then
  appops set $PKG MANAGE_MEDIA allow
fi
PKGOPS=`appops get $PKG`
UID=`dumpsys package $PKG 2>/dev/null | grep -m 1 userId= | sed 's/    userId=//'`
if [ "$UID" -gt 9999 ]; then
  appops set --uid "$UID" LEGACY_STORAGE allow
  if [ "$API" -ge 29 ]; then
    appops set --uid "$UID" ACCESS_MEDIA_LOCATION allow
  fi
  UIDOPS=`appops get --uid "$UID"`
fi
}

# grant
PKG=com.miui.home
pm grant $PKG android.permission.READ_CALENDAR
pm grant $PKG android.permission.WRITE_CALENDAR
pm grant $PKG android.permission.READ_PHONE_STATE
pm grant $PKG android.permission.CALL_PHONE
pm grant $PKG android.permission.CAMERA
pm grant $PKG android.permission.READ_CONTACTS
appops set $PKG GET_USAGE_STATS allow
grant_permission

# grant
PKG=com.miui.miwallpaper
pm grant $PKG android.permission.READ_PHONE_STATE
grant_permission

# grant
PKG=com.mfashiongallery.emag
grant_permission

# grant
PKG=com.android.quicksearchbox
if pm list packages | grep $PKG; then
  pm grant $PKG android.permission.READ_CONTACTS
  pm grant $PKG android.permission.READ_PHONE_STATE
  grant_permission
fi

# grant
PKG=com.miui.personalassistant
if pm list packages | grep $PKG; then
  grant_permission
fi

# grant
PKG=com.mi.android.globalminusscreen
if pm list packages | grep $PKG; then
  pm grant $PKG android.permission.READ_CALENDAR
  pm grant $PKG android.permission.WRITE_CALENDAR
  appops set $PKG GET_USAGE_STATS allow
  grant_permission
fi















