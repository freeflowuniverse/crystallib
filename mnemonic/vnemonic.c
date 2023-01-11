#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include "wordlist.h"
#include "english.c"

//
// wordlist
//

static void wordlist_free(struct words *w);

static int bstrcmp(const void *l, const void *r)
{
    return strcmp(l, (*(const char **)r));
}

/* https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogObvious */
static size_t get_bits(size_t n)
{
    size_t bits = 0;
    while (n >>= 1)
        ++bits;
    return bits;
}

/* Allocate a new words structure */
static struct words *wordlist_alloc(const char *words, size_t len)
{
    struct words *w = malloc(sizeof(struct words));
    if (w) {
        memset(w, 0x00, sizeof(*w));
        w->str = strdup(words);
        if (w->str) {
            w->str_len = strlen(w->str);
            w->len = len;
            w->bits = get_bits(len);
            w->indices = malloc(len * sizeof(const char *));
            if (w->indices)
                return w;
        }
        wordlist_free(w);
    }
    return NULL;
}

static size_t wordlist_count(const char *words)
{
    size_t len = 1u; /* Always 1 less separator than words, so start from 1 */
    while (*words)
        len += *words++ == ' '; /* FIXME: utf-8 sep */
    return len;
}

static struct words *wordlist_init(const char *words)
{
    size_t i, len = wordlist_count(words);
    struct words *w = wordlist_alloc(words, len);

    if (w) {
        /* Tokenise the strings into w->indices */
        const char *p = w->str;
        for (len = 0; len < w->len; ++len) {
            w->indices[len] = p;
            while (*p && *p != ' ') /* FIXME: utf-8 sep */
                ++p;
            *((char *)p) = '\0';
            ++p;
        }

        w->sorted = 1;
        for (i = 1; i < len && w->sorted; ++i)
            if (strcmp(w->indices[i - 1], w->indices[i]) > 0)
                w->sorted = 0;
    }
    return w;
}

static size_t wordlist_lookup_word(const struct words *w, const char *word)
{
    const size_t size = sizeof(const char *);
    const char **found = NULL;

    if (w->sorted)
        found = (const char **)bsearch(word, w->indices, w->len, size, bstrcmp);
    else {
        size_t i;
        for (i = 0; i < w->len && !found; ++i)
            if (!strcmp(word, w->indices[i]))
                found = w->indices + i;
    }
    return found ? found - w->indices + 1u : 0u;
}

static const char *wordlist_lookup_index(const struct words *w, size_t idx)
{
    if (idx >= w->len)
        return NULL;
    return w->indices[idx];
}

static void wordlist_free(struct words *w)
{
    if (w) {
        if (w->str) {
            if (w->str_len)
                memset((void *)w->str, 0x00, w->str_len);
            free((void *)w->str);
        }
        if (w->indices)
            free((void *)w->indices); /* No need to clear */

        memset(w, 0x00, sizeof(*w));
        free(w);
    }
}

//
// mnemonic
//

#define U8_AT(bytes, pos) (bytes)[(pos) / 8u]
#define U8_MASK(pos) (1u << (7u - (pos) % 8u))

/* Get n'th value (of w->bits length) from bytes */
static size_t extract_index(size_t bits, const unsigned char *bytes, size_t n)
{
    size_t pos, end, value;
    for (pos = n * bits, end = pos + bits, value = 0; pos < end; ++pos)
        value = (value << 1u) | !!(U8_AT(bytes, pos) & U8_MASK(pos));
    return value;
}

/* Store n'th value (of w->bits length) to bytes
 * Assumes: 1) the bits we are writing to are zero
 *          2) value fits within w->bits
 */
static void store_index(size_t bits, unsigned char *bytes_out, size_t n, size_t value)
{
    size_t i, pos;
    for (pos = n * bits, i = 0; i < bits; ++i, ++pos)
        if (value & (1u << (bits - i - 1u)))
            U8_AT(bytes_out, pos) |= U8_MASK(pos);
}

static char *mnemonic_from_bytes(const struct words *w, const unsigned char *bytes, size_t bytes_len)
{
    size_t total_bits = bytes_len * 8u; /* bits in 'bytes' */
    size_t total_mnemonics = total_bits / w->bits; /* Mnemonics in 'bytes' */
    size_t i, str_len = 0;
    char *str = NULL;

    /* Compute length of result */
    for (i = 0; i < total_mnemonics; ++i) {
        size_t idx = extract_index(w->bits, bytes, i);
        size_t mnemonic_len = strlen(w->indices[idx]);

        str_len += mnemonic_len + 1; /* +1 for following separator or NUL */
    }

    /* Allocate and fill result */
    if (str_len && (str = malloc(str_len))) {
        char *out = str;

        for (i = 0; i < total_mnemonics; ++i) {
            size_t idx = extract_index(w->bits, bytes, i);
            size_t mnemonic_len = strlen(w->indices[idx]);

            memcpy(out, w->indices[idx], mnemonic_len);
            out[mnemonic_len] = ' '; /* separator */
            out += mnemonic_len + 1;
        }
        str[str_len - 1] = '\0'; /* Overwrite the last separator with NUL */
    }

    return str;
}

char *mnemonic_from_bytes_en(const unsigned char *bytes, size_t bytes_len) {
    return mnemonic_from_bytes(&en_words, bytes, bytes_len);
}

int mnemonic_to_bytes(const struct words *w, const char *mnemonic,
                      unsigned char *bytes_out, size_t len, size_t *written)
{
    struct words *mnemonic_w = NULL;
    size_t i;

    if (written)
        *written = 0;

    if (!w || !bytes_out || !len)
        return -EINVAL;

    mnemonic_w = wordlist_init(mnemonic);

    if (!mnemonic_w)
        return -ENOMEM;

    if ((mnemonic_w->len * w->bits + 7u) / 8u > len)
        goto cleanup; /* Return the length we would have written */

    memset(bytes_out, 0x00, len);

    for (i = 0; i < mnemonic_w->len; ++i) {
        size_t idx = wordlist_lookup_word(w, mnemonic_w->indices[i]);
        if (!idx) {
            wordlist_free(mnemonic_w);
            memset(bytes_out, 0x00, len);
            return -EINVAL;
        }
        store_index(w->bits, bytes_out, i, idx - 1);
    }

cleanup:
    if (written)
        *written = (mnemonic_w->len * w->bits + 7u) / 8u;
    wordlist_free(mnemonic_w);
    return 0;
}

int mnemonic_to_bytes_en(const char *mnemonic, unsigned char *bytes_out, size_t len, size_t *written) {
    return mnemonic_to_bytes(&en_words, mnemonic, bytes_out, len, written);
}

//
// test
//

#ifdef BUILD_DEBUG
int main() {
#else
int vnemonic_test() {
#endif
    char *mnemo = "turtle soda patrol vacuum turn fault bracket border angry rookie okay anger";
    char buffer[128];
    size_t written = 0;

    memset(buffer, 0x00, sizeof(buffer));

    int val = mnemonic_to_bytes_en(mnemo, buffer, sizeof(buffer), &written);
    printf("%d %lu\n", val, written);

    printf("0x");

    for(int i = 0; i < written; i++)
        printf("%02X", buffer[i] & 0xff);

    printf("\n");

    char *xx = mnemonic_from_bytes_en(buffer, written);
    printf(">> %s\n", xx);

    return 0;
}
