If you appreciate this project, support me on Patreon !
[![Patreon !](https://raw.githubusercontent.com/Miouyouyou/RockMyy/master/.img/button-patreon.png)](https://www.patreon.com/Miouyouyou)

[![Pledgie !](https://pledgie.com/campaigns/32702.png)](https://pledgie.com/campaigns/32702)
[![Tip with Altcoins](https://raw.githubusercontent.com/Miouyouyou/Shapeshift-Tip-button/9e13666e9d0ecc68982fdfdf3625cd24dd2fb789/Tip-with-altcoin.png)](https://shapeshift.io/shifty.html?destination=16zwQUkG29D49G6C7pzch18HjfJqMXFNrW&output=BTC)

# About

This example demonstrates how to :

* assemble a library written with the ARMv8-A 64 bits GNU ASsembly syntax
* call this procedure from a Android app using the JNI
* display the value returned by this procedure in the Android app

# Building
## Building using GNU Make

### Requirements

* GNU AS (aarch64)
* Gold linker (aarch64)
* An ARM Android phone/emulator on which you have installation privileges

### Build

Run `make` from this folder

#### Manually

Run the following commands :

```
# cross compiler prefix. Remove if you're assembling from an ARM machine
export PREFIX="aarch64-linux-gnu-"
export DEST="./apk/app/src/main/jniLibs"
$PREFIX-as -o wild.o wild.s
$PREFIX-ld.gold -shared --dynamic-linker=/system/bin/linker -shared --hash-style=sysv -o libwildAssembly.so wild.o
cp libwildAssembly.so $DEST/armeabi/libwildAssembly.so
cp libwildAssembly.so $DEST/armeabi-v7a/libwildAssembly.so
```
## Building using Android ndk-build

### Requirements

* The Android NDK path in your system's PATH directory

### Build

Open a shell or a *command window* in this folder and :
* On Windows, run 'mkbuild'
* On Linux, run 'mkbuild.sh'

# Installing the prepared APK

* Connect your ARMv8-A Android phone/emulator
* open a shell or a "command window"
* `cd` to the **apk** folder

Then :
* On Windows run `gradlew installDebug`.
* On Linux run `./gradlew installDebug`

# Install

Connect your ARMv7 Android phone/emulator and run `./gradlew installDebug` from the **apk** folder.

