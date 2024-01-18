#ifndef TFG_PIPELINED_WRAPPER_H
#define TFG_PIPELINED_WRAPPER_H

#include <vector>
#include <string>
#include <memory>

#include "../mips_sim/src/cpu/cpu_pipelined.h"
#include "../mips_sim/src/cpu_flex/cpu_flex.h"
#include "../mips_sim/src/exception.h"


#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>

typedef struct {
    godot::String PCValue;
    godot::String LOValue;
    godot::String HIValue;
    godot::String cycles;

} cpu_info_t;


class PipelinedWrapper : public godot::Node {
    GDCLASS(PipelinedWrapper, Node);
    
    static PipelinedWrapper* pipelinedWrapper;

protected:
    static void _bind_methods();
public:
    PipelinedWrapper();
    ~PipelinedWrapper();

    static PipelinedWrapper* get_singleton();

    godot::Dictionary* cpu_info;
    std::unique_ptr<mips_sim::CpuFlex> cpu;
    std::shared_ptr<mips_sim::Memory> mem;
    godot::Array instructions;
    godot::Array loaded_instructions;
    godot::Dictionary diagram; //diagram[instruction_index][at_cycle] = "stage_name"
    godot::Array stage_signals_map {}; //map[stage]["Signal"] = value

    godot::String reset_cpu(bool data_memory, bool text_memory);
    godot::String next_cycle();
    godot::String previous_cycle();
    godot::String init();
    godot::String show_memory();
    bool is_ready();
    bool load_program(godot::String filename, bool is_file, godot::Dictionary memory_data);

    godot::Dictionary get_cpu_info();
    void set_cpu_info(godot::Dictionary p_cpu_info);
    godot::Array get_instructions();
    void set_instructions(godot::Array p_instructions);
    godot::Array get_loaded_instructions();
    void set_loaded_instructions(godot::Array p_loaded_instructions);
    void set_diagram(godot::Dictionary p_diagram);
    godot::Dictionary get_diagram();
    void set_stage_signals_map(godot::Array p_signals_map);
    godot::Array get_stage_signals_map();

    void change_branch_stage(int new_branch_stage);
    void change_branch_type(int new_branch_type);
    void enable_hazard_detection_unit(bool value);
    void enable_forwarding_unit(bool value);

    void _update_cpu_info();
    void _update_loaded_instructions();
    void _update_diagram();

    godot::Dictionary exception_info;
    void set_exception_info(godot::Dictionary value);
    godot::Dictionary get_exception_info();
    void handle_exception(int exception, std::string message, uint32_t value, int syscall_id);

    godot::Array get_register_names();

    godot::Array get_fp_register_names();

    godot::String to_hex32(uint32_t value);

    godot::Array get_memory_data(bool from_backup);

    godot::Array get_register_values();

    godot::Array get_fp_register_values_f();

    godot::Array get_fp_register_values_d();

    std::map<uint32_t, std::vector<uint32_t>> memory_map {}; //memory backup

    godot::String create_memory_backup();

    void execute_syscall_callback(godot::Dictionary values);
};
#endif //TFG_PIPELINED_WRAPPER_H