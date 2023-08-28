#ifndef TFG_PIPELINED_WRAPPER_H
#define TFG_PIPELINED_WRAPPER_H

#include <vector>
#include <string>
#include <memory>

#include "../mips_sim/src/cpu/cpu_pipelined.h"
#include "../mips_sim/src/cpu_flex/cpu_flex.h"


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
protected:
    static void _bind_methods();
public:
    PipelinedWrapper();
    ~PipelinedWrapper();

    godot::Dictionary* cpu_info;
    std::unique_ptr<mips_sim::CpuFlex> cpu;
    std::shared_ptr<mips_sim::Memory> mem;
    godot::Array instructions;
    godot::Array loaded_instructions;
    godot::Dictionary diagram; //diagram[instruction_index][at_cycle] = "stage_name"

    godot::String reset_cpu();
    godot::String next_cycle();
    godot::String previous_cycle();
    godot::String init();
    godot::String show_memory();
    bool is_ready();
    bool load_program(godot::String filename);

    godot::Dictionary get_cpu_info();
    void set_cpu_info(godot::Dictionary p_cpu_info);
    godot::Array get_instructions();
    void set_instructions(godot::Array p_instructions);
    godot::Array get_loaded_instructions();
    void set_loaded_instructions(godot::Array p_loaded_instructions);
    void set_diagram(godot::Dictionary p_diagram);
    godot::Dictionary get_diagram();

    void _update_cpu_info();
    void _update_loaded_instructions();
    void _update_diagram();
};
#endif //TFG_PIPELINED_WRAPPER_H