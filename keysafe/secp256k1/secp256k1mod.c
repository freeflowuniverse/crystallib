#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <sys/random.h>
#include <stddef.h>
#include <limits.h>
#include <stdio.h>
#include <secp256k1.h>
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

secp256k1_t *secp256k1_new() {
    secp256k1_t *secp = malloc(sizeof(secp256k1_t));
    unsigned char randomize[32];

    secp->kntxt = secp256k1_context_create(SECP256K1_CONTEXT_NONE);

    if(!fill_random(randomize, sizeof(randomize))) {
        printf("Failed to generate randomness\n");
        return NULL;
    }

    /* Randomizing the context is recommended to protect against side-channel
     * leakage See `secp256k1_context_randomize` in secp256k1.h for more
     * information about it. This should never fail. */
    int val = secp256k1_context_randomize(secp->kntxt, randomize);

    return secp;
}

/*
int main() {
    secp256k1_new();
    return 0;
}
*/
