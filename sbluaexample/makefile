.PHONY: all ccb fonts res_ios res_android android ios clean

all:ccb android

ccb: fonts
	mkdir -p res/ccb
	cd tools && sh ccb2json.sh ../res/ccb && cd ..

fonts:
	# covert to json
	plutil -convert json raw/example.spritebuilder/Packages/SpriteBuilder\ Resources.sbpack/Strings.ccbLang -o raw/fonts/Strings.json

android:res_android ccb
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

