#ifndef TFG_GODOT_WRAPPER
#define TFG_GODOT_WRAPPER
#include "stage.h"
#include "IF.cpp"
#include "ID.cpp"
#include "EX.cpp"
#include "MEM_stage.cpp"
#include "WB.cpp"
#include "GodotWrapper.h"
#include <vector>
#include <string>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>

#include <godot_cpp/variant/utility_functions.hpp>

#include "mips_sim.h"
#include "mips_assembler.h"
using namespace godot;
using namespace mips_sim;

void GodotWrapper::_bind_methods() {
    //bind methods
    ClassDB::bind_method(D_METHOD("run_cycle"), &GodotWrapper::run_cycle);
    ClassDB::bind_method(D_METHOD("init"), &GodotWrapper::init);
    ClassDB::bind_method(D_METHOD("load_program"), &GodotWrapper::load_program);

    //bind properties
    ClassDB::bind_method(D_METHOD("get_cpu_stages"), &GodotWrapper::get_cpu_stages);
    ClassDB::bind_method(D_METHOD("set_cpu_stages", "p_cpu_stages"), &GodotWrapper::set_cpu_stages);
    ClassDB::add_property("GodotWrapper", PropertyInfo(Variant::ARRAY, "cpu_stages"), "set_cpu_stages", "get_cpu_stages");
}

GodotWrapper::GodotWrapper(){
    shared_ptr<mips_sim::Memory> mem = shared_ptr<mips_sim::Memory>(new mips_sim::Memory());
    cpu = unique_ptr<mips_sim::CPU_FLEX>(new mips_sim::CPU_FLEX(mem));
    vector<Stage*> p_stages;
    p_stages.push_back(new IF());
    p_stages.push_back(new ID());
    p_stages.push_back(new EX());
    p_stages.push_back(new MEM());
    p_stages.push_back(new WB());
    cpu->set_stages(p_stages);
    _set_cpu_stages();
}

GodotWrapper::~GodotWrapper() {}

godot::String GodotWrapper::init() {
    return "init done";
}

godot::String GodotWrapper::run_cycle() {
    return godot::String(cpu->run_cycle().c_str());
}

godot::Array GodotWrapper::get_cpu_stages(){
    return cpu_stages;
}

void GodotWrapper::set_cpu_stages(godot::Array p_cpu_stages) {
    cpu_stages = p_cpu_stages;
}

void GodotWrapper::_set_cpu_stages() {
    godot::Array stages = {};
    for (Stage* stage : cpu->get_stages()) {
        stages.push_back(stage->stageName.c_str());
    }
    GodotWrapper::set_cpu_stages(stages);
}

godot::String GodotWrapper::load_program(godot::String filename) {
    if (mips_sim::assemble_file(filename.ascii().get_data(), cpu->memory) != 0) {
        return "Error parsing file";
    }
    //cpu->memory->print_memory(0x00400000, 0x00100000);
    return "program loaded\n";
}

#endif //TFG_GODOT_WRAPPER
