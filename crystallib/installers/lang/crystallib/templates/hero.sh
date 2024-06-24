export PATH=${home_dir}/hero/bin:??PATH
export TERM=xterm

cd ${home_dir}/code/github/freeflowuniverse/crystallib/cli/hero

PRF="${home_dir}/.profile"
[ -f "??PRF" ] && source "??PRF"

if [[ "??OSTYPE" == "linux-gnu"* ]]; then
    #v -enable-globals -w -cflags -static -cc gcc hero.v
    v -enable-globals -w -n hero.v
    export HEROPATH='/usr/local/bin/hero'
elif [[ "??OSTYPE" == "darwin"* ]]; then
    v -enable-globals -w -n hero.v
    export HEROPATH=${home_dir}/hero/bin/hero
fi

chmod +x hero

cp hero ??HEROPATH
rm hero    