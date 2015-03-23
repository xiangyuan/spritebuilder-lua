platform=$1
filename=$2
dest_dir=$3/${filename}
mkdir -p ${dest_dir}/res_android
mkdir -p ${dest_dir}/res_ios

if [ "$platform" = "android" ]; then
	echo buiding Resources Android start
	mkdir -p ${dest_dir}
	rm -rf ${filename}.png ${filename}.plist 
	texturepacker --data ${filename}.plist  --allow-free-size --algorithm MaxRects --maxrects-heuristics best --shape-padding 2 --border-padding 0 --padding 0 --inner-padding 0 --disable-rotation --opt RGBA8888 --dither-none-nn --dpi 72 --format cocos2d ../${filename} --sheet ${filename}.png
	mv ${filename}.plist ${filename}.png ${dest_dir}
	echo @@@@ building common resource done!
fi
	
if [ "$platform" = "ios" ]; then
	echo buiding Resources ios start
	mkdir -p ${dest_dir}
	rm -rf ${filename}.pvr.ccz ${filename}.plist 
	texturepacker --texture-format pvr2ccz --data ${filename}.plist  --allow-free-size --algorithm MaxRects --maxrects-heuristics best --shape-padding 2 --border-padding 0 --padding 0 --inner-padding 0 --disable-rotation --opt PVRTC4 --dither-none-nn --dpi 72 --format cocos2d ../${filename} --sheet ${filename}.pvr.ccz
	mv ${filename}.plist ${filename}.pvr.ccz ${dest_dir}
	echo @@@@ building common resource done!
fi
	