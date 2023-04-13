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
#include "utils.h"

using namespace godot;
using namespace mips_sim;


void PipelinedWrapper::_bind_methods() {
    //bind methods
    ClassDB::bind_method(D_METHOD("next_cycle"), &PipelinedWrapper::next_cycle);
    ClassDB::bind_method(D_METHOD("init"), &PipelinedWrapper::init);
    ClassDB::bind_method(D_METHOD("load_program"), &PipelinedWrapper::load_program);
    ClassDB::bind_method(D_METHOD("is_ready"), &PipelinedWrapper::is_ready);

    //bind properties
    ClassDB::bind_method(D_METHOD("set_cpu_info"), &PipelinedWrapper::set_cpu_info);
    ClassDB::bind_method(D_METHOD("get_cpu_info"), &PipelinedWrapper::get_cpu_info);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::DICTIONARY, "cpu_info"), "set_cpu_info", "get_cpu_info");
}


PipelinedWrapper::PipelinedWrapper(){
    mem = std::shared_ptr<mips_sim::Memory>(new mips_sim::Memory());
    cpu = std::unique_ptr<mips_sim::Cpu>(new CpuPipelined(mem));
    cpu_info = new godot::Dictionary();
}


PipelinedWrapper::~PipelinedWrapper() {}


godot::String PipelinedWrapper::init() {
    return "init done";
}

void PipelinedWrapper::_update_cpu_info(){
    //CPU info
    uint32_t pc_value = cpu->read_special_register(SPECIAL_PC);
    (*cpu_info)["PCValue"] = godot::String(Utils::hex32(pc_value).c_str());
    (*cpu_info)["HIValue"] = godot::String(Utils::hex32(cpu->read_special_register(SPECIAL_HI)).c_str());
    (*cpu_info)["LOValue"] = godot::String(Utils::hex32(cpu->read_special_register(SPECIAL_LO)).c_str());
    (*cpu_info)["Cycles"] = godot::String(std::to_string(cpu->get_cycle()).c_str());

    //CPU info: registers
    godot::Dictionary registers;
    godot::Array iRegisters;
    godot::Array fRegisters;
    godot::Array dRegisters;
    
    for (int i=0; i<32; ++i)
    {   
        iRegisters.append(godot::String(Utils::hex32(cpu->read_register(i)).c_str()));
        
        float f = cpu->read_register_f(i);
        fRegisters.append(godot::String(godot::rtos(f)));

        if (i%2 == 0)
        {
            double d = cpu->read_register_d(i);
            dRegisters.append(godot::String(godot::rtos(f)));
        }
    }
    registers["iRegisters"] = iRegisters.duplicate();
    registers["fRegisters"] = fRegisters.duplicate();
    registers["dRegisters"] = dRegisters.duplicate();

    (*cpu_info)["Registers"] = registers.duplicate();
}

godot::String PipelinedWrapper::next_cycle() {
    if (!cpu->is_ready()) {
        return "Program done";
    }

    //intercept cout
    bool retval;
    std::stringbuf strbuf;
    std::ostream out(&strbuf);
    retval = cpu->next_cycle(out);
    std::stringstream ss;
    ss << out.rdbuf();
    godot::String str = ss.str().c_str();
    godot::UtilityFunctions::print(str);

    _update_cpu_info();

    return godot::String(std::to_string(retval).c_str());
}


bool PipelinedWrapper::is_ready() {
    return cpu->is_ready();
}

bool PipelinedWrapper::load_program(godot::String filename) {
    if (mips_sim::assemble_file(filename.ascii().get_data(), mem) != 0) {
        return false;
    }

    return true;
}


void PipelinedWrapper::set_cpu_info(godot::Dictionary p_cpu_info) {
    *cpu_info = p_cpu_info;
}

godot::Dictionary PipelinedWrapper::get_cpu_info() {
    return *cpu_info;
}

#endif //TFG_PIPELINED_WRAPPER
