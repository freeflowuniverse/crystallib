#ifndef WORDLIST_H
#define WORDLIST_H

struct words {
    /* Number of words in the list */
    size_t len;
    /* Number of bits representable by this word list */
    size_t bits;
    /* Is the word list sorted by unicode code point order? */
    int sorted;
    /* The underlying string (tokenised, containing embedded NULs) */
    const char *str;
    /* The length of str, or 0 if str points to constant storage */
    size_t str_len;
    /* Pointers to the individual words */
    const char **indices;
};

#endif
