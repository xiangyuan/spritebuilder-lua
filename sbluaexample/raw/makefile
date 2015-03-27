.PHONY: common android ios 
tmpdir=../tmp
android:common
	make -C ui android

ios:common
	make -C ui ios

common:
	#copy the fonts
	
	mkdir -p $(tmpdir)/res_android/fonts
	mkdir -p $(tmpdir)/res_ios/fonts
	cp ./fonts/* $(tmpdir)/res_android/fonts
	cp ./fonts/* $(tmpdir)/res_ios/fonts




