set -ex
cd ~/code/github/freeflowuniverse/crystallib

rm -rf _docs
rm -rf docs

cd crystallib

rm -rf _docs
rm -rf docs

v fmt -w .
v doc -m -f html . -readme -comments -no-timestamp

mv _docs ../docs

if ! [[ ${OSTYPE} == "linux-gnu"* ]]; then
    open docs/index.html
fi

