#include "stage.h"
#include "cpu_flex.h"

#include <string>


CPU_FLEX::CPU_FLEX() {
    // initialize any variables here
}

CPU_FLEX::~CPU_FLEX() {
    // add your cleanup here
}

string CPU_FLEX::run_cycle() {
    string out = "";
    for (auto stage: stages) {
        out += stage->runStage();
    }
    return "";
}

void CPU_FLEX::set_stages(vector<Stage*> p_stages) {
    stages = p_stages;
}

vector<Stage*> CPU_FLEX::get_stages() {
    return stages;
}

string CPU_FLEX::to_string() {
    string out = "";
    out += std::to_string(stages.size()) +  " stages: \n";
    for (Stage* stage: stages) {
        out += stage->stageName + "\n";
    }
}