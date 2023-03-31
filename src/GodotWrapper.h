#ifndef TFG_GODOTWRAPPER_H
#define TFG_GODOTWRAPPER_H
#include <vector>
#include <string>
#include <memory>
#include "cpu_flex.h"
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>
namespace godot {

class GodotWrapper : public Node{
    GDCLASS(GodotWrapper, Node);
private:
    godot::Array cpu_stages;
protected:
    static void _bind_methods();
public:
    std::unique_ptr<mips_sim::CPU_FLEX> cpu;
    GodotWrapper();
    ~GodotWrapper();
    godot::String run_cycle();
    godot::String init();
    
    //cpu_stages
    godot::Array get_cpu_stages();
    void set_cpu_stages(godot::Array p_cpu_stages);
    void _set_cpu_stages();
    
    godot::String load_program(godot::String filename);
};
}
#endif //TFG_GODOTWRAPPER_H