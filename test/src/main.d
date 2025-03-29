/*
Copyright (c) 2025 Timur Gafarov.

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module main;

import std.stdio;
import std.conv;
import std.file;
import std.string;

import bindbc.spirvcross;
import loader = bindbc.loader.sharedlib;

void main()
{
    SPVCSupport spvcVersion = loadSPVC();
    writeln("Loaded library version: ", spvcVersion);
    
    if (loader.errors.length)
    {
        writeln("Loader errors:");
        foreach(info; loader.errors)
        {
            writeln(to!string(info.error), ": ", to!string(info.message));
        }
        
        return;
    }
    
    uint major, minor, patch;
    spvc_get_version(&major, &minor, &patch);
    writefln("SPIRV-Cross %s.%s.%s", major, minor, patch);
    
    spvc_context spvcContext;
    if (spvc_context_create(&spvcContext) != SPVC_SUCCESS)
    {
        writeln("Failed to create context");
        return;
    }
    
    uint[] spirvModule = cast(uint[])read("test.vert.spv");
    
    spvc_parsed_ir spvcIR;
    if (spvc_context_parse_spirv(spvcContext, spirvModule.ptr, spirvModule.length, &spvcIR) != SPVC_SUCCESS)
    {
        writeln("Failed to parse SPIR-V module");
        return;
    }
    
    spvc_compiler spvcCompiler;
    if (spvc_context_create_compiler(spvcContext, SPVC_BACKEND_GLSL, spvcIR, SPVC_CAPTURE_MODE_COPY, &spvcCompiler) != SPVC_SUCCESS)
    {
        writeln("Failed to create compiler");
        return;
    }
    
    spvc_compiler_options spvcCompilerOptions;
    if (spvc_compiler_create_compiler_options(spvcCompiler, &spvcCompilerOptions) != SPVC_SUCCESS)
    {
        writeln("Failed to create compiler options");
        return;
    }
    
    spvc_compiler_options_set_uint(spvcCompilerOptions, SPVC_COMPILER_OPTION_GLSL_VERSION, 400);
    spvc_compiler_options_set_bool(spvcCompilerOptions, SPVC_COMPILER_OPTION_GLSL_EMIT_UNIFORM_BUFFER_AS_PLAIN_UNIFORMS, true);
    spvc_compiler_options_set_bool(spvcCompilerOptions, SPVC_COMPILER_OPTION_GLSL_VULKAN_SEMANTICS, false);
    spvc_compiler_install_compiler_options(spvcCompiler, spvcCompilerOptions);
    
    const(char)* output;
    if (spvc_compiler_compile(spvcCompiler, &output) != SPVC_SUCCESS)
    {
        writeln("Failed to compile");
        return;
    }
    
    string glslCode = output.to!string;
    
    writeln("SPIR-V to GLSL compilation result:\n");
    writeln(glslCode);
    
    spvc_context_destroy(spvcContext);
}
