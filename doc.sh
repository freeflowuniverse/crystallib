set -ex
rm -rf _docs
rm -rf docs
v fmt -w .
#pushd src
v doc -m -f html . -readme -comments -no-timestamp 
#-o ../
#popd

mv _docs docs
open docs/index.html

# open https://threefoldfoundation.github.io/dao_research/liqpool/docs/liquidity.html