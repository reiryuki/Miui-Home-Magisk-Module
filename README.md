# Miui Home Magisk Module

## DISCLAIMER
- Miui apps are owned by Xiaomi™.
- The MIT license specified here is for the Magisk Module only, not for Miui apps.

## Descriptions
- Home launcher app by Xiaomi Inc. ported and integrated as a Magisk Module for all supported and rooted devices with Magisk

## Sources
- https://apkmirror.com com.miui.home & com.android.quicksearchbox by Xiaomi Inc.

## Screenshots
- https://t.me/androidryukimods/370

## Requirements
- NOT in Miui ROM
- Android 5 and up
- Magisk or KernelSU installed
- Miui Core Magisk Module installed
- Gesture navigation requires android.permission.INJECT_EVENTS. The permission can only be granted in AOSP signatured ROM or disabled Android Signature Verification in Android 13 and bellow.

## Installation Guide & Download Link
- Install Miui Core Magisk Module first: https://github.com/reiryuki/Miui-Core-Magisk-Module
- If you want to activate the recents provider, READ Optionals bellow!
- Install this module https://www.pling.com/p/1680776/ via Magisk app or KernelSU app or Recovery if Magisk installed
- If you want App Vault to be working, install Miui App Vault Magisk Module: https://github.com/reiryuki/Miui-App-Vault-Magisk-Module & Miui Security Magisk Module: https://github.com/reiryuki/Miui-Security-Center-Magisk-Module except in global mode
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (enable show system apps) and reboot afterwards
- Change your default launcher to this Miui Home System Launcher via Settings app (or you can copy the content of default.sh and paste it to Termux app. Type su and grant root first!)
- If you change from hardware navbar to software navbar or vice-versa, you need to force stop this launcher to fix display bug.

## Known Issues
- Some widgets doesn't work
- Uninstall app requires 2 confirmations
- Minimize button in Freeform window doesn't work because I'm using "setTaskAlwaysOnTop" method so it can be showed on top of current task
- Split screen doesn't work except this launcher is set as default launcher if the recents provider is activated

## Optionals
- https://t.me/androidryukimodsdiscussions/54012
- Global: https://t.me/androidryukimodsdiscussions/60861

## Troubleshootings
- https://t.me/androidryukimodsdiscussions/64467
- Global: https://t.me/androidryukimodsdiscussions/29836

## Support & Bug Report
- https://t.me/androidryukimodsdiscussions/2618
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
- https://t.me/androidryukimodsdiscussions/2619


