#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <sys/random.h>
#include <stddef.h>
#include <limits.h>
#include <stdio.h>
#include <secp256k1.h>
#include <secp256k1_ecdh.h>
#include "secp256k1mod.h"

static int fill_random(unsigned char* data, size_t size) {
#if defined(__linux__) || defined(__FreeBSD__)
    ssize_t res = getrandom(data, size, 0);
    if(res < 0 || (size_t) res != size) {
        return 0;
    } else {
        return 1;
    }

#elif defined(__APPLE__) || defined(__OpenBSD__)
    int res = getentropy(data, size);
    if(res == 0) {
        return 1;
    } else {
        return 0;
    }
#endif

    return 0;
}

static void dumphex(unsigned char *data, size_t size) {
    size_t i;

    printf("0x");

    for(i = 0; i < size; i++) {
        printf("%02x", data[i]);
    }

    printf("\n");
}

static void secp256k1_erase(unsigned char *target, size_t length) {
#if defined(__GNUC__)
    // memory barrier to avoid memset optimization
    memset(target, 0, length);
    __asm__ __volatile__("" : : "r"(target) : "memory");
#else
    // if we can't, fill with random, still better than
    // risking avoid memset
    fill_random(target, length);
#endif
}

static void secp256k1_erase_free(unsigned char *target, size_t length) {
    secp256k1_erase(target, length);
    free(target);
}

secp256k1_t *secp256k1_new() {
    secp256k1_t *secp = malloc(sizeof(secp256k1_t));
    unsigned char randomize[32];

    secp->kntxt = secp256k1_context_create(SECP256K1_CONTEXT_NONE);

    if(!fill_random(randomize, sizeof(randomize))) {
        printf("[-] failed to generate randomness\n");
        return NULL;
    }

    // side-channel protection
    int val = secp256k1_context_randomize(secp->kntxt, randomize);

    return secp;
}

void secp256k1_free(secp256k1_t *secp) {
    secp256k1_context_destroy(secp->kntxt);
    secp256k1_erase_free(secp->seckey, SECKEY_SIZE);
    secp256k1_erase_free(secp->compressed, COMPPUB_SIZE);
    free(secp);
}

int secp256k1_generate_key(secp256k1_t *secp) {
    secp->seckey = malloc(sizeof(char) * SECKEY_SIZE);
    secp->compressed = malloc(sizeof(char) * COMPPUB_SIZE);

    while(1) {
        if(!fill_random(secp->seckey, SECKEY_SIZE)) {
            printf("[-] failed to generate randomness\n");
            return 1;
        }

        if(secp256k1_ec_seckey_verify(secp->kntxt, secp->seckey) == 0) {
            // try again
            continue;
        }

        int r = secp256k1_ec_pubkey_create(secp->kntxt, &secp->pubkey, secp->seckey);
        assert(r);

        size_t len = COMPPUB_SIZE;
        int val = secp256k1_ec_pubkey_serialize(secp->kntxt, secp->compressed, &len, &secp->pubkey, SECP256K1_EC_COMPRESSED);

        return 0;
    }

    return 1;
}

unsigned char *secp265k1_shared_key(secp256k1_t *private, secp256k1_t *public) {
    unsigned char *shared = malloc(sizeof(unsigned char) * SHARED_SIZE);

    int val = secp256k1_ecdh(private->kntxt, shared, &public->pubkey, private->seckey, NULL, NULL);

    return shared;
}

unsigned char *secp256k1_sign_hash(secp256k1_t *secp, unsigned char *hash, size_t length) {
    secp256k1_sign_t signature;

    if(length != SHA256_SIZE) {
        printf("[-] warning: you should only sign sha-256 hash, size mismatch\n");
        printf("[-] warning: you get warned\n");
    }

    int return_val = secp256k1_ecdsa_sign(secp->kntxt, &signature.sig, hash, secp->seckey, NULL, NULL);
    assert(return_val);

    signature.serialized = malloc(sizeof(unsigned char) * SERSIG_SIZE);

    return_val = secp256k1_ecdsa_signature_serialize_compact(secp->kntxt, signature.serialized, &signature.sig);
    assert(return_val);

    return signature.serialized;
}

secp256k1_sign_t *secp256k1_load_signature(secp256k1_t *secp, unsigned char *serialized, size_t length) {
    secp256k1_sign_t *signature;

    if(length != SERSIG_SIZE) {
        printf("[-] serialized signature length mismatch, expected %u bytes\n", SERSIG_SIZE);
        return NULL;
    }

    signature = calloc(sizeof(secp256k1_sign_t), 1);

    signature->length = length;
    signature->serialized = malloc(length);
    memcpy(signature->serialized, serialized, length);

    if(!secp256k1_ecdsa_signature_parse_compact(secp->kntxt, &signature->sig, signature->serialized)) {
        printf("[-] failed to parse the signature\n");
        // FIXME: cleanup
        return NULL;
    }

    return signature;
}

void secp256k1_sign_free(secp256k1_sign_t *signature) {
    secp256k1_erase_free(signature->serialized, signature->length);
    free(signature);
}

int secp256k1_sign_verify(secp256k1_t *secp, secp256k1_sign_t *signature, unsigned char *hash, size_t length) {
    if(length != SHA256_SIZE) {
        printf("[-] warning: you should only check sha-256 hash, size mismatch\n");
    }

    return secp256k1_ecdsa_verify(secp->kntxt, &signature->sig, hash, &secp->pubkey);
}

int main() {
    secp256k1_t *bob = secp256k1_new();
    secp256k1_generate_key(bob);

    printf("Bob:\n");
    dumphex(bob->seckey, SECKEY_SIZE);
    dumphex(bob->compressed, COMPPUB_SIZE);

    secp256k1_t *alice = secp256k1_new();
    secp256k1_generate_key(alice);

    printf("\n");
    printf("Alice:\n");
    dumphex(alice->seckey, SECKEY_SIZE);
    dumphex(alice->compressed, COMPPUB_SIZE);

    unsigned char *shared1 = secp265k1_shared_key(bob, alice);
    unsigned char *shared2 = secp265k1_shared_key(alice, bob);

    printf("\n");
    printf("Shared Key:\n");
    dumphex(shared1, SHARED_SIZE);
    dumphex(shared2, SHARED_SIZE);

    secp256k1_erase_free(shared1, SHARED_SIZE);
    secp256k1_erase_free(shared2, SHARED_SIZE);

    // Hello, world!
    unsigned char hash[32] = {
        0x31, 0x5F, 0x5B, 0xDB, 0x76, 0xD0, 0x78, 0xC4,
        0x3B, 0x8A, 0xC0, 0x06, 0x4E, 0x4A, 0x01, 0x64,
        0x61, 0x2B, 0x1F, 0xCE, 0x77, 0xC8, 0x69, 0x34,
        0x5B, 0xFC, 0x94, 0xC7, 0x58, 0x94, 0xED, 0xD3,
    };

    unsigned char *sign = secp256k1_sign_hash(bob, hash, sizeof(hash));

    printf("\n");
    printf("Signature:\n");
    dumphex(sign, SERSIG_SIZE);

    secp256k1_sign_t *sigobj = secp256k1_load_signature(bob, sign, SERSIG_SIZE);
    int valid = secp256k1_sign_verify(bob, sigobj, hash, sizeof(hash));

    printf("\n");
    printf("Signature valid: %d\n", valid);

    secp256k1_erase_free(sign, SERSIG_SIZE);
    secp256k1_sign_free(sigobj);

    secp256k1_free(bob);
    secp256k1_free(alice);

    return 0;
}

