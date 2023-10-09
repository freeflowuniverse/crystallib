#include <stdio.h>
#include <string.h>
#include <jerasure.h>
#include <reed_sol.h>
#include <stdlib.h>
#include <math.h>
#include "jerasure-simple.h"


static void *erased_free(int *erased) {
    free(erased);
    return NULL;
}


buffer_t *buffer_new(size_t length) {
    buffer_t *buffer;

    if(!(buffer = malloc(sizeof(buffer_t))))
        return NULL;

    if(!(buffer->data = malloc(length))) {
        free(buffer);
        return NULL;
    }

    buffer->length = length;

    return buffer;
}

void *buffer_free(buffer_t *buffer) {
    if(buffer)
        free(buffer->data);

    free(buffer);

    return NULL;
}


erasure_t *erasure_new(int k, int m) {
    erasure_t *erasure;

    if(!(erasure = malloc(sizeof(erasure_t))))
        return NULL;

    erasure->k = k;
    erasure->m = m;
    erasure->w = 8; // hardcoded for now

    erasure->matrix = reed_sol_vandermonde_coding_matrix(k, m, erasure->w);

    return erasure;
}

void *erasure_free(erasure_t *erasure) {
    free(erasure->matrix);
    free(erasure);
    return NULL;
}


shards_t *shards_new(int data_length, int parity_length, size_t aligned, size_t blocksize) {
    shards_t *shards = NULL;

    if(!(shards = calloc(sizeof(shards_t), 1)))
        return NULL;

    shards->data_length = data_length;
    shards->parity_length = parity_length;
    shards->aligned = aligned;
    shards->blocksize = blocksize;

    return shards;
}

void *shards_free(shards_t *shards) {
    if(!shards)
        return NULL;

    if(shards->data) {
        for(int i = 0; i < shards->data_length; i++) {
            free(shards->data[i]);
        }
    }

    if(shards->parity) {
        for(int i = 0; i < shards->parity_length; i++) {
            free(shards->parity[i]);
        }
    }

    free(shards->data);
    free(shards->parity);
    free(shards);

    return NULL;
}


shards_t *erasure_encode(erasure_t *erasure, char *data, size_t length) {
    shards_t *shards = NULL;

    int wsize = erasure->w / 8;
    int multiple = erasure->k * wsize;

    // compute aligned size and blocksize
    size_t aligned = ceill((float) length / (float) multiple) * multiple;
    size_t blocksize = aligned / erasure->k;

    if(!(shards = shards_new(erasure->k, erasure->m, aligned, blocksize)))
        return NULL;

    // FIXME: only allocate one buffer to contains last data shard
    // if aligned memory is larger than data, this avoid jerasure
    // to do buffer overrun
    if(!(shards->data = (char **) calloc(erasure->k, sizeof(char *))))
        return shards_free(shards);

    for(int i = 0; i < erasure->k; i++) {
        if(!(shards->data[i] = (char *) malloc(shards->blocksize)))
            return shards_free(shards);

        memcpy(shards->data[i], data + (i * shards->blocksize), shards->blocksize);
    }

    // allocate parities
    if(!(shards->parity = calloc(erasure->m, sizeof(char *))))
        return shards_free(shards);

    for(int i = 0; i < erasure->m; i++) {
        if(!(shards->parity[i] = malloc(shards->blocksize)))
            return shards_free(shards);
    }

    // build parities (with shortcut name)
    erasure_t *e = erasure;
    shards_t *s = shards;

    jerasure_matrix_encode(e->k, e->m, e->w, e->matrix, s->data, s->parity, s->blocksize);

    return shards;
}


buffer_t *erasure_decode(erasure_t *erasure, shards_t *shards) {
    buffer_t *buffer = NULL;

    if(shards->data_length != erasure->k)
        return NULL;

    if(shards->parity_length != erasure->m)
        return NULL;

    int *erased;
    int eraseid = 0;

    if(!(erased = malloc(sizeof(int) * (erasure->m + 1))))
        return NULL;

    // check for missing shards
    for(int i = 0; i < erasure->k; i++) {
        if(shards->data[i] == NULL) {
            erased[eraseid++] = i;

            if(eraseid == erasure->m + 1)
                return erased_free(erased);

            if(!(shards->data[i] = malloc(shards->blocksize)))
                return erased_free(erased);
        }
    }

    for(int i = 0; i < erasure->m; i++) {
        if(shards->parity[i] == NULL) {
            erased[eraseid++] = i + erasure->k;

            if(eraseid == erasure->m + 1)
                return erased_free(erased);

            if(!(shards->parity[i] = malloc(shards->blocksize)))
                return erased_free(erased);
        }
    }

    erased[eraseid] = -1;

    for(int i = 0; i < erasure->m; i++)
        printf("Missing: %d\n", erased[i]);

    erasure_t *e = erasure;
    shards_t *s = shards;

    int ret = jerasure_matrix_decode(e->k, e->m, e->w, e->matrix, 1, erased, s->data, s->parity, s->blocksize);
    if(ret != 0) {
        fprintf(stderr, "could not decode matrix");
        exit(1);
    }

    if(!(buffer = buffer_new(erasure->k * shards->blocksize)))
        return erased_free(erased);

    char *writer = buffer->data;

    for(int i = 0; i < erasure->k; i++) {
        memcpy(writer, shards->data[i], shards->blocksize);
        writer += shards->blocksize;
    }

    erased_free(erased);

    return buffer;
}

