#ifndef SECP256K1_V_MOD
    #define SECP256K1_V_MOD

    #include <secp256k1.h>

    typedef struct secp256k1_t {
        secp256k1_context *kntxt;         // library context
        unsigned char *seckey;            // ec private key

        unsigned char *compressed;        // ec public key serialized
        secp256k1_pubkey pubkey;          // ec public key

        unsigned char *xcompressed;       // x-only serialized key
        secp256k1_xonly_pubkey xpubkey;   // x-only public key
        secp256k1_keypair keypair;        // keypair opaque representation
                                          // needed for schnorr

    } secp256k1_t;

    typedef struct secp256k1_sign_t {
        secp256k1_ecdsa_signature sig;
        unsigned char *serialized;
        size_t length;

    } secp256k1_sign_t;

    #define SECKEY_SIZE    32   // secret key size
    #define SHARED_SIZE    32   // ecdh shared key size
    #define COMPPUB_SIZE   33   // compressed public key size
    #define XSERPUB_SIZE   32   // x-only public key serialized size
    #define SERSIG_SIZE    64   // serialized signature size
    #define SCHSIG_SIZE    64   // internal schnorr signature size

    #define SHA256_SIZE    32   // sha-256 digest length

    secp256k1_t *secp256k1_new();
    void secp256k1_free(secp256k1_t *secp);

    int secp256k1_generate_key(secp256k1_t *secp);
    unsigned char *secp265k1_shared_key(secp256k1_t *private, secp256k1_t *public);
    unsigned char *secp256k1_sign_hash(secp256k1_t *secp, unsigned char *hash, size_t length);

    secp256k1_sign_t *secp256k1_load_signature(secp256k1_t *secp, unsigned char *serialized, size_t length);
    int secp256k1_sign_verify(secp256k1_t *secp, secp256k1_sign_t *signature, unsigned char *hash, size_t length);
    unsigned char *secp256k1_schnorr_sign_hash(secp256k1_t *secp, unsigned char *hash, size_t length);
    int secp256k1_schnorr_verify(secp256k1_t *secp, unsigned char *signature, size_t siglen, unsigned char *hash, size_t hashlen);
    void secp256k1_sign_free(secp256k1_sign_t *signature);

#endif

