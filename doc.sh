set -ex
rm -rf _docs
v fmt -w .
#pushd src
v doc -f html -m . -readme -comments -no-timestamp 
#-o ../
#popd

open _docs/index.html

# open https://threefoldfoundation.github.io/dao_research/liqpool/docs/liquidity.html