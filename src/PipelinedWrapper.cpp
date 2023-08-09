#ifndef TFG_PIPELINED_WRAPPER
#define TFG_PIPELINED_WRAPPER
#include "PipelinedWrapper.h"
#include <vector>
#include <string>
#include <ostream>
#include <sstream>


#include "../mips_sim/src/assembler/mips_assembler.h"
#include "../mips_sim/src/utils.h"

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>


using namespace godot;
using namespace mips_sim;


void PipelinedWrapper::_bind_methods() {
    //bind methods
    ClassDB::bind_method(D_METHOD("next_cycle"), &PipelinedWrapper::next_cycle);
    ClassDB::bind_method(D_METHOD("init"), &PipelinedWrapper::init);
    ClassDB::bind_method(D_METHOD("load_program"), &PipelinedWrapper::load_program);
    ClassDB::bind_method(D_METHOD("is_ready"), &PipelinedWrapper::is_ready);
    ClassDB::bind_method(D_METHOD("reset_cpu"), &PipelinedWrapper::reset_cpu);
    ClassDB::bind_method(D_METHOD("previous_cycle"), &PipelinedWrapper::previous_cycle);
    ClassDB::bind_method(D_METHOD("show_memory"), &PipelinedWrapper::show_memory);


    //bind properties
    ClassDB::bind_method(D_METHOD("set_cpu_info"), &PipelinedWrapper::set_cpu_info);
    ClassDB::bind_method(D_METHOD("get_cpu_info"), &PipelinedWrapper::get_cpu_info);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::DICTIONARY, "cpu_info"), "set_cpu_info", "get_cpu_info");

    ClassDB::bind_method(D_METHOD("set_instructions"), &PipelinedWrapper::set_instructions);
    ClassDB::bind_method(D_METHOD("get_instructions"), &PipelinedWrapper::get_instructions);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::ARRAY, "instructions"), "set_instructions", "get_instructions");

    ClassDB::bind_method(D_METHOD("set_loaded_instructions"), &PipelinedWrapper::set_loaded_instructions);
    ClassDB::bind_method(D_METHOD("get_loaded_instructions"), &PipelinedWrapper::get_loaded_instructions);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::ARRAY, "loaded_instructions"), "set_loaded_instructions", "get_loaded_instructions");

    ClassDB::bind_method(D_METHOD("set_diagram"), &PipelinedWrapper::set_diagram);
    ClassDB::bind_method(D_METHOD("get_diagram"), &PipelinedWrapper::get_diagram);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::ARRAY, "diagram"), "set_diagram", "get_diagram");
}


PipelinedWrapper::PipelinedWrapper(){
    mem = std::shared_ptr<mips_sim::Memory>(new mips_sim::Memory());
    cpu = std::unique_ptr<mips_sim::CpuFlex>(new CpuFlex(mem));
    cpu_info = new godot::Dictionary();
    _update_cpu_info();
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

godot::String PipelinedWrapper::reset_cpu(){
    if (cpu == nullptr)
    {
      return godot::String("[error] CPU not set");
      
    }

    cpu->reset(true, true);
    _update_cpu_info();
    return godot::String("CPU reset");
}

godot::String PipelinedWrapper::previous_cycle(){
    if (cpu->get_cycle() == 0)
    {
      return "Already at first cycle";
    }
    
    //intercept cout
    bool retval = true;
    std::stringbuf strbuf;
    std::ostream out(&strbuf);
    retval = cpu->run_to_cycle(cpu->get_cycle()-1, out);
    std::stringstream ss;
    ss << out.rdbuf();
    godot::String str = ss.str().c_str();
    godot::UtilityFunctions::print(str);

    _update_cpu_info();
    _update_loaded_instructions();
    _update_diagram();

    return godot::String(std::to_string(retval).c_str());
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
    _update_loaded_instructions();
    _update_diagram();

    return godot::String(std::to_string(retval).c_str());
}

godot::String PipelinedWrapper::show_memory(){
    //intercept cout
    bool retval = true;
    std::stringbuf strbuf;
    std::ostream out(&strbuf);
    out << "Text region:\n";
    mem->print_memory(0x00400000, 0x00100000, out);
    out << "Data region:\n";
    mem->print_memory(0x10010000, 0x00100000, out);
    std::stringstream ss;
    ss << out.rdbuf();
    godot::String str = ss.str().c_str();
    godot::UtilityFunctions::print(str);

    return "";
}


bool PipelinedWrapper::is_ready() {
    return cpu->is_ready();
}

bool PipelinedWrapper::load_program(godot::String filename) {
    if (mips_sim::assemble_file(filename.ascii().get_data(), mem) != 0) {
        return false;
    }
    mem->snapshot(0);
    mem->snapshot(1);

    instructions.clear();
    int cont = 0;
    for (uint32_t mem_addr=0x00400000, instr_index=1; mem_addr<0x00400000+0x00100000; mem_addr+=4, instr_index++)
    {   
        try {
            uint32_t word = mem->mem_read_32(mem_addr);
            cont++;
            godot::Array instruction_info;
            instruction_info.push_back(mem_addr);
            godot::String instruction_text = std::string("[" + Utils::hex32(mem_addr) + "] " + Utils::decode_instruction(word)).c_str();
            instruction_info.push_back(instruction_text);
            instructions.push_back(instruction_info);
        }
        catch (int e) {}
    }
    return true;
}

godot::Dictionary PipelinedWrapper::get_cpu_info() {
    return *cpu_info;
}

void PipelinedWrapper::set_cpu_info(godot::Dictionary p_cpu_info) {
    *cpu_info = p_cpu_info;
}

godot::Array PipelinedWrapper::get_instructions() {
    return instructions;
}

void PipelinedWrapper::set_instructions(godot::Array p_instructions) {
    instructions = p_instructions;
}

godot::Array PipelinedWrapper::get_loaded_instructions() {
    return loaded_instructions;
}

void PipelinedWrapper::set_loaded_instructions(godot::Array p_loaded_instructions) {
    loaded_instructions = p_loaded_instructions;
}

void PipelinedWrapper::_update_loaded_instructions() {
    loaded_instructions.clear();
    for (uint32_t inst: cpu->get_loaded_instructions()) {
        loaded_instructions.push_back(godot::String(std::to_string(inst).c_str()));
    }
}

godot::Array PipelinedWrapper::get_diagram() {
    return diagram;
}

void PipelinedWrapper::set_diagram(godot::Array p_diagram) {
    diagram = p_diagram;
}

void PipelinedWrapper::_update_diagram() {
    CpuPipelined & cpuPipe = dynamic_cast<CpuPipelined &>(*cpu);
    const uint32_t * const * l_diagram = cpuPipe.get_diagram();
    uint32_t current_cycle = cpu->get_cycle();
    uint32_t min_cycle = current_cycle;
    uint32_t instr_ids[20];
    size_t instr_count = 0;
    godot::Array result = {};

    for (int i = 1; i < loaded_instructions.size(); i++) {
        if (l_diagram[i][current_cycle] > 0) {
            instr_ids[instr_count] = i;
            instr_count++;
            uint32_t lmin_cycle = current_cycle;

            for (size_t j=current_cycle; l_diagram[i][j] > 0 && j > 0; j--) {
                lmin_cycle--;
            }
            if (lmin_cycle < min_cycle) {
                min_cycle = lmin_cycle;
            }
        }
    }

    for (size_t i=0; i<instr_count; i++) {
        godot::Array arr = {};
        for (size_t j=current_cycle; j>min_cycle; j--) {
            if (l_diagram[instr_ids[i]][j] > 0) {
                if (l_diagram[instr_ids[i]][j] == l_diagram[instr_ids[i]][j-1]) {
                    //stall
                    arr.push_front("stall");
                }
                else {
                    arr.push_front(stage_names[l_diagram[instr_ids[i]][j] - 1].c_str());
                }
            }
        }
        result.push_back(arr);
    }
    set_diagram(result);
}



#endif //TFG_PIPELINED_WRAPPER
