#!/usr/bin/env python3
"""Run once after `flutter create --platforms=android .`

Patches the generated Android project so that scheduled notifications work:
  * permissions + notification receivers in AndroidManifest.xml
  * core library desugaring in android/app/build.gradle(.kts)
  * app label ("ڕۆژان") and removal of the default widget test
"""
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
manifest = root / "android/app/src/main/AndroidManifest.xml"
if not manifest.exists():
    sys.exit("android/ folder not found. Run: flutter create --platforms=android .")

# ------------------------------------------------------------ manifest
m = manifest.read_text(encoding="utf-8")

perms = """    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
"""
receivers = """        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
"""

if "POST_NOTIFICATIONS" not in m:
    m = m.replace("<application", perms + "    <application", 1)
if "ScheduledNotificationReceiver" not in m:
    m = m.replace("</application>", receivers + "    </application>", 1)
m = re.sub(r'android:label="[^"]*"', 'android:label="ڕۆژان"', m, count=1)
manifest.write_text(m, encoding="utf-8")

# -------------------------------------------------------------- gradle
kts = root / "android/app/build.gradle.kts"
groovy = root / "android/app/build.gradle"

if kts.exists():
    g = kts.read_text(encoding="utf-8")
    if "isCoreLibraryDesugaringEnabled" not in g:
        g = re.sub(r"compileOptions\s*\{",
                   "compileOptions {\n        isCoreLibraryDesugaringEnabled = true", g, count=1)
    if "desugar_jdk_libs" not in g:
        g += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    kts.write_text(g, encoding="utf-8")
elif groovy.exists():
    g = groovy.read_text(encoding="utf-8")
    if "coreLibraryDesugaringEnabled" not in g:
        g = re.sub(r"compileOptions\s*\{",
                   "compileOptions {\n        coreLibraryDesugaringEnabled true", g, count=1)
    if "desugar_jdk_libs" not in g:
        g += "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"
    groovy.write_text(g, encoding="utf-8")
else:
    sys.exit("build.gradle(.kts) not found")

# The default generated test references a class that does not exist here.
t = root / "test/widget_test.dart"
if t.exists():
    t.unlink()

print("Android project patched successfully.")
