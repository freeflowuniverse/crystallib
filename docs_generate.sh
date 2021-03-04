v doc -all -m . -f html

export home=$HOME

if [[ "$OSTYPE" == "darwin"* ]]; then
    open file://$home/.vmodules/despiegk/crystallib/_docs/despiegk.crystallib.gittools.html
fi


