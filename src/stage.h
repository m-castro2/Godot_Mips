#ifndef TFG_STAGE_H
#define TFG_STAGE_H
#include <string>

using namespace std;

#define IF_ID  0
#define ID_EX  1
#define EX_MEM 2
#define MEM_WB 3

#define SR_INSTRUCTION  0
#define SR_IID          1
#define SR_PC           2
#define SR_SIGNALS      3
#define SR_OPCODE       4
#define SR_RS           5
#define SR_RT           6
#define SR_RD           7
#define SR_SHAMT        8
#define SR_FUNCT        9
#define SR_RSVALUE     10
#define SR_RTVALUE     11
#define SR_ADDR_I      12
#define SR_REGDEST     13
#define SR_ALUOUTPUT   14
#define SR_ALUZERO     15
#define SR_RELBRANCH   16
#define SR_WORDREAD    17

struct seg_reg_t {
    uint32_t data[32];
};

class Stage {
public:
    string stageName;
    virtual string runStage() = 0;
    virtual string run() = 0;
    virtual ~Stage() = default;

    seg_reg_t seg_regs[4] = {};
};

class stage
{
};
#endif //TFG_STAGE_H
