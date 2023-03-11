#ifndef SECP256K1_V_MOD
    #define SECP256K1_V_MOD

    #include <secp256k1.h>

    typedef struct secp256k1_t {
        secp256k1_context *kntxt;
        unsigned char *seckey;
        unsigned char *compressed;
        secp256k1_pubkey pubkey;
        secp256k1_ecdsa_signature sig;


    } secp256k1_t;

    #define SECKEY_SIZE    32
    #define SHARED_SIZE    32
    #define COMPPUB_SIZE   33

    secp256k1_t *secp256k1_new();
    int secp256k1_generate_key(secp256k1_t *secp);

#endif

