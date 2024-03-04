# GPU Installation

This process will needs about `50 GB of disk space`. About 35 GB for VS2022 and 15GB for CUDA.

## 1. Windows

### 1.1 NVIDIA CUDA Toolkit

Windows GPU support is done through [`CUDA Toolkit`](https://developer.nvidia.com/cuda-downloads).

Tested on:
- Windows 10 with CUDA 11.5 - RTX 3070
- Windows 11 with CUDA 12.2.2 - RTX 4080 Max-Q (Laptop version)

Some tips to get it working with an `NVIDIA card and CUDA`:

For Installer Type, choose exe (`network`).

During install, choose `Custom` (`Advanced`).

The only required components are:

- Cuda
    - Runtime
    - Development
    - Integration with Visual Studio

- Driver components
    - Display driver

You may choose to install additional components if you like.

Restart your Computer.

Verify your installation is correct by running:

```bash
nvcc --version
```

```bash
nvidia-smi
```

Ensure your CUDA version is up to date and your GPU is detected.

### 1.2 Visual Studio 2022

May be you already installed this when you were making Embedding installation, but if don't:

Install the [latest VS2022](https://visualstudio.microsoft.com/vs/community/) (and build tools).

Make sure the following components are selected:
- 1. Universal Windows Platform development
- 2. C++ CMake tools for Windows

### 1.3 Configuration

If you have all required dependencies properly configured running the following `Powershell` (admin mode) command should succeed. Execute it on the root path of this project

```Powershell
$env:CMAKE_ARGS='-DLLAMA_CUBLAS=on'; poetry run pip install --force-reinstall --no-cache-dir llama-cpp-python
```

If your installation was correct, you should see a message similar to the following next time you start the server `BLAS = 1`

```sh
llama_new_context_with_model: total VRAM used: 4857.93 MB (model: 4095.05 MB, context: 762.87 MB)
AVX = 1 | AVX2 = 1 | AVX512 = 0 | AVX512_VBMI = 0 | AVX512_VNNI = 0 | FMA = 1 | NEON = 0 | ARM_FMA = 0 | F16C = 1 | FP16_VA = 0 | WASM_SIMD = 0 | BLAS = 1 | SSE3 = 1 | SSSE3 = 0 | VSX = 0 |
```

Note: if you are running with CPU or installation with GPU failed, you will see: `BLAS = 0`.