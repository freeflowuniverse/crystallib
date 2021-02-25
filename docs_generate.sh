v doc -all -m . -o docs/ -f html

export home=$HOME

if [[ "$OSTYPE" == "darwin"* ]]; then
    open file://$home/.vmodules/despiegk/crystallib/_docs/despiegk.crystallib.gittools.html
fi


