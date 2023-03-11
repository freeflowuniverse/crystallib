#ifndef SECP256K1_V_MOD
    #define SECP256K1_V_MOD

    #include <secp256k1.h>

    typedef struct secp256k1_t {
        secp256k1_context *kntxt;
        unsigned char *seckey;
        unsigned char *compressed;
        secp256k1_pubkey pubkey;

    } secp256k1_t;

    typedef struct secp256k1_sign_t {
        secp256k1_ecdsa_signature sig;
        unsigned char *serialized;
        size_t length;

    } secp256k1_sign_t;

    #define SECKEY_SIZE    32   // secret key size
    #define SHARED_SIZE    32   // ecdh shared key size
    #define COMPPUB_SIZE   33   // compressed public key size
    #define SERSIG_SIZE    64   // serialized signature size

    #define SHA256_SIZE    32   // sha-256 digest length

    secp256k1_t *secp256k1_new();
    void secp256k1_free(secp256k1_t *secp);

    int secp256k1_generate_key(secp256k1_t *secp);
    unsigned char *secp265k1_shared_key(secp256k1_t *private, secp256k1_t *public);
    unsigned char *secp256k1_sign_hash(secp256k1_t *secp, unsigned char *hash, size_t length);
#endif

