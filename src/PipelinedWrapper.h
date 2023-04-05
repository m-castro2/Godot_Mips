#ifndef TFG_PIPELINED_WRAPPER_H
#define TFG_PIPELINED_WRAPPER_H

#include <vector>
#include <string>
#include <memory>

#include "pipelined/cpu_pipelined.h"
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>
namespace godot {

class PipelinedWrapper : public Node{
    GDCLASS(PipelinedWrapper, Node);
protected:
    static void _bind_methods();
public:
    std::unique_ptr<mips_sim::Cpu> cpu;
    std::shared_ptr<mips_sim::Memory> mem;
    PipelinedWrapper();
    ~PipelinedWrapper();
    godot::String run_cycle();
    godot::String init();
    
    godot::String load_program(godot::String filename);
};
}
#endif //TFG_PIPELINED_WRAPPER_H