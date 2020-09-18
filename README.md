# The LLVM Compiler Infrastructure

This directory and its subdirectories contain source code for LLVM,
a toolkit for the construction of highly optimized compilers,
optimizers, and runtime environments.

## Build for RVP
```
mkdir build
cd build

cmake \
    -G"Ninja" \
    -DCMAKE_BUILD_TYPE="Debug" \
    -DBUILD_SHARED_LIBS=True \
    -DLLVM_USE_SPLIT_DWARF=True \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_OPTIMIZED_TABLEGEN=True \
    -DLLVM_BUILD_TESTS=True \
    -DLLVM_ENABLE_PROJECTS="clang" \
    -DLLVM_USE_LINKER=gold \
    -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="RISCV" ../llvm

cmake --build .
```
- make sure your're on the branch `rvp`