set -ex
v -cg ~/code/github/freeflowuniverse/crystallib/bizmodel/example/bizmodel.v
cp ~/code/github/freeflowuniverse/crystallib/bizmodel/example/bizmodel ~/Downloads/
# cp ~/code/github/freeflowuniverse/crystallib/bizmodel/example/bizmodel /usr/local/bin/
rm -f bizmodel

echo 'to use do ~/Downloads/bizmodel pathofexecution'