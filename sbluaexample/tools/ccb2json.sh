DST_DIR=$1
INPUT_DIR="../raw/example.spritebuilder/Packages/SpriteBuilder Resources.sbpack/"
PWD=`pwd`
RESULT_DIR=${PWD}/${DST_DIR}

cd "${INPUT_DIR}"
echo Convert:
for i in `ls *.ccb`; do
	plutil -convert json ${i%.*}.ccb -o ${RESULT_DIR}/${i%.*}.json
    echo  "    "${i}  finished!
done
