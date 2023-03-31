#include "stage.h"
#include "cpu_flex.h"

#include <string>

namespace mips_sim {


CPU_FLEX::CPU_FLEX(std::shared_ptr<mips_sim::Memory> _memory): memory(_memory) {
    loaded_instructions.reserve(400);
    loaded_instructions.push_back(0); /* start with a nop instruction */

    /* reset CPU but no memory */
    reset(false, false);
}

CPU_FLEX::~CPU_FLEX() {
    // add your cleanup here
}

string CPU_FLEX::run_cycle() {
    string out = "";
    for (auto stage: stages) {
        out += stage->runStage();
    }
    return out;
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
    return out;
}

void CPU_FLEX::reset( bool reset_data_memory, bool reset_text_memory )
{
  PC       = MEM_TEXT_START;
  HI       = 0;
  LO       = 0;
  STATUS   = 0;
  EPC      = 0;
  CAUSE    = 0;
  BADVADDR = 0;

  cycle = 0;
  mi_index = 0;
  execution_stall = 0;
  ready = true;

  /* set registers to 0 */
  memset(gpr, 0, 32 * sizeof(int));
  memset(fpr, 0, 32 * sizeof(int));

  /* stack pointer */
  gpr[Utils::find_register_by_name("$sp")] =
    static_cast<uint32_t>(MEM_STACK_START) + MEM_STACK_SIZE;

  if (reset_data_memory)
    memory->reset(MEM_DATA_REGION);

  if (reset_text_memory)
    memory->reset(MEM_TEXT_REGION);

  loaded_instructions.clear();
  loaded_instructions.push_back(0); /* start with a nop instruction */
}
}