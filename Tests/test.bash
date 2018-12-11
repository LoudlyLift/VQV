#!/bin/bash
MAX_COUNT="$1"

IN_SUFFIX=".yuv"
OUT_SUFFIX=".hevc"
TEST_DIR="$HOME/UA/CurrSem/VQV/Kvazaar/Tests/"
RAW_DIR="$TEST_DIR/Raw"
REF_DIR="$TEST_DIR/Standard"
TMP_DIR="/tmp/test_kvazaar"
/bin/rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

if [ "$MAX_COUNT" = "" ]; then
	MAX_COUNT=-1;
fi

echo Hello, World!

#Build Kvazaar
pushd "$HOME/UA/CurrSem/VQV/Kvazaar/"
echo "###BUILDING###"
make -j
sudo make install

#Encode test files
echo "###TESTING###"
cd "$RAW_DIR"
for x in *.yuv; do
	if [ $MAX_COUNT -eq 0 ]; then
		break
	fi
	fIn="./$x"
	fOut="${TMP_DIR}/${x/$IN_SUFFIX}$OUT_SUFFIX"
	fRef="${REF_DIR}/${x/$IN_SUFFIX}$OUT_SUFFIX"

	kvazaar -i "$fIn" -o "$fOut" > /dev/null 2>&1 && echo "$x completed" || (echo failed "$x"; break);

	fInSize=$(du "$fIn" | cut -f 1)
	fOutSize=$(du "$fOut" | cut -f 1)
	fRefSize=$(du "$fRef" | cut -f 1)

	prcnt=$((100*$fOutSize/$fRefSize))
	echo "$x is ${prcnt}% the size of the reference implementation"

	MAX_COUNT=$((MAX_COUNT - 1))
done
