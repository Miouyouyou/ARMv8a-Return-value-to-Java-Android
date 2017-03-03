[![Pledgie !](https://pledgie.com/campaigns/32702.png)](https://pledgie.com/campaigns/32702)
[![Tip with Altcoins](https://raw.githubusercontent.com/Miouyouyou/Shapeshift-Tip-button/9e13666e9d0ecc68982fdfdf3625cd24dd2fb789/Tip-with-altcoin.png)](https://shapeshift.io/shifty.html?destination=16zwQUkG29D49G6C7pzch18HjfJqMXFNrW&output=BTC)

# About

This example demonstrates how to :

* generate a library containing a procedure written in ARMv7 GNU ASsembly
* call this procedure from a Android app using the JNI
* use the returned value in the Android app and display it

# Requirements

* GNU AS
* Gold linker
* An ARM Android phone/emulator on which you have installation privileges

# Build

Run `make` from this folder

## Manually

Run the following commands :

```
# cross compiler prefix. Remove if you're assembling from an ARM machine
export PREFIX="armv7a-hardfloat-linux-gnueabi"
export DEST="./apk/app/src/main/jniLibs"
$PREFIX-as -o wild.o wild.s
$PREFIX-ld.gold -shared --dynamic-linker=/system/bin/linker -shared --hash-style=sysv -o libwildAssembly.so wild.o
cp libwildAssembly.so $DEST/armeabi/libwildAssembly.so
cp libwildAssembly.so $DEST/armeabi-v7a/libwildAssembly.so
```

# Install

Connect your ARMv7 Android phone/emulator and run `./gradlew installDebug` from the **apk** folder.

