#ifndef MNEMONIC_H
    #define MNEMONIC_H

    char *mnemonic_from_bytes_en(const unsigned char *bytes, size_t bytes_len);
    int mnemonic_to_bytes_en(const char *mnemonic, unsigned char *bytes_out, size_t len, size_t *written);
#endif
