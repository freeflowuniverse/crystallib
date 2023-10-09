set -ex
rm -rf _docs
rm -rf docs
v fmt -w src
#pushd src
v doc -m -f html src/. -readme -comments -no-timestamp 
#-o ../
#popd

mv _docs docs
open docs/index.html

# open https://threefoldfoundation.github.io/dao_research/liqpool/docs/liquidity.html