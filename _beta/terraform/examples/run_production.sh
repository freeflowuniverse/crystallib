set -e

#build taiga export
rm -f tf

if [[ "$OSTYPE" == "darwin"* ]]; then
    # v -v -d static_boehm  -gc boehm -prod publishtools.v
    v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc  -gc boehm tf.v
    ulimit -n 10000
else
    v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc -gc boehm tf.v
    # v -g -keepc -gc boehm taiga_export_production.v
fi
   


# v tf.v

# lldb tf  --one-line r
./tf

