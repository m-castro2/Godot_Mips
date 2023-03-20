#include "stage.h"
#include "IF.cpp"
#include "ID.cpp"
#include "EX.cpp"
#include "MEM.cpp"
#include "WB.cpp"
#include "cpu_flex.h"

#include <vector>


int main() {
    vector<Stage*> stages;
    IF IF;
    ID ID;
    EX EX;
    MEM MEM;
    WB WB;
    stages.push_back(&IF);
    stages.push_back(&ID);
    stages.push_back(&EX);
    stages.push_back(&MEM);
    stages.push_back(&WB);
    CPU_FLEX* cpu = new CPU_FLEX();
    cpu->set_stages(stages);
    std::cout << cpu->run_cycle() << "\n";
    return 0;
}
