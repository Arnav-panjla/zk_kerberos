# Makefile

.PHONY: all mopro flutter

all: mopro transfer flutter

mopro:
	@echo "Running mopro build and update..."
	mopro build
	mopro update

transfer:
	rm -rf flutter/android/app/src/main/jniLibs/arm64-v8a/
	mkdir -p flutter/android/app/src/main/jniLibs/arm64-v8a/
	cp -r MoproAndroidBindings/jniLibs/arm64-v8a/* ./flutter/android/app/src/main/jniLibs/arm64-v8a/
	@echo "sanity check"
	ls flutter/android/app/src/main/jniLibs/arm64-v8a/

flutter:
	@echo "Running flutter pub get and build..."
	cd flutter && flutter pub get && flutter run

