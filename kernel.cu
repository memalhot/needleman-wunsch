__global__ void needleman_wunsch_kernel(int* d_M, char * d_x,  char * d_y, int rows, int cols, int match, int mismatch, int gap_open, int gap_extend) {
    
    // int col = blockIdx.x * blockDim.x + threadIdx.x
    // int row = blockIdx.y * blockDim.y + threadIdx.y
}