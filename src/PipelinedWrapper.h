#ifndef TFG_PIPELINED_WRAPPER_H
#define TFG_PIPELINED_WRAPPER_H

#include <vector>
#include <string>
#include <memory>

#include "pipelined/cpu_pipelined.h"
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>
namespace godot {

typedef struct {
    godot::String PCValue;
    godot::String LOValue;
    godot::String HIValue;
    godot::String cycles;

} cpu_info_t;

class PipelinedWrapper : public Node{
    GDCLASS(PipelinedWrapper, Node);
protected:
    static void _bind_methods();
public:
    godot::Dictionary* cpu_info;
    std::unique_ptr<mips_sim::Cpu> cpu;
    std::shared_ptr<mips_sim::Memory> mem;
    PipelinedWrapper();
    ~PipelinedWrapper();
    godot::String next_cycle();
    godot::String init();
    
    bool is_ready();
    bool load_program(godot::String filename);

    void set_cpu_info(godot::Dictionary p_cpu_info);
    godot::Dictionary get_cpu_info();

    void _update_cpu_info();
};
}
#endif //TFG_PIPELINED_WRAPPER_H