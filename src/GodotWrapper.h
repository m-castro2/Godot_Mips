#ifndef TFG_GODOTWRAPPER_H
#define TFG_GODOTWRAPPER_H
#include <vector>
#include <string>
#include "cpu_flex.h"
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>
namespace godot {

class GodotWrapper : public Node{
    GDCLASS(GodotWrapper, Node);
protected:
    static void _bind_methods();
public:
    std::unique_ptr<CPU_FLEX> cpu;
    GodotWrapper();
    ~GodotWrapper();
    godot::String run_cycle();
    godot::String init();
};
}
#endif //TFG_GODOTWRAPPER_H