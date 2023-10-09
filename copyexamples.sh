
set -ex

# mkdir -p examples/tools/tmux
# mkdir -p examples/tools/vault
# mkdir -p examples/core/openrpc
# mkdir -p examples/core/pathlib
# mkdir -p examples/web/auth
# mkdir -p examples/web/publisher2
# mkdir -p examples/osal/docker
# mkdir -p examples/osal/sandbox
# mkdir -p examples/osal
# mkdir -p examples/algo/crpgp
# mkdir -p examples/algo/encoder
# mkdir -p examples/baobab/context
# mkdir -p examples/baobab/spawner
# mkdir -p examples/baobab/taskletmanager
# mkdir -p examples/baobab/jobs
# mkdir -p examples/threefold/web3gw
# mkdir -p examples/threefold/actions_3script/blockchain
# mkdir -p examples/threefold/nodepilot
# mkdir -p examples/threefold/grid
# mkdir -p examples/knowledgetree/testdata
# mkdir -p examples/data/resp
# mkdir -p examples/data/vstor
# mkdir -p examples/data/params/
# mkdir -p examples/builder
# mkdir -p examples/servers/filedb
# mkdir -p examples/installers



# rsync -rav src/ui/console/examples examples/ui/console
# rsync -rav src/tools/tmux/examples examples/tools/tmux
# rsync -rav src/tools/vault/examples examples/tools/vault
# rsync -rav src/core/openrpc/examples examples/core/openrpc
# rsync -rav src/core/pathlib/examples examples/core/pathlib
# rsync -rav src/web/auth/examples examples/web/auth
# rsync -rav src/web/publisher2/examples examples/web/publisher2
# rsync -rav src/osal/docker/examples examples/osal/docker
# rsync -rav src/osal/sandbox/examples examples/osal/sandbox
# rsync -rav src/osal/examples examples/osal
# rsync -rav src/algo/crpgp/examples examples/algo/crpgp
# rsync -rav src/algo/encoder/examples examples/algo/encoder
# rsync -rav src/baobab/context/examples examples/baobab/context
# rsync -rav src/baobab/spawner/examples examples/baobab/spawner
# rsync -rav src/baobab/taskletmanager/examples examples/baobab/taskletmanager
# rsync -rav src/baobab/jobs/examples examples/baobab/jobs
# rsync -rav src/threefold/web3gw/examples examples/threefold/web3gw
# rsync -rav src/threefold/actions_3script/blockchain/examples examples/threefold/actions_3script/blockchain
# rsync -rav src/threefold/nodepilot/examples examples/threefold/nodepilot
# rsync -rav src/threefold/grid/examples examples/threefold/grid
# rsync -rav src/data/knowledgetree/testdata examples/knowledgetree/testdata
# rsync -rav src/data/resp/examples examples/data/resp
# rsync -rav src/data/vstor/examples examples/data/vstor
# rsync -rav src/data/params/examples examples/data/params
# rsync -rav src/builder/examples examples/builder
# rsync -rav src/servers/filedb/examples examples/servers/filedb
# rsync -rav src/installers/examples examples/installers


rm -rf src/ui/console/examples 
rm -rf src/tools/tmux/examples 
rm -rf src/tools/vault/examples 
rm -rf src/core/openrpc/examples 
rm -rf src/core/pathlib/examples 
rm -rf src/web/auth/examples 
rm -rf src/web/publisher2/examples 
rm -rf src/osal/docker/examples 
rm -rf src/osal/sandbox/examples 
rm -rf src/osal/examples 
rm -rf src/algo/crpgp/examples 
rm -rf src/algo/encoder/examples 
rm -rf src/baobab/context/examples 
rm -rf src/baobab/spawner/examples 
rm -rf src/baobab/taskletmanager/examples 
rm -rf src/baobab/jobs/examples 
rm -rf src/threefold/web3gw/examples 
rm -rf src/threefold/actions_3script/blockchain/examples 
rm -rf src/threefold/nodepilot/examples 
rm -rf src/threefold/grid/examples 
rm -rf src/data/knowledgetree/testdata 
rm -rf src/data/resp/examples 
rm -rf src/data/vstor/examples 
rm -rf src/data/params/examples 
rm -rf src/builder/examples 
rm -rf src/servers/filedb/examples 
rm -rf src/installers/examples 


echo "OK"