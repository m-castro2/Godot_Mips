#ifndef TFG_CPU_FLEX_H
#define TFG_CPU_FLEX_H

#include "stage.h"
#include <vector>
#include <string>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/node.hpp>


class CPU_FLEX {
public:
    CPU_FLEX();
    ~CPU_FLEX();
    string run_cycle();
    void set_stages(vector<Stage*> stages);
    vector<Stage*> get_stages();
    string to_string();
    vector<Stage*> stages;
};

#endif //TFG_CPU_FLEX_H
