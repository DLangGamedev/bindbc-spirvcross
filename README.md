# BindBC-SPIRVCross
BindBC binding to [SPIRV-Cross, a SPIR-V cross-compilation toolchain from Khronos Group](https://github.com/KhronosGroup/SPIRV-Cross).

## Usage
```
dub add bindbc-spirvcross
```

BindBC-SPIRVCross relies on a shared library: `spirv-cross.dll` on Windows and `libspirv-cross.so` on Linux. To compile SPIRV-Cross with shared libraries, use `BUILD_SHARED_LIBS` CMake option, for example:

```
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
```
