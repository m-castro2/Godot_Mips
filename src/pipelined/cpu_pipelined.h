#ifndef MIPS_SIM_CPU_PIPELINED_H
#define MIPS_SIM_CPU_PIPELINED_H

/* processor stages */
#define STAGE_IF      0
#define STAGE_ID      1
#define STAGE_EX      2
#define STAGE_MEM     3
#define STAGE_WB      4
#define STAGE_COUNT   5

/* segmentation register types */
#define IF_ID  0
#define ID_EX  1
#define EX_MEM 2
#define MEM_WB 3

/* data through segmentation registers */
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

/* brahch processing options */
#define BRANCH_FLUSH     0 /* flush pipeline */
#define BRANCH_NON_TAKEN 1 /* fixed non taken */
#define BRANCH_DELAYED   2 /* delayed branch */

/* proper keys */
#define KEY_BRANCH_TYPE           "branch-type"
#define KEY_BRANCH_STAGE          "branch-stage"
#define KEY_FORWARDING_UNIT       "has-forwarding-unit"
#define KEY_HAZARD_DETECTION_UNIT "has-hazard-detection-unit"

#include "cpu.h"

#define X -1

namespace mips_sim
{

  const std::string stage_names[] = {"IF",  "ID",  "EX", "MEM", "WB"};


/* segmentation register */
struct seg_reg_t {
  uint32_t data[32];
};

struct op_microcode_t {
  uint8_t opcode;
  uint8_t subopcode;
  uint32_t microinstruction_index;
};

class CpuPipelined : public Cpu
{
  public:

    static constexpr uint32_t uc_signal_bits[SIGNAL_COUNT] =
     { 0, 2, 0, 1, 1, 0, 2, 1, 2, 1, 0, 0, 1, 2, 1, 0 };

    static constexpr int uc_microcode_matrix[][SIGNAL_COUNT] =
    // P  P  I  M  M  I  M  R  R  R  S  S  A  A  B  C
    // C  C  o  R  W  W  2  B  D  W  A  A  S  O  r  t
    // w  s  D  d  r  r  R  k  s  r  A  B  r  p  a  d
    // -  1  -  1  1  -  2  1  2  1  -  -  1  2  1  -
     {{X, 0, X, 0, 0, X, 1, 0, 1, 1, X, X, 0, 2, 0, X}, //  0 R type
      {X, 3, X, 0, 0, X, 0, 0, 0, 0, X, X, 0, 0, 1, X}, //  1 J
      {X, 2, X, 0, 0, X, 0, 0, 0, 0, X, X, 0, 0, 1, X}, //  2 JR
      {X, 3, X, 0, 0, X, 2, 0, 2, 1, X, X, 0, 0, 1, X}, //  3 JAL
      {X, 2, X, 0, 0, X, 2, 0, 2, 1, X, X, 0, 0, 1, X}, //  4 JALR
      {X, 1, X, 0, 0, X, 0, 0, 0, 0, X, X, 0, 1, 1, X}, //  5 BNE/BEQ
      {X, 0, X, 1, 0, X, 0, 0, 0, 1, X, X, 1, 0, 0, X}, //  6 LW
      {X, 0, X, 0, 1, X, 0, 0, 0, 0, X, X, 1, 0, 0, X}, //  7 SW
      {X, 0, X, 0, 0, X, 1, 0, 0, 1, X, X, 1, 2, 0, X}, //  8 I type
      {X, 0, X, 0, 0, X, 1, 1, 1, 1, X, X, 0, 2, 0, X}, //  9 FType add/sub/mul/div
      {X, 0, X, 1, 0, X, 0, 1, 0, 1, X, X, 1, 0, 0, X}, // 10 LWC1
      {X, 0, X, 0, 1, X, 0, 1, 0, 0, X, X, 1, 0, 0, X}, // 11 SWC1
      {X, 0, X, 0, 0, X, 0, 0, 0, 0, X, X, 0, 2, 0, X}, // 12 SYSCALL
      {0} // end
    };

    static constexpr op_microcode_t op_select[] =
    {
      {OP_RTYPE, SUBOP_JR,       2},
      {OP_RTYPE, SUBOP_JALR,     4},
      {OP_RTYPE, SUBOP_SYSCALL, 12},
      {OP_RTYPE, UNDEF8,         0},
      {OP_J,     UNDEF8,         1},
      {OP_JAL,   UNDEF8,         3},
      {OP_BNE,   UNDEF8,         5},
      {OP_BEQ,   UNDEF8,         5},
      {OP_LW,    UNDEF8,         6},
      {OP_LWC1,  UNDEF8,        10},
      {OP_SW,    UNDEF8,         7},
      {OP_SWC1,  UNDEF8,        11},
      {OP_FTYPE, SUBOP_FPADD,    9},
      {OP_FTYPE, SUBOP_FPSUB,    9},
      {OP_FTYPE, SUBOP_FPMUL,    9},
      {OP_FTYPE, SUBOP_FPDIV,    9},
      {OP_FTYPE, SUBOP_FPCEQ,    8},
      {OP_FTYPE, SUBOP_FPCLE,    8},
      {OP_FTYPE, SUBOP_FPCLT,    8},
      {OP_FTYPE, UNDEF8     ,    5}, // bc1t / bc1f
      {UNDEF8,   UNDEF8,         8}   // I type

    };

    //CpuPipelined(std::shared_ptr<Memory>);
    CpuPipelined(std::shared_ptr<Memory>,
                 std::shared_ptr<ControlUnit> = nullptr,
                 int branch_type = BRANCH_NON_TAKEN,
                 int branch_stage = STAGE_ID,
                 bool has_forwarding_unit = true,
                 bool has_hazard_detection_unit = true);
    virtual ~CpuPipelined() override;

    void get_current_state(uint32_t *);
    const uint32_t * const * get_diagram( void ) const;

    virtual bool next_cycle( std::ostream & = std::cout ) override;
    virtual void print_diagram( std::ostream & = std::cout ) const override;
    virtual void print_status( std::ostream & = std::cout ) const override;
    virtual void reset( bool reset_data_memory = true,
                        bool reset_text_memory = true ) override;

    void enable_hazard_detection_unit( bool );
    void enable_forwarding_unit( bool );
    void set_branch_stage( int );
    void set_branch_type( int );
    
  private:

    bool pc_write; /* if false, blocks pipeline */
    uint32_t next_pc;
    int flush_pipeline;
    seg_reg_t seg_regs[STAGE_COUNT-1] = {};
    uint32_t seg_regs_wrflag = 0;

    seg_reg_t next_seg_regs[STAGE_COUNT-1] = {};

    uint32_t sigmask[STAGE_COUNT-1] = {};

    uint32_t pc_conditional_branch;
    uint32_t pc_instruction_jump;
    uint32_t pc_register_jump;

    uint32_t loaded_instruction_index;
    uint32_t **diagram;
    uint32_t current_state[STAGE_COUNT] = {UNDEF32,UNDEF32,UNDEF32,UNDEF32,UNDEF32};

    void stage_if( std::ostream &out = std::cout );
    void stage_id( std::ostream &out = std::cout );
    void stage_ex( std::ostream &out = std::cout );
    void stage_mem( std::ostream &out = std::cout );
    void stage_wb( std::ostream &out = std::cout );

    size_t get_current_instruction(size_t stage) const;

    // void stage_ex_cop ( bool verbose = true);
    // void stage_mem_cop ( bool verbose = true);
    // void stage_wb_cop ( bool verbose = true);
    //
    // seg_reg_t cop_seg_regs[DIV_DELAY + 2] = {};

    uint32_t forward_register( uint32_t reg, uint32_t reg_value,
                               bool fp_reg = false,
                               std::ostream &out = std::cout ) const;
    bool detect_hazard( uint32_t read_reg, bool can_forward,
                        bool fp_reg = false ) const;

    bool process_branch(uint32_t instruction_code,
                        uint32_t rs_value, uint32_t rt_value,
                        uint32_t pc_value);

    /* return false in case of structural hazard */
    /* registers can be written once per cycle */
    bool write_segmentation_register(size_t index, seg_reg_t values);
};

} /* namespace */

#undef X
#endif
