PKG="com.miui.home*
     com.miui.miwallpaper
     com.mfashiongallery.emag
     com.android.quicksearchbox
     com.miui.personalassistant
     com.mi.android.globalminusscreen"
for PKGS in $PKG; do
  rm -rf /data/user/*/$PKGS/cache/*
done


