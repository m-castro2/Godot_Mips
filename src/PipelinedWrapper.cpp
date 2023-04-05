#ifndef TFG_PIPELINED_WRAPPER
#define TFG_PIPELINED_WRAPPER
#include "PipelinedWrapper.h"
#include <vector>
#include <string>
#include <ostream>
#include <sstream>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>

#include <godot_cpp/variant/utility_functions.hpp>

#include "mips_assembler.h"
using namespace godot;
using namespace mips_sim;

void PipelinedWrapper::_bind_methods() {
    //bind methods
    ClassDB::bind_method(D_METHOD("run_cycle"), &PipelinedWrapper::run_cycle);
    ClassDB::bind_method(D_METHOD("init"), &PipelinedWrapper::init);
    ClassDB::bind_method(D_METHOD("load_program"), &PipelinedWrapper::load_program);

    //bind properties
}

PipelinedWrapper::PipelinedWrapper(){
    mem = std::shared_ptr<mips_sim::Memory>(new mips_sim::Memory());
    cpu = std::unique_ptr<mips_sim::Cpu>(new CpuPipelined(mem));
}

PipelinedWrapper::~PipelinedWrapper() {}

godot::String PipelinedWrapper::init() {
    return "init done";
}

godot::String PipelinedWrapper::run_cycle() {
    bool retval;
    std::stringbuf strbuf;
    std::ostream out(&strbuf);
    retval = cpu->next_cycle(out);
    std::stringstream ss;
    ss << out.rdbuf();
    godot::String str = ss.str().c_str();
    godot::UtilityFunctions::print(str);
    return godot::String(std::to_string(retval).c_str());
}

godot::String PipelinedWrapper::load_program(godot::String filename) {
    if (mips_sim::assemble_file(filename.ascii().get_data(), mem) != 0) {
        return "Error parsing file";
    }
    //cpu->memory->print_memory(0x00400000, 0x00100000);
    return "program loaded\n";
}

#endif //TFG_PIPELINED_WRAPPER
