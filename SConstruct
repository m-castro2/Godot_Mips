#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/"])
env.Append(CPPPATH=["mips_sim/src/"])
env.Append(CPPPATH=["mips_sim/src/assembler/"])
env.Append(CPPPATH=["mips_sim/src/cpu/"])
env.Append(CPPPATH=["mips_sim/src/cpu/component/"])
env.Append(CPPPATH=["mips_sim/src/interface/"])
env.Append(CPPPATH=["mips_sim/src/interface/cli/"])
env.Append(CPPPATH=["mips_sim/src/interface/cli/detail/"])
env.Append(CPPPATH=["mips_sim/src/interface/qt/"])

env.Append(CFLAGS=["-g -O0"])


sources = Glob("src/*.cpp")
sources = sources + Glob("mips_sim/src/*.cpp")
sources = sources + Glob("mips_sim/src/assembler/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/component/*.cpp")
sources = sources + Glob("mips_sim/src/interface/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/interface/cli/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/interface/cli/detail/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/interface/qt/*.cpp")

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "GUI/bin/libgdexample.{}.{}.framework/libgdexample.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "GUI/bin/libgdexample{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
