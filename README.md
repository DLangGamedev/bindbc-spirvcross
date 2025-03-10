# BindBC-GLSLang
BindBC binding to [GLSL reference compiler from Khronos Group](https://github.com/KhronosGroup/glslang). This package allows to embed a GLSL-to-SPIR-V compilation toolchain into your application, thereby avoiding the tedious separate shader building step.

## Usage
```
dub add bindbc-glslang
```

BindBC-GLSLang relies on a shared library: `glslang.dll` on Windows and `libglslang.so` on Linux. To compile GLSLang with shared libraries, use `BUILD_SHARED_LIBS` CMake option, for example:

```
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
```
