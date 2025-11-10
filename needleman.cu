#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr,
            "Usage: %s seq1.txt seq2.txt "
            "[--match 7 --mismatch -5 --gap-open -3 --gap-extend -1]\n",
            argv[0]);
        return 1;
    }

    const char *file1 = argv[1];
    const char *file2 = argv[2];

    // default scoring values
    int match_score = 1;
    int mismatch_score = -1;
    int gap_open = -2;
    int gap_extend = -1;

    // optional flags
    for (int i = 3; i < argc; i++) {
        if (strcmp(argv[i], "--match") == 0 && i + 1 < argc) {
            match_score = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--mismatch") == 0 && i + 1 < argc) {
            mismatch_score = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--gap-open") == 0 && i + 1 < argc) {
            gap_open = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--gap-extend") == 0 && i + 1 < argc) {
            gap_extend = atoi(argv[++i]);
        } else {
            fprintf(stderr, "Unknown or incomplete argument: %s\n", argv[i]);
            return 1;
        }
    }

    // printf("File 1: %s\n", file1);
    // printf("File 2: %s\n", file2);
    // printf("Match score: %d\n", match_score);
    // printf("Mismatch score: %d\n", mismatch_score);
    // printf("Gap open: %d\n", gap_open);
    // printf("Gap extend: %d\n", gap_extend);

    return 0;
}
