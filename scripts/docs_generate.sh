v doc -all -m . -f html -inline-assets

export home=$HOME

if [[ "$OSTYPE" == "darwin"* ]]; then
    open file://$home/.vmodules/freeflowuniverse/crystallib/_docs/crystallib.gittools.html
fi


