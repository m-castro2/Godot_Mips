#ifndef TFG_CPU_FLEX_H
#define TFG_CPU_FLEX_H

#include "stage.h"
#include <vector>
#include <string>
#include "mem.h"
#include "utils.h"
#include <memory>

namespace mips_sim {

class CPU_FLEX {
public:
    CPU_FLEX(std::shared_ptr<mips_sim::Memory> memory);
    ~CPU_FLEX();

    string run_cycle();
    void set_stages(vector<Stage*> stages);
    vector<Stage*> get_stages();
    string to_string();

    vector<Stage*> stages;
    std::shared_ptr<mips_sim::Memory> memory;

    uint32_t HI, LO;
    uint32_t PC;
    uint32_t STATUS, EPC, CAUSE, BADVADDR;

    uint32_t cycle;
    size_t mi_index;
    bool ready;
    /* stall cycles */
    int execution_stall;
    std::vector<uint32_t> loaded_instructions;
    
    virtual void reset( bool reset_data_memory = true, bool reset_text_memory = true );

    /* register banks */
    uint32_t gpr[32];
    uint32_t fpr[32];
};
}
#endif //TFG_CPU_FLEX_H
