#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void read_sequences(const char *filename, char **x, char **y) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        perror("File open failed");
        exit(1);
    }

    size_t len = 0;
    ssize_t read;

    char *line1 = NULL;
    char *line2 = NULL;

    // read first line
    if ((read = getline(&line1, &len, fp)) == -1) || ((read = getline(&line2, &len, fp)) == -1) {
        fprintf(stderr, "File must contain at least 2 lines\n");
        exit(1);
    }

    // strip newline
    line1[strcspn(line1, "\n")] = 0;
    line2[strcspn(line2, "\n")] = 0;

    *x = line1;
    *y = line2;

    fclose(fp);
    return
}


void print_matrix(const int *M, const char *x, const char *y, int rows, int cols) {

    #define IDX(i,j) ((i) * (cols) + (j))

    printf("      -   ");
    for (int j = 0; j < (int)strlen(x); j++) {
        printf("  %c ", x[j]);
    }
    printf("\n");

    // row 0
    printf("  - ");
    for (int j = 0; j < cols; j++) {
        printf("%3d ", M[IDX(0,j)]);
    }
    printf("\n");

    for (int i = 1; i < rows; i++) {
        printf("  %c ", y[i-1]);
        for (int j = 0; j < cols; j++) {
            printf("%3d ", M[IDX(i,j)]);
        }
        printf("\n");
    }
}


int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr,
            "Usage: %s seq.txt "
            "[--match 7 --mismatch -5 --gap-open -3 --gap-extend -1]\n",
            argv[0]);
        return 1;
    }

    const char *file = argv[1];

    // default scoring values
    int match_score = 1;
    int mismatch_score = -1;
    int gap_open = -2;
    int gap_extend = -1;

    // optional flags start at argv[2]
    for (int i = 2; i < argc; i++) {
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

    printf("File: %s\n", file);
    printf("Match score: %d\n", match_score);
    printf("Mismatch score: %d\n", mismatch_score);
    printf("Gap open: %d\n", gap_open);
    printf("Gap extend: %d\n\n", gap_extend);

    char *x = NULL;
    char *y = NULL;
    read_sequences(file1, &x, &y);

    printf("X (columns): %s\n", x);
    printf("Y (rows)   : %s\n\n", y);

    int rows, cols;
    int *M = init_matrix(x, y, gap_open, gap_extend, &rows, &cols);

    // host pointers: x, y, M
    char *d_x, *d_y;
    int  *d_M;
    size_t len_x = strlen(x);
    size_t len_y = strlen(y);
    size_t matrix_bytes = rows * cols * sizeof(int);

    cudaMalloc(&d_x, len_x * sizeof(char));
    cudaMalloc(&d_y, len_y * sizeof(char));
    cudaMalloc(&d_M, matrix_bytes);

    // copy inputs to device
    cudaMemcpy(d_x, x, len_x * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, len_y * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, M, matrix_bytes,        cudaMemcpyHostToDevice);

    needleman_wunsch_kernel<<<grid, block>>>(d_M, d_x, d_y, rows, cols, match, mismatch, gap_open, gap_extend);

    // copy result matrix back
    cudaMemcpy(M, d_M, matrix_bytes, cudaMemcpyDeviceToHost);

    // updated matrix
    print_matrix(M, x, y, rows, cols);

    // clean up
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_M);
    free(M);
    free(x);
    free(y);

    return 0;
}