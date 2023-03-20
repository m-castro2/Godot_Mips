#include "stage.h"
#include "IF.cpp"
#include "ID.cpp"
#include "EX.cpp"
#include "MEM.cpp"
#include "WB.cpp"
#include "GodotWrapper.h"
#include <vector>
#include <string>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>
using namespace godot;

void GodotWrapper::_bind_methods() {
    ClassDB::bind_method(D_METHOD("run_cycle"), &GodotWrapper::run_cycle);
    ClassDB::bind_method(D_METHOD("init"), &GodotWrapper::init);
}

GodotWrapper::GodotWrapper(){
    cpu = unique_ptr<CPU_FLEX>(new CPU_FLEX());
}

GodotWrapper::~GodotWrapper() {}

godot::String GodotWrapper::init() {
    vector<Stage*> p_stages;
    IF IF;
    ID ID;
    EX EX;
    MEM MEM;
    WB WB;
    p_stages.push_back(&IF);
    p_stages.push_back(&ID);
    p_stages.push_back(&EX);
    p_stages.push_back(&MEM);
    p_stages.push_back(&WB);
    cpu->set_stages(p_stages);
    return "init done";
}

godot::String GodotWrapper::run_cycle() {
    return godot::String(cpu->run_cycle().c_str());
}
