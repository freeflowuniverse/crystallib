#ifndef SECP256K1_V_MOD
    #define SECP256K1_V_MOD

    #include <secp256k1.h>

    typedef struct secp256k1_t {
        secp256k1_context *kntxt;

    } secp256k1_t;


    secp256k1_t *secp256k1_new();

#endif

