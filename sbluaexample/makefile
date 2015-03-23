.PHONY: all ccb res_ios res_android android ios clean

all:ccb android

ccb:
	sh tools/ccb2json.sh raw/example.spritebuilder/Packages/SpriteBuilder\ Resources.sbpack res/ccb

android:res_android
	mkdir -p res/images
	cp tmp/res_android/ui/* res/images/

	mkdir -p res/fonts
	cp tmp/res_android/fonts/* res/fonts/

ios:res_ios
	mkdir -p res/images
	cp tmp/res_ios/ui/* res/images/

	mkdir -p res/fonts
	cp tmp/res_ios/fonts/* res/fonts/
res_ios:
	make -C raw ios

res_android:
	make -C raw android

clean:
	-rm -rf tmp/*
	-rm -rf res/*

