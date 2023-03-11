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

    secp256k1_free(bob);
    secp256k1_free(alice);

    return 0;
}

