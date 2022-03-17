#!/bin/bash
TMP_DIR=/tmp/crpgp
TMP_LIB_PATH=$TMP_DIR/libcrpgp.so
TMP_HEADER_PATH=$TMP_DIR/crpgp.h
CRPGP_DIR=$HOME/.vmodules/despiegk/crystallib/crpgp
V_CRPGP_PATH=$CRPGP_DIR/crpgp.v

# mkdir TMP_DIR
mkdir -p $TMP_DIR

# Download crpgp lib and header file
echo "- Download libcrpgp.so"
curl -L https://github.com/threefoldtech/crpgp/releases/download/v0.0.1/libcrpgp.so --output $TMP_LIB_PATH
echo "- Download crpgp.h"
curl -L https://github.com/threefoldtech/crpgp/releases/download/v0.0.1/crpgp.h --output $TMP_HEADER_PATH
echo "✅ Downloaded!"
# Update crpgp.v (if crystallib in vmodules)
if [ -d $CRPGP_DIR ]; then
	echo "- Updating crpgp.v ..."
	echo -e 'module crpgp\n' >$V_CRPGP_PATH
	cat $TMP_HEADER_PATH |
		egrep -o 'struct [a-zA-Z_]+' |
		sort | uniq |
		sed 's/struct \([a-zA-Z]*\)/struct C.\1 {}\nstruct \1 {\n    internal \&C.\1\n}/g' \
			>>$V_CRPGP_PATH

	cat $TMP_HEADER_PATH |
		sed -z 's/\n\s\s\s*/ /g' |
		grep ');' |
		sed 's/ [*]/* /g' |
		sed 's/ [a-z_][a-z_]*[)]/\)/g' |
		sed 's/struct \([a-zA-Z_]*\)[*]/\&C.\1/g' |
		sed 's/struct \([a-zA-Z_]*\)/C.\1/g' |
		sed -z 's/ [a-z_]*,/,/g' |
		sed 's/^\([^ ]*\) \(.*\);$/fn C.\2 \1/g' |
		sed 's/uint8_t/u8/g' |
		sed 's/size_t/u64/g' |
		sed 's/\([a-zA-Z0-9]*\)[*]/\&\1/g' |
		sed 's/[(]void[)]/()/g' \
			>>$V_CRPGP_PATH
	echo "✅ Updated!"
else
	echo "- Crystallib not found"
fi

# Move crpgp lib and header file in system dirs
sudo mv $TMP_LIB_PATH /usr/lib
sudo mv $TMP_HEADER_PATH /usr/include

# Delete tmp files
rm -rf $TMP_DIR

echo "✅ Installation Done!"
