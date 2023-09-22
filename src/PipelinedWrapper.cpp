#ifndef TFG_PIPELINED_WRAPPER
#define TFG_PIPELINED_WRAPPER
#include "PipelinedWrapper.h"
#include <vector>
#include <string>
#include <ostream>
#include <sstream>
#include <string_view>


#include "../mips_sim/src/assembler/mips_assembler.h"
#include "../mips_sim/src/utils.h"
#include "../mips_sim/src/exception.h"

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
    ClassDB::bind_method(D_METHOD("enable_forwarding_unit"), &PipelinedWrapper::enable_forwarding_unit);
    ClassDB::bind_method(D_METHOD("enable_hazard_detection_unit"), &PipelinedWrapper::enable_hazard_detection_unit);
    ClassDB::bind_method(D_METHOD("change_branch_stage"), &PipelinedWrapper::change_branch_stage);
    ClassDB::bind_method(D_METHOD("change_branch_type"), &PipelinedWrapper::change_branch_type);


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
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::DICTIONARY, "diagram"), "set_diagram", "get_diagram");

    ClassDB::bind_method(D_METHOD("set_stage_signals_map"), &PipelinedWrapper::set_stage_signals_map);
    ClassDB::bind_method(D_METHOD("get_stage_signals_map"), &PipelinedWrapper::get_stage_signals_map);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::ARRAY, "stage_signals_map"), "set_stage_signals_map", "get_stage_signals_map");

    ClassDB::bind_method(D_METHOD("set_exception_info"), &PipelinedWrapper::set_exception_info);
    ClassDB::bind_method(D_METHOD("get_exception_info"), &PipelinedWrapper::get_exception_info);
    ClassDB::add_property("PipelinedWrapper", PropertyInfo(Variant::DICTIONARY, "exception_info"), "set_exception_info", "get_exception_info");
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

    //stage signals map
    stage_signals_map.clear();
    std::map<int, std::map<std::string_view, int>> map = cpu->get_hw_stage_instruction_signals(5);
    for (int i = 0; i<5; ++i) {
        godot::Dictionary dict {};
        for(std::map<std::string_view, int>::iterator it = map[i].begin(); it != map[i].end(); ++it) {
            dict[godot::String(std::string(it->first).c_str())] = it->second;
        }
        stage_signals_map.push_back(dict);
    }
}

godot::String PipelinedWrapper::reset_cpu(bool data_memory, bool text_memory){
    if (cpu == nullptr)
    {
      return godot::String("[error] CPU not set");
      
    }

    cpu->reset(data_memory, text_memory);
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
    try {
        retval = cpu->run_to_cycle(cpu->get_cycle()-1, out);
    }
    catch (int e) {
        handle_exception(e, err_msg, err_v);
    }
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

    exception_info.clear();

    //intercept cout
    bool retval;
    std::stringbuf strbuf;
    std::ostream out(&strbuf);
    try {
        retval = cpu->next_cycle(out);
    }
    catch (int e) {
        handle_exception(e, err_msg, err_v);
    }
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

godot::Dictionary PipelinedWrapper::get_diagram() {
    return diagram;
}

void PipelinedWrapper::set_diagram(godot::Dictionary p_diagram) {
    diagram = p_diagram;
}

void PipelinedWrapper::_update_diagram() {
    CpuFlex & cpuFlex = dynamic_cast<CpuFlex &>(*cpu);
    const uint32_t * const * l_diagram = cpuFlex.get_diagram();
    uint32_t current_cycle = cpu->get_cycle();
    godot::Dictionary result = {};

    std::vector<uint32_t> loaded_inst = cpu->get_loaded_instructions();
    for (size_t i = 1; i < loaded_inst.size(); ++i)
    {   
        uint32_t ipc = loaded_inst[i];
        uint32_t iindex = (ipc - MEM_TEXT_START)/4 + 1;
        int runstate = 0;
        godot::Array cycle_array = {};

        for (size_t j = 1; j<=current_cycle && runstate < 2; j++) {
            godot::Array array;
            array.push_back(std::to_string(j).c_str());
            if (l_diagram[i][j] > 0)
            {
                runstate = 1;
                if (l_diagram[i][j] == l_diagram[i][j-1]) {
                    array.push_back(stage_names[l_diagram[i][j]-1].c_str());
                }
                else {
                    array.push_back(stage_names[l_diagram[i][j]-1].c_str());
                }
            }
            else
            {
                /* if (runstate)
                    runstate = 2; */
                array.push_back("/");
            }
            /* if (iindex <= cycle_array.size()) { //backwards jumps
                cycle_array.remove_at(iindex);
                cycle_array.insert(iindex, array);
            }
            else { */
                cycle_array.push_back(array);
        }

        result[iindex] = cycle_array;
    }


    diagram = result;
}

void PipelinedWrapper::set_stage_signals_map(godot::Array p_signals_map){
    stage_signals_map = p_signals_map;
}

godot::Array PipelinedWrapper::get_stage_signals_map() {
    return stage_signals_map;
}

void PipelinedWrapper::change_branch_stage(int new_branch_stage) {
    cpu->change_branch_stage(new_branch_stage);
}

void PipelinedWrapper::change_branch_type(int new_branch_type) {
    cpu->change_branch_type(new_branch_type);
}

void PipelinedWrapper::enable_hazard_detection_unit(bool value) {
    cpu->enable_hazard_detection_unit(value);
}

void PipelinedWrapper::enable_forwarding_unit(bool value) {
    cpu->enable_forwarding_unit(value);
}

void PipelinedWrapper::handle_exception(int exception, std::string message, uint32_t value) {
    exception_info["err_no"] = exception;
    exception_info["err_msg"] = godot::String(message.c_str());
    exception_info["err_v"] = godot::String(Utils::hex32(value).c_str());
}

void PipelinedWrapper::set_exception_info(godot::Dictionary value) {
    exception_info = value;
}

godot::Dictionary PipelinedWrapper::get_exception_info() {
    return exception_info;
}


#endif //TFG_PIPELINED_WRAPPER
