# Compiler
NVCC       := nvcc

# Target binary name
TARGET     := needleman

SRC        := needleman.cu

# Compiler flags
NVCCFLAGS  := -O2 -arch=native -std=c++17

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(NVCCFLAGS) -o $@ $^

run: $(TARGET)
	./$(TARGET) ./sequences/seq1.txt ./sequences/seq2.txt --match 1 --mismatch -1 --gap-open -2 --gap-extend -1

# Debug build
debug: NVCCFLAGS += -G -O0 -lineinfo -DDEBUG
debug: clean all

clean:
	rm -f $(TARGET)

.PHONY: all run clean debug
