set -ex
# pushd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
v -enable-globals -stats test crystallib/data/actionparser
v -enable-globals -stats test crystallib/algo/encoder
v -enable-globals -stats test crystallib/core/codeparser
v -enable-globals -stats test crystallib/clients/coinmarketcap
v -enable-globals -stats test crystallib/ui/console
v -enable-globals -stats test crystallib/core/crystaljson
v -enable-globals -stats test crystallib/data/currency
v -enable-globals -stats test crystallib/osal/docker
v -enable-globals -stats test crystallib/algo/encoder
v -enable-globals -stats test crystallib/tools/imagemagick
v -enable-globals -stats test crystallib/data/ipaddress
v -enable-globals -stats test crystallib/data/markdownparser
v -enable-globals -stats test crystallib/data/mnemonic
v -enable-globals -stats test crystallib/data/paramsparser
v -enable-globals -stats test crystallib/core/pathlib
v -enable-globals -stats test crystallib/clients/redisclient
v -enable-globals -stats test crystallib/data/resp
v -enable-globals -stats test crystallib/core/texttools
v -enable-globals -stats test crystallib/data/ourtime
v -enable-globals -stats test crystallib/osal/gittools
v -enable-globals -stats test crystallib/data/jsonrpc
v -enable-globals -stats test crystallib/core/openrpc
v -enable-globals -stats test crystallib/data/jsonschema
v -enable-globals -stats test crystallib/osal

# OK TO IGNORE FOR NOW
# v -stats test tmux
# v -stats test knowledgetree
# v -stats test crpgp

# popd


echo "TESTS OK"