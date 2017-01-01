CROSS_COMPILE = armv7a-hardfloat-linux-gnueabi-
LD = $(CROSS_COMPILE)ld.gold
AS = $(CROSS_COMPILE)as
ANDROID_APK_NATIVE_LIB_DIR = ./apk/app/src/main/jniLibs
ANDROID_LIBNAME = libwildAssembly.so
SOURCE = wild.s
OBJECT = wild.o

.PHONY: all
all: $(OBJECT)
	$(LD) -shared --dynamic-linker=/system/bin/linker --hash-style=sysv -o $(ANDROID_LIBNAME) wild.o
	mkdir -p $(ANDROID_APK_NATIVE_LIB_DIR)/armeabi{,-v7a}
	cp $(ANDROID_LIBNAME) $(ANDROID_APK_NATIVE_LIB_DIR)/armeabi
	cp $(ANDROID_LIBNAME) $(ANDROID_APK_NATIVE_LIB_DIR)/armeabi-v7a

$(OBJECT): $(SOURCE)
	$(AS) -o $(OBJECT) wild.s

.PHONY: clean
clean:
	$(RM) $(OBJECT) $(ANDROID_LIBNAME)

.PHONY: distclean
distclean: clean
	$(RM) $(ANDROID_APK_NATIVE_LIB_DIR)/armeabi/$(ANDROID_LIBNAME)
	$(RM) $(ANDROID_APK_NATIVE_LIB_DIR)/armeabi-v7a/$(ANDROID_LIBNAME)
