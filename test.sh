set -ex
pushd ~/code/github/freeflowuniverse/crystallib
bash doc.sh
v -stats test baobab/actions
v -stats test algo/encoder
v -stats test codeparser
v -stats test clients/coinmarketcap
v -stats test console
v -stats test crystaljson
v -stats test currency
v -stats test data
v -stats test docker
v -stats test algo/encoder
v -stats test imagemagick
v -stats test ipaddress
v -stats test markdowndocs
v -stats test mnemonic
v -stats test params
v -stats test pathlib
v -stats test redisclient
v -stats test resp
v -stats test texttools
v -stats test timetools
v -stats test gittools
v -stats test jsonrpc
v -stats test openrpc
v -stats test markdowndocs
v -stats test jsonschema
v -stats test osal

# OK TO IGNORE FOR NOW
# v -stats test tmux
# v -stats test knowledgetree
# v -stats test crpgp

popd


echo "TESTS OK"