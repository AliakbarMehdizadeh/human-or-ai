"""Applies app name, app ID, icon, target SDK and release signing to the
Android project that `flutter create` generates. Safe to run more than once.
Run from the project root: python3 tool/configure_android.py
"""
import os
import re
import shutil
import sys

APP_ID = "io.github.aliakbarmehdizadeh.humanorai"
APP_NAME = "Human or AI?"
MIN_TARGET_SDK = 36  # Google Play requirement from Aug 31, 2026

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GRADLE = os.path.join(ROOT, "android", "app", "build.gradle.kts")
MANIFEST = os.path.join(ROOT, "android", "app", "src", "main", "AndroidManifest.xml")
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
ICONS = os.path.join(ROOT, "branding", "android")


def fail(msg):
    print("configure_android: " + msg, file=sys.stderr)
    sys.exit(1)


def sub_once(pattern, repl, text, what):
    new, n = re.subn(pattern, repl, text, count=1)
    if n == 0:
        fail("could not find " + what + " in build.gradle.kts")
    return new


def patch_gradle():
    if not os.path.exists(GRADLE):
        fail("android/app/build.gradle.kts not found (run flutter create first)")
    g = open(GRADLE).read()

    if "keystoreProperties" not in g:
        g = "import java.util.Properties\nimport java.io.FileInputStream\n\n" + g
        g = sub_once(
            r"\nandroid \{",
            '\nval keystoreProperties = Properties()\n'
            'val keystorePropertiesFile = rootProject.file("key.properties")\n'
            "if (keystorePropertiesFile.exists()) {\n"
            "    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n"
            "}\n\nandroid {",
            g, "android { block")
        g = sub_once(
            r"\n([ \t]*)buildTypes \{",
            "\n\\1signingConfigs {\n"
            '\\1    create("release") {\n'
            "\\1        if (keystorePropertiesFile.exists()) {\n"
            '\\1            keyAlias = keystoreProperties["keyAlias"] as String\n'
            '\\1            keyPassword = keystoreProperties["keyPassword"] as String\n'
            '\\1            storeFile = file(keystoreProperties["storeFile"] as String)\n'
            '\\1            storePassword = keystoreProperties["storePassword"] as String\n'
            "\\1        }\n"
            "\\1    }\n"
            "\\1}\n\\1buildTypes {",
            g, "buildTypes block")
        g = sub_once(
            r'signingConfig = signingConfigs\.getByName\("debug"\)',
            'signingConfig = if (keystorePropertiesFile.exists()) '
            'signingConfigs.getByName("release") else signingConfigs.getByName("debug")',
            g, "release signingConfig line")

    g = sub_once(r'applicationId = "[^"]*"', 'applicationId = "%s"' % APP_ID, g, "applicationId")
    g = re.sub(r"targetSdk = flutter\.targetSdkVersion\b",
               "targetSdk = maxOf(flutter.targetSdkVersion, %d)" % MIN_TARGET_SDK, g)
    g = re.sub(r"compileSdk = flutter\.compileSdkVersion\b",
               "compileSdk = maxOf(flutter.compileSdkVersion, %d)" % MIN_TARGET_SDK, g)
    open(GRADLE, "w").write(g)


def patch_manifest():
    m = open(MANIFEST).read()
    m, n = re.subn(r'android:label="[^"]*"', 'android:label="%s"' % APP_NAME, m, count=1)
    if n == 0:
        fail("could not find android:label in AndroidManifest.xml")
    open(MANIFEST, "w").write(m)


def copy_icons():
    for d in os.listdir(ICONS):
        dst = os.path.join(RES, d)
        os.makedirs(dst, exist_ok=True)
        shutil.copy(os.path.join(ICONS, d, "ic_launcher.png"), os.path.join(dst, "ic_launcher.png"))


if __name__ == "__main__":
    patch_gradle()
    patch_manifest()
    copy_icons()
    print("configure_android: done (app id %s)" % APP_ID)
