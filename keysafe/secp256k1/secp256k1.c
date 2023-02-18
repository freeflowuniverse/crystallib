#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <sys/random.h>

#include <stddef.h>
#include <limits.h>
#include <stdio.h>
#include <secp256k1.h>

static int fill_random(unsigned char* data, size_t size) {
#if defined(__linux__) || defined(__FreeBSD__)
    /* If `getrandom(2)` is not available you should fallback to /dev/urandom */
    ssize_t res = getrandom(data, size, 0);
    if (res < 0 || (size_t)res != size ) {
        return 0;
    } else {
        return 1;
    }
#elif defined(__APPLE__) || defined(__OpenBSD__)
    /* If `getentropy(2)` is not available you should fallback to either
     * `SecRandomCopyBytes` or /dev/urandom */
    int res = getentropy(data, size);
    if (res == 0) {
        return 1;
    } else {
        return 0;
    }
#endif
    return 0;
}

int init() {
    secp256k1_context* ctx = secp256k1_context_create(SECP256K1_CONTEXT_NONE);
    unsigned char randomize[32];

    if (!fill_random(randomize, sizeof(randomize))) {
        printf("Failed to generate randomness\n");
        return 1;
    }

    /* Randomizing the context is recommended to protect against side-channel
     * leakage See `secp256k1_context_randomize` in secp256k1.h for more
     * information about it. This should never fail. */
    int return_val = secp256k1_context_randomize(ctx, randomize);

    return 0;
}
