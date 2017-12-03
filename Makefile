CROSS_COMPILE = aarch64-linux-gnu-
LD = $(CROSS_COMPILE)ld.gold
AS = $(CROSS_COMPILE)as
ANDROID_APK_NATIVE_LIB_DIR = ./apk/app/src/main/jniLibs
ANDROID_LIBNAME = libwildAssembly.so
SOURCE = wild.s
OBJECT = wild.o

.PHONY: all
all: $(OBJECT)
	$(LD) -shared --dynamic-linker=/system/bin/linker --hash-style=sysv -o $(ANDROID_LIBNAME) wild.o
	mkdir -p $(ANDROID_APK_NATIVE_LIB_DIR)/arm64-v8a
	cp $(ANDROID_LIBNAME) $(ANDROID_APK_NATIVE_LIB_DIR)/arm64-v8a

$(OBJECT): $(SOURCE)
	$(AS) -o $(OBJECT) wild.s

.PHONY: clean
clean:
	$(RM) $(OBJECT) $(ANDROID_LIBNAME)

.PHONY: distclean
distclean: clean
	$(RM) $(ANDROID_APK_NATIVE_LIB_DIR)/arm64-v8a/$(ANDROID_LIBNAME)
