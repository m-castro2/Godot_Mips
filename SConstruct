#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

env.Append(CPPPATH=["src/"])
env.Append(CPPPATH=["mips_sim/src/"])
env.Append(CPPPATH=["mips_sim/src/assembler/"])
env.Append(CPPPATH=["mips_sim/src/cpu/"])
env.Append(CPPPATH=["mips_sim/src/cpu/component/"])
env.Append(CPPPATH=["mips_sim/src/cpu_flex/"])
env.Append(CPPPATH=["mips_sim/src/cpu_flex/stages"])

env.Append(CFLAGS=["-g -O0"])


sources = Glob("src/*.cpp")
sources = sources + Glob("mips_sim/src/*.cpp")
sources = sources + Glob("mips_sim/src/assembler/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/*.cpp")
sources = sources + Glob("mips_sim/src/cpu/component/*.cpp")
sources = sources + Glob("mips_sim/src/cpu_flex/*.cpp")
sources = sources + Glob("mips_sim/src/cpu_flex/stages/*.cpp")

excluded_files = ['mips_sim/src/mips_sim.cpp']
sources = [x for x in sources if str(x) not in excluded_files]

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
