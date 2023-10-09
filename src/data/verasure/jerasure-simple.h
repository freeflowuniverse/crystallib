#ifndef JERASURE_SIMPLE_H
#define JERASURE_SIMPLE_H

    typedef struct erasure_t {
        int k;
        int m;
        int w;

        int *matrix;

    } erasure_t;

    typedef struct shards_t {
        int data_length;
        int parity_length;

        char **data;
        char **parity;

        size_t aligned;
        size_t blocksize;

        int allocated; // 0 - no data buffer allocated
                       // 1 - only last data buffer allocated
                       // 2 - all data buffer allocated
                       // this is used to keep track of buffer to free

    } shards_t;

    typedef struct buffer_t {
        char *data;
        size_t length;

    } buffer_t;


    buffer_t *buffer_new(size_t length);
    void *buffer_free(buffer_t *buffer);

    erasure_t *erasure_new(int k, int m);
    void *erasure_free(erasure_t *erasure);

    shards_t *shards_new(int data_length, int parity_length, size_t aligned, size_t blocksize);
    void *shards_free(shards_t *shards);

    shards_t *erasure_encode(erasure_t *erasure, char *data, size_t length);
    buffer_t *erasure_decode(erasure_t *erasure, shards_t *shards);

#endif
