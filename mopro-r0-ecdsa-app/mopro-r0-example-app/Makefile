# Makefile

.PHONY: all mopro flutter

all: mopro flutter

mopro:
	@echo "Running mopro build and update..."
	mopro build
	mopro update

flutter:
	@echo "Running flutter pub get and build..."
	cd flutter && flutter pub get && flutter run

