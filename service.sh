(

MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# wait
sleep 60

# function
grant_permission() {
  UID=`pm list packages -U | grep $PKG | sed -n -e "s/package:$PKG uid://p"`
  pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
  pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE
  pm grant $PKG android.permission.ACCESS_MEDIA_LOCATION
  appops set --uid $UID LEGACY_STORAGE allow
  appops set $PKG READ_EXTERNAL_STORAGE allow
  appops set $PKG WRITE_EXTERNAL_STORAGE allow
  appops set $PKG READ_MEDIA_AUDIO allow
  appops set $PKG READ_MEDIA_VIDEO allow
  appops set $PKG READ_MEDIA_IMAGES allow
  appops set $PKG WRITE_MEDIA_AUDIO allow
  appops set $PKG WRITE_MEDIA_VIDEO allow
  appops set $PKG WRITE_MEDIA_IMAGES allow
  if [ "$API" -gt 29 ]; then
    appops set $PKG MANAGE_EXTERNAL_STORAGE allow
    appops set $PKG NO_ISOLATED_STORAGE allow
    appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
  fi
}

# grant
PKG=com.miui.home
pm grant $PKG android.permission.READ_CALENDAR
pm grant $PKG android.permission.WRITE_CALENDAR
pm grant $PKG android.permission.ACCESS_COARSE_LOCATION
pm grant $PKG android.permission.ACCESS_FINE_LOCATION
pm grant $PKG android.permission.READ_PHONE_STATE
pm grant $PKG android.permission.CALL_PHONE
pm grant $PKG android.permission.CAMERA
pm grant $PKG android.permission.READ_CONTACTS
grant_permission
appops set $PKG ACCESS_MEDIA_LOCATION allow
appops set $PKG GET_USAGE_STATS allow
appops set $PKG SYSTEM_ALERT_WINDOW allow

# grant
PKG=com.miui.miwallpaper
pm grant $PKG android.permission.READ_PHONE_STATE
pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE

# grant
PKG=com.mfashiongallery.emag
grant_permission
appops set --uid $UID ACCESS_MEDIA_LOCATION allow

# grant
PKG=com.android.quicksearchbox
pm grant $PKG android.permission.READ_CONTACTS
pm grant $PKG android.permission.READ_PHONE_STATE
grant_permission
appops set $PKG ACCESS_MEDIA_LOCATION allow

) 2>/dev/null


