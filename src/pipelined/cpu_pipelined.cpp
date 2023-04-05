#include "cpu_pipelined.h"
#include "../utils.h"
#include "../exception.h"

#include <cassert>
#include <iostream>
#include <iomanip>

using namespace std;

#define MAX_DIAGRAM_SIZE 500

namespace mips_sim
{
  constexpr int CpuPipelined::uc_microcode_matrix[][SIGNAL_COUNT];
  constexpr uint32_t CpuPipelined::uc_signal_bits[SIGNAL_COUNT];
  constexpr op_microcode_t CpuPipelined::op_select[];

  CpuPipelined::CpuPipelined(std::shared_ptr<Memory> _memory,
                             std::shared_ptr<ControlUnit> _control_unit,
                             int _branch_type,
                             int _branch_stage,
                             bool _has_forwarding_unit,
                             bool _has_hazard_detection_unit)
    : Cpu(_memory,
          _control_unit?_control_unit:
            std::shared_ptr<ControlUnit>(
              new ControlUnit(CpuPipelined::uc_signal_bits,
                              CpuPipelined::uc_microcode_matrix,
                              nullptr))
         )
  {

    status[KEY_BRANCH_TYPE]           = _branch_type;
    status[KEY_BRANCH_STAGE]          = _branch_stage;
    status[KEY_FORWARDING_UNIT]       = _has_forwarding_unit;
    status[KEY_HAZARD_DETECTION_UNIT] = _has_hazard_detection_unit;
    
    /* signals sorted in reverse order */
    signal_t signals_ID[] = {
      SIG_MEM2REG, SIG_REGBANK, SIG_REGWRITE, // WB stage
      SIG_MEMREAD, SIG_MEMWRITE, // MEM stage
      SIG_BRANCH, SIG_PCSRC, SIG_ALUSRC, SIG_ALUOP, SIG_REGDST}; // EX stage

    /* build signals bitmask as the number of signals passed to the next stage */
    sigmask[IF_ID]  = UNDEF32;
    sigmask[ID_EX]  = control_unit->get_signal_bitmask(signals_ID, 10);
    sigmask[EX_MEM] = control_unit->get_signal_bitmask(signals_ID, 7);
    sigmask[MEM_WB] = control_unit->get_signal_bitmask(signals_ID, 3);

    pc_write = true;
    flush_pipeline = 0;
    next_pc = 0;

    pc_conditional_branch = 0;
    pc_register_jump      = 0;
    pc_instruction_jump   = 0;

    loaded_instruction_index = 1;
    loaded_instructions.push_back(PC);

    diagram = new uint32_t*[MAX_DIAGRAM_SIZE];
    for (size_t i=0; i<MAX_DIAGRAM_SIZE; ++i)
      diagram[i] = new uint32_t[MAX_DIAGRAM_SIZE];
  }

  CpuPipelined::~CpuPipelined()
  {
    for (size_t i=0; i<MAX_DIAGRAM_SIZE; ++i)
      delete diagram[i];
    delete diagram;
  }

  bool CpuPipelined::process_branch(uint32_t instruction_code,
                      uint32_t rs_value, uint32_t rt_value,
                      uint32_t pc_value)
  {
    instruction_t instruction = Utils::fill_instruction(instruction_code);

    uint32_t opcode = instruction.opcode;
    uint32_t funct = instruction.funct;
    uint32_t addr_i32 = static_cast<uint32_t>(static_cast<int>(instruction.addr_i) << 16 >> 16);

    bool conditional_branch = (status.at(KEY_BRANCH_STAGE) == STAGE_ID) &&
                              ((rs_value == rt_value && opcode == OP_BEQ)
                           || (rs_value != rt_value && opcode == OP_BNE));

    pc_conditional_branch = pc_value + (addr_i32 << 2);
    pc_register_jump = rs_value;
    pc_instruction_jump = (pc_value & 0xF0000000) | (instruction.addr_j << 2);

    bool branch_taken = conditional_branch
          || opcode == OP_J || opcode == OP_JAL
          || (opcode == OP_RTYPE && (funct == SUBOP_JR || funct == SUBOP_JALR));

    return branch_taken;
  }

/******************************************************************************/

  void CpuPipelined::stage_if( ostream &out )
  {
    uint32_t pc_src_signal = control_unit->test(next_seg_regs[ID_EX].data[SR_SIGNALS],
                                                SIG_PCSRC);
    seg_reg_t next_seg_reg = {};
    uint32_t instruction_code;
    string cur_instr_name;

    if (PC != loaded_instructions[loaded_instruction_index])
    {
      loaded_instruction_index++;
      loaded_instructions.push_back(PC);
    }

    out << "IF stage" << endl;

    /* fetch instruction */
    instruction_code = memory->mem_read_32(PC);

    cur_instr_name = Utils::decode_instruction(instruction_code);
    out << "   *** PC: 0x" << Utils::hex32(PC) << endl;
    out << "   *** " << cur_instr_name << " : 0x"
        << Utils::hex32(instruction_code) << endl;
    current_state[STAGE_IF] = PC;

    /* increase PC */
    if (pc_write)
    {
      switch(pc_src_signal)
      {
        case 0:
          PC += 4; break;
        case 1:
          out << "   !!! Conditional branch taken >> 0x"
             << Utils::hex32(pc_conditional_branch) << endl;
          PC = pc_conditional_branch; break;
        case 2:
          out << "   !!! Register jump taken >> 0x"
             << Utils::hex32(pc_register_jump) << endl;
          PC = pc_register_jump; break;
        case 3:
          out << "   !!! Unconditional jump taken >> 0x"
             << Utils::hex32(pc_instruction_jump) << endl;
          PC = pc_instruction_jump; break;
        default:
          assert(0);
      }

      /* next instruction */
      next_seg_reg.data[SR_INSTRUCTION] = instruction_code;
      next_seg_reg.data[SR_PC] = PC;

      next_seg_reg.data[SR_IID] = loaded_instruction_index;

      if (!write_segmentation_register(IF_ID, next_seg_reg))
      {
        /* no structural hazard should happen here */
        assert(0);
      }
    }
  }

/******************************************************************************/

  bool CpuPipelined::detect_hazard( uint32_t read_reg, bool can_forward, bool fp_reg) const
  {
    if(!status.at(KEY_HAZARD_DETECTION_UNIT))
    {
      //TODO: Check for hazards anyway and keep the info.
      //TODO: Inform about ignored hazard
      return false;
    }
      
    bool hazard;

    /* check next 2 registers as forwarding would happen on next cycle */
    uint32_t ex_regdest   = seg_regs[ID_EX].data[SR_REGDEST];
    uint32_t ex_regwrite  = control_unit->test(seg_regs[ID_EX].data[SR_SIGNALS], SIG_REGWRITE);
    uint32_t ex_fpwrite   = control_unit->test(seg_regs[ID_EX].data[SR_SIGNALS], SIG_REGBANK);
    uint32_t ex_memread   = control_unit->test(seg_regs[ID_EX].data[SR_SIGNALS], SIG_MEMREAD);
    uint32_t mem_regdest  = seg_regs[EX_MEM].data[SR_REGDEST];
    uint32_t mem_regwrite = control_unit->test(seg_regs[EX_MEM].data[SR_SIGNALS], SIG_REGWRITE);
    uint32_t mem_fpwrite  = control_unit->test(seg_regs[EX_MEM].data[SR_SIGNALS], SIG_REGBANK);

    bool ex_regtype_match = !(ex_fpwrite ^ fp_reg);
    bool mem_regtype_match = !(mem_fpwrite ^ fp_reg);

    hazard =     (ex_regdest == read_reg)
              && ex_regwrite
              && ex_regtype_match
              && (ex_memread || !can_forward);
    hazard |=    (mem_regdest == read_reg)
              && mem_regtype_match
              && mem_regwrite
              && !can_forward;
    return hazard;
  }

  /* ID stage: Decode and branch */
  void CpuPipelined::stage_id( ostream &out )
  {
    seg_reg_t next_seg_reg = {};

    size_t mi_index = UNDEF32;
    uint32_t microinstruction;
    bool stall = false;
    uint32_t rs_value, rt_value;
    uint32_t reg_dest;

    /* get data from previous stage */
    uint32_t instruction_code = seg_regs[IF_ID].data[SR_INSTRUCTION];
    uint32_t pc_value = seg_regs[IF_ID].data[SR_PC];

    out << "ID stage: " << Utils::decode_instruction(instruction_code) << "Inst code: " << instruction_code << endl;

    instruction_t instruction = Utils::fill_instruction(instruction_code);
    out << "  -Instruction:"
        << " OP=" << static_cast<uint32_t>(instruction.opcode)
        << " Rs=" << Utils::get_register_name(instruction.rs)
        << " Rt=" << Utils::get_register_name(instruction.rt)
        << " Rd=" << Utils::get_register_name(instruction.rd)
        << " Shamt=" << static_cast<uint32_t>(instruction.shamt)
        << " Func=" << static_cast<uint32_t>(instruction.funct)
        << endl << "            "
        << " addr16=0x" << Utils::hex32(static_cast<uint32_t>(instruction.addr_i), 4)
        << " addr26=0x" << Utils::hex32(static_cast<uint32_t>(instruction.addr_j), 7)
        << endl;
    current_state[STAGE_ID] = pc_value-4;

    if (instruction.code == 0)
    {
      /* NOP */
      microinstruction = 0;
    }
    else
    {
      /* this loop eventually finishes: last entry is {UNDEF8,UNDEF8} */
      for (size_t i=0; ; ++i)
      {
        if (instruction.opcode == op_select[i].opcode
            || op_select[i].opcode == UNDEF8)
        {
          if (instruction.funct == op_select[i].subopcode
              || op_select[i].subopcode == UNDEF8)
          {
            mi_index = op_select[i].microinstruction_index;
            break;
          }
        }
      }

      microinstruction = control_unit->get_microinstruction(mi_index);
      out << "   Microinstruction: [" << mi_index << "]: 0x"
          << Utils::hex32(microinstruction) << endl;
    }

    if (instruction.opcode == 0 && instruction.funct == SUBOP_SYSCALL)
    {
      /* stalls until previous instructions finished */
      stall = !(seg_regs[ID_EX].data[SR_INSTRUCTION] == 0 &&
                seg_regs[EX_MEM].data[SR_INSTRUCTION] == 0);
    }

    if (instruction.opcode == OP_FTYPE)
    {
      /* will go to coprocessor */
      //TODO
      throw Exception::e(CPU_UNIMPL_EXCEPTION, "Instruction not implemented yet: " + Utils::decode_instruction(instruction_code));

      //write_segmentation_register(ID_EX, {});
    }
    else
    {
      /* integer unit */
      rs_value = read_register(instruction.rs);
      if (control_unit->test(microinstruction, SIG_REGBANK))
        rt_value = read_fp_register(instruction.rt);
      else
        rt_value = read_register(instruction.rt);

      if (status.at(KEY_HAZARD_DETECTION_UNIT))
      {
        //TODO: Branch stage can be decided using additional signals.
        // That way we don't need explicit comparisons here
        bool can_forward = status.at(KEY_FORWARDING_UNIT) &&
                           ((instruction.opcode != OP_BNE && instruction.opcode != OP_BEQ)
                             || status.at(KEY_BRANCH_STAGE) > STAGE_ID);

        /* check for hazards */
        if (instruction.code > 0 && instruction.funct != SUBOP_SYSCALL
            && instruction.opcode != OP_LUI)
        {
          stall = detect_hazard(instruction.rs, can_forward);

          if ((!control_unit->test(microinstruction, SIG_ALUSRC))
              || instruction.opcode == OP_SW
              || instruction.opcode == OP_SWC1)
          {
              stall |= detect_hazard(instruction.rt, can_forward, instruction.opcode == OP_SWC1);
          }
        }

        if (stall) out << "   Hazard detected: Pipeline stall" << endl;
      }

      pc_write = !stall;
      if (stall)
      {
        /* send "NOP" to next stage */
        next_seg_reg = {};
      }
      else
      {
        if (control_unit->test(microinstruction, SIG_BRANCH))
        {
          /* unconditional branches are resolved here */
          bool branch_taken = process_branch(instruction_code,
                                             rs_value, rt_value, pc_value);

          if (!branch_taken)
          {
            control_unit->set(microinstruction, SIG_PCSRC, 0);
          }

          if (status.at(KEY_BRANCH_TYPE) == BRANCH_FLUSH
              || (status.at(KEY_BRANCH_TYPE) == BRANCH_NON_TAKEN && branch_taken))
          {
            flush_pipeline = 1;

            if (!branch_taken)
              PC = pc_value-4;
          }
        }

        switch(control_unit->test(microinstruction, SIG_REGDST))
        {
          case 0:
            reg_dest = instruction.rt; break;
          case 1:
            reg_dest = instruction.rd; break;
          case 2:
            reg_dest = 31; break;
          default:
            assert(0);
        }

        /* send data to next stage */
        next_seg_reg.data[SR_INSTRUCTION] = instruction_code;
        next_seg_reg.data[SR_SIGNALS] = microinstruction & sigmask[ID_EX];
        next_seg_reg.data[SR_PC]      = pc_value; // bypass PC
        next_seg_reg.data[SR_RSVALUE] = rs_value;
        next_seg_reg.data[SR_RTVALUE] = rt_value;
        next_seg_reg.data[SR_ADDR_I]  = instruction.addr_i;
        next_seg_reg.data[SR_RT]      = instruction.rt;
        next_seg_reg.data[SR_RD]      = instruction.rd;
        next_seg_reg.data[SR_REGDEST] = reg_dest;
        next_seg_reg.data[SR_FUNCT]   = instruction.funct;
        next_seg_reg.data[SR_OPCODE]  = instruction.opcode;
        next_seg_reg.data[SR_RS]      = instruction.rs;
        next_seg_reg.data[SR_SHAMT]   = instruction.shamt;

        next_seg_reg.data[SR_IID]     = seg_regs[IF_ID].data[SR_IID];
      }

      if (!write_segmentation_register(ID_EX, next_seg_reg))
      {
        /* no structural hazard should happen here */
        assert(0);
      }
    }
  }

/******************************************************************************/

  uint32_t CpuPipelined::forward_register( uint32_t reg, uint32_t reg_value,
                                           bool fp_reg, ostream &out ) const
  {
    assert(status.at(KEY_FORWARDING_UNIT));

    uint32_t mem_regdest  = seg_regs[EX_MEM].data[SR_REGDEST];
    uint32_t mem_regvalue = seg_regs[EX_MEM].data[SR_ALUOUTPUT];
    uint32_t mem_fpwrite  = control_unit->test(seg_regs[EX_MEM].data[SR_SIGNALS], SIG_REGBANK);
    uint32_t wb_regdest   = seg_regs[MEM_WB].data[SR_REGDEST];
    uint32_t wb_regvalue; /* can come from ALU output or Memory */
    uint32_t wb_fpwrite  = control_unit->test(seg_regs[MEM_WB].data[SR_SIGNALS], SIG_REGBANK);

    if (reg == 0 && !fp_reg)
      return reg_value;

    /* check EX/MEM register */
    if  (mem_regdest == reg
        && !(mem_fpwrite ^ fp_reg)
        && !control_unit->test(seg_regs[EX_MEM].data[SR_SIGNALS], SIG_MEMREAD)
        && control_unit->test(seg_regs[EX_MEM].data[SR_SIGNALS], SIG_REGWRITE))
    {
      out << " -- forward "
         << (fp_reg?Utils::get_fp_register_name(reg)
                   :Utils::get_register_name(reg))
         << " [0x" << Utils::hex32(mem_regvalue) << "] from EX/MEM" << endl;
      return mem_regvalue;
    }

    /* check MEM/WB register */
    if (wb_regdest == reg
        && !(wb_fpwrite ^ fp_reg)
        && control_unit->test(seg_regs[MEM_WB].data[SR_SIGNALS], SIG_REGWRITE))
    {
      switch (control_unit->test(seg_regs[MEM_WB].data[SR_SIGNALS], SIG_MEM2REG))
      {
        case 0:
          wb_regvalue = seg_regs[MEM_WB].data[SR_WORDREAD];
          break;
        case 1:
          wb_regvalue = seg_regs[MEM_WB].data[SR_ALUOUTPUT];
          break;
        case 2:
          wb_regvalue = seg_regs[MEM_WB].data[SR_PC];
          break;
        default:
          assert(0);
      }
      out << " -- forward "
          << (fp_reg?Utils::get_fp_register_name(reg)
                    :Utils::get_register_name(reg))
          << " [0x" << Utils::hex32(wb_regvalue) << "] from MEM/WB" << endl;
      return wb_regvalue;
    }

    return reg_value;
  }

  void CpuPipelined::stage_ex( ostream &out )
  {
    seg_reg_t next_seg_reg = {};
    uint32_t microinstruction = seg_regs[ID_EX].data[SR_SIGNALS];
    uint32_t alu_input_a, alu_input_b, alu_output;

    /* get data from previous stage */
    uint32_t instruction_code = seg_regs[ID_EX].data[SR_INSTRUCTION];
    uint32_t pc_value = seg_regs[ID_EX].data[SR_PC];
    uint32_t rs_value = seg_regs[ID_EX].data[SR_RSVALUE];
    uint32_t rt_value = seg_regs[ID_EX].data[SR_RTVALUE];
    uint32_t addr_i   = seg_regs[ID_EX].data[SR_ADDR_I];
    uint32_t rs       = seg_regs[ID_EX].data[SR_RS];
    uint32_t rt       = seg_regs[ID_EX].data[SR_RT];
    uint32_t opcode   = seg_regs[ID_EX].data[SR_OPCODE];
    uint32_t funct    = seg_regs[ID_EX].data[SR_FUNCT];
    uint32_t shamt    = seg_regs[ID_EX].data[SR_SHAMT];

    uint32_t addr_i32 = static_cast<uint32_t>(static_cast<int>(addr_i) << 16 >> 16);

    out << "EX stage: " << Utils::decode_instruction(instruction_code) << endl;
    current_state[STAGE_EX] = pc_value-4;

    /* forwarding unit */
    if (status.at(KEY_FORWARDING_UNIT))
    {
      rs_value = forward_register(rs, rs_value, false, out);
      if (control_unit->test(microinstruction, SIG_REGDST) == 1 ||
          !control_unit->test(microinstruction, SIG_REGWRITE))
        rt_value = forward_register(rt, rt_value, opcode == OP_SWC1, out);
    }

    alu_input_a = rs_value;
    alu_input_b = control_unit->test(microinstruction, SIG_ALUSRC)
                  ? addr_i32
                  : rt_value;

    switch (control_unit->test(microinstruction, SIG_ALUOP))
    {
      case 0:
        alu_output = alu_compute_subop(alu_input_a, alu_input_b,
                                       static_cast<uint8_t>(shamt), SUBOP_ADDU);
        break;
      case 1:
        alu_output = alu_compute_subop(alu_input_a, alu_input_b,
                                       static_cast<uint8_t>(shamt), SUBOP_SUBU);
        break;
      case 2:
        if (opcode == OP_RTYPE)
          alu_output = alu_compute_subop(alu_input_a, alu_input_b,
                                         static_cast<uint8_t>(shamt), funct);
        else
          alu_output = alu_compute_op(alu_input_a, alu_input_b, opcode);
        break;
      default:
        std::cerr << "Undefined ALU operation" << std::endl;
        assert(0);
    }

    out << "   ALU compute 0x" << Utils::hex32(alu_input_a) << " OP 0x"
        << Utils::hex32(alu_input_b) << " = 0x"
        << Utils::hex32(alu_output) << endl;

    /* send data to next stage */
    next_seg_reg.data[SR_INSTRUCTION] = instruction_code;
    next_seg_reg.data[SR_PC]         = pc_value; /* bypass PC */
    next_seg_reg.data[SR_SIGNALS]    = microinstruction & sigmask[EX_MEM];
    next_seg_reg.data[SR_RELBRANCH]  = (addr_i32 << 2) + seg_regs[ID_EX].data[SR_PC];
    next_seg_reg.data[SR_ALUZERO]    = ((alu_output == 0) && (opcode == OP_BEQ))
                                               || ((alu_output != 0) && (opcode == OP_BNE));
    next_seg_reg.data[SR_ALUOUTPUT]  = alu_output;
    next_seg_reg.data[SR_RTVALUE]    = rt_value;
    next_seg_reg.data[SR_REGDEST]    = seg_regs[ID_EX].data[SR_REGDEST];

    next_seg_reg.data[SR_IID] = seg_regs[ID_EX].data[SR_IID];

    if (!write_segmentation_register(EX_MEM, next_seg_reg))
    {
      /*TODO: STRUCTURAL HAZARD! */
      assert(0);
    }
  }

/******************************************************************************/

  void CpuPipelined::stage_mem( ostream &out )
  {
    seg_reg_t next_seg_reg = {};
    uint32_t word_read = UNDEF32;

    /* get data from previous stage */
    uint32_t instruction_code = seg_regs[EX_MEM].data[SR_INSTRUCTION];
    uint32_t pc_value         = seg_regs[EX_MEM].data[SR_PC];
    uint32_t microinstruction = seg_regs[EX_MEM].data[SR_SIGNALS];
    uint32_t mem_addr         = seg_regs[EX_MEM].data[SR_ALUOUTPUT];
    uint32_t rt_value         = seg_regs[EX_MEM].data[SR_RTVALUE];
    uint32_t branch_addr      = seg_regs[EX_MEM].data[SR_RELBRANCH];
    uint32_t branch_taken     = seg_regs[EX_MEM].data[SR_ALUZERO];

    out << "MEM stage: " << Utils::decode_instruction(instruction_code) << endl;
    current_state[STAGE_MEM] = pc_value-4;

    if (status.at(KEY_BRANCH_STAGE) == STAGE_MEM && control_unit->test(microinstruction, SIG_BRANCH))
    {
      /* if conditional branches are resolved here */
      if (status.at(KEY_BRANCH_TYPE) == BRANCH_FLUSH
          || (status.at(KEY_BRANCH_TYPE) == BRANCH_NON_TAKEN && branch_taken))
      {
        flush_pipeline = 3;

        if (!branch_taken)
          PC = pc_value-4;
      }

      if (branch_taken)
      {
        out << "  BRANCH: Jump to 0x" << Utils::hex32(branch_addr) << endl;

        next_pc = branch_addr;
      }
    }

    if (control_unit->test(microinstruction, SIG_MEMREAD))
    {
      out << "   MEM read 0x" << Utils::hex32(mem_addr);
      word_read = memory->mem_read_32(mem_addr);
    }
    else if (control_unit->test(microinstruction, SIG_MEMWRITE))
    {
      out << "   MEM write 0x" << Utils::hex32(rt_value) << " to 0x" << Utils::hex32(mem_addr) << endl;
      memory->mem_write_32(mem_addr, rt_value);
    }

    // ...
    out << "   Address/ALU_Bypass: 0x" << Utils::hex32(mem_addr) << endl;

    /* send data to next stage */
    next_seg_reg.data[SR_INSTRUCTION] = instruction_code;
    next_seg_reg.data[SR_PC]          = pc_value; /* bypass PC */
    next_seg_reg.data[SR_SIGNALS]     = microinstruction & sigmask[MEM_WB];
    next_seg_reg.data[SR_WORDREAD]    = word_read;
    next_seg_reg.data[SR_ALUOUTPUT]   = mem_addr; // come from alu output
    next_seg_reg.data[SR_REGDEST]     = seg_regs[EX_MEM].data[SR_REGDEST];

    next_seg_reg.data[SR_IID] = seg_regs[EX_MEM].data[SR_IID];

    if (!write_segmentation_register(MEM_WB, next_seg_reg))
    {
      /* no structural hazard should happen here */
      assert(0);
    }
  }

/******************************************************************************/

  void CpuPipelined::stage_wb( ostream &out )
  {
    uint32_t regwrite_value = UNDEF32;

    /* get data from previous stage */
    uint32_t instruction_code = seg_regs[MEM_WB].data[SR_INSTRUCTION];
    uint32_t pc_value         = seg_regs[MEM_WB].data[SR_PC];
    uint32_t microinstruction = seg_regs[MEM_WB].data[SR_SIGNALS];
    uint32_t reg_dest         = seg_regs[MEM_WB].data[SR_REGDEST];
    uint32_t mem_word_read    = seg_regs[MEM_WB].data[SR_WORDREAD];
    uint32_t alu_output       = seg_regs[MEM_WB].data[SR_ALUOUTPUT];

    out << "WB Stage: " << Utils::decode_instruction(instruction_code) << endl;
    current_state[STAGE_WB] = pc_value-4;

    switch (control_unit->test(microinstruction, SIG_MEM2REG))
    {
      case 0:
        regwrite_value = mem_word_read; break;
      case 1:
        regwrite_value = alu_output; break;
      case 2:
        regwrite_value = pc_value; break;
      default:
        assert(0);
    }

    if (control_unit->test(microinstruction, SIG_REGWRITE))
    {
      out << "   Result value: 0x" << Utils::hex32(regwrite_value) << endl;
      if (control_unit->test(microinstruction, SIG_REGBANK))
        out << "   Register dest: " << Utils::get_fp_register_name(reg_dest) << endl;
      else
        out << "   Register dest: " << Utils::get_register_name(reg_dest) << endl;
      out << "   Signal Mem2Reg: " << control_unit->test(microinstruction, SIG_MEM2REG) << endl;
    }

    if (control_unit->test(microinstruction, SIG_REGWRITE))
    {
      if (control_unit->test(microinstruction, SIG_REGBANK))
      {
        out << "   REG write " << Utils::get_fp_register_name(reg_dest)
            << " <-- 0x" << Utils::hex32(regwrite_value) << endl;
        write_fp_register(reg_dest, regwrite_value);
      }
      else
      {
        out << "   REG write " << Utils::get_register_name(reg_dest)
            << " <-- 0x" << Utils::hex32(regwrite_value) << endl;
        write_register(reg_dest, regwrite_value);
      }
    }
  }

/******************************************************************************/

  bool CpuPipelined::write_segmentation_register(size_t index, seg_reg_t values)
  {
    /* check if can write */
    if (seg_regs_wrflag & (1 << index))
    {
      /* already written this cycle: Structural hazard */
      return false;
    }

    /* write register and set wr flag */
    next_seg_regs[index] = values;
    seg_regs_wrflag |= (1 << index);

    return true;
  }

  void CpuPipelined::get_current_state(uint32_t * cs)
  {
    memcpy(cs, current_state, STAGE_COUNT*sizeof(uint32_t));
  }

  size_t CpuPipelined::get_current_instruction(size_t stage) const
  {
    assert(stage <= STAGE_WB);

    uint32_t instruction_code;
    if (stage == STAGE_IF)
    {
      instruction_code = loaded_instruction_index;
    }
    else
    {
      instruction_code = seg_regs[stage-1].data[SR_IID];
    }

    return instruction_code;
  }

  bool CpuPipelined::next_cycle( ostream &out )
  {
    Cpu::next_cycle( out );

    /* reset segmentation register write flags */
    seg_regs_wrflag = 0;

    stage_wb(out);
    stage_mem(out);
    stage_ex(out);
    stage_id(out);
    stage_if(out);

    for (size_t stage_id = 0; stage_id < STAGE_COUNT; ++stage_id)
    {
      size_t iindex = get_current_instruction(stage_id);
      //if (iindex >= MAX_DIAGRAM_SIZE || cycle >= MAX_DIAGRAM_SIZE)
      //{
        // TODO: Allow for disabling diagram? Cyclic buffer?
        //throw Exception::e(OVERFLOW_EXCEPTION, "Overflow in multicycle diagram");
      //}
      diagram[iindex][cycle] = static_cast<uint32_t>(stage_id+1);
    }

    /* update segmentation registers */
    memcpy(seg_regs, next_seg_regs, sizeof(seg_regs));

    if (flush_pipeline > 0)
    {
      for (int i = 0; i < flush_pipeline; ++i)
        seg_regs[i] = {};

      flush_pipeline = 0;
    }

    if (next_pc != 0)
    {
      PC = next_pc;
      next_pc = 0;
    }

    return ready;
  }

  const uint32_t * const * CpuPipelined::get_diagram( void ) const
  {
    return diagram;
  }

  void CpuPipelined::print_diagram( ostream &out ) const
  {
    out << setw(24) << " ";
    for (size_t i = 1; i <= cycle; ++i)
      out << right << setw(4) << i;
    out << endl;

    for (size_t i = 1; i < loaded_instructions.size(); ++i)
    {
      uint32_t ipc = loaded_instructions[i];
      uint32_t icode = ipc?memory->mem_read_32(ipc):0;
      uint32_t iindex = (ipc - MEM_TEXT_START)/4 + 1;
      out << setw(2) << right << iindex << " " << setw(23) << left << Utils::decode_instruction(icode);
      int runstate = 0;
      for (size_t j = 1; j<=cycle && runstate < 2; j++)
        if (diagram[i][j] > 0)
        {
          runstate = 1;
          if (diagram[i][j] == diagram[i][j-1])
            out << setw(4) << "--";
          else
            out << setw(4) << stage_names[diagram[i][j]-1];
        }
        else
        {
          if (runstate)
            runstate = 2;
          out << setw(4) << " ";
        }
      out << endl;
    }
  }

  void CpuPipelined::print_status( ostream &out ) const
  {
    out << "5-stage Pipelined CPU (IF/ID/EX/MEM/WB)" << endl;
    out << "  Hazard detection unit: " << (status.at(KEY_HAZARD_DETECTION_UNIT)?"yes":"no") << endl;
    out << "  Forwarding unit: " << (status.at(KEY_FORWARDING_UNIT)?"yes":"no") << endl;
    out << "  Conditional branches decided at " << (status.at(KEY_BRANCH_STAGE)==STAGE_ID?"ID":"MEM") << " stage" << endl;
    out << "  Branch processing strategy: ";
    switch(status.at(KEY_BRANCH_TYPE))
    {
    case BRANCH_NON_TAKEN:
      out << "Fixed non-taken" << endl; break;
    case BRANCH_FLUSH:
      out << "Flush the pipeline" << endl; break;
    case BRANCH_DELAYED:
      out << "Delayed branch" << endl; break;
    default:
      assert(0);
    }
    out << "  Multiplication delay: " << status.at("mult-delay") << " cycles"  << endl;
    out << "  Division delay: " << status.at("div-delay") << " cycles" << endl;
    out << "  Floating Point Add delay: " << status.at("fp-add-delay") << " cycles" << endl;
  }

  void CpuPipelined::reset( bool reset_data_memory, bool reset_text_memory )
  {
    Cpu::reset(reset_data_memory, reset_text_memory);

    memset(seg_regs, 0, sizeof(seg_regs));
    memset(next_seg_regs, 0, sizeof(next_seg_regs));

    for (size_t i=0; i<MAX_DIAGRAM_SIZE; ++i)
     memset(diagram[i], 0, MAX_DIAGRAM_SIZE * sizeof(uint32_t));

    memset(current_state, -1, STAGE_COUNT*sizeof(uint32_t));

    pc_write = true;
    flush_pipeline = 0;
    next_pc = 0;

    pc_conditional_branch = 0;
    pc_register_jump      = 0;
    pc_instruction_jump   = 0;

    loaded_instructions.push_back(PC);
    loaded_instruction_index = 1;
  }

  void CpuPipelined::enable_hazard_detection_unit(bool enabled)
  {
    status[KEY_HAZARD_DETECTION_UNIT] = enabled;
  }

  void CpuPipelined::enable_forwarding_unit(bool enabled)
  {
    status[KEY_FORWARDING_UNIT] = enabled;
  }

  void CpuPipelined::set_branch_stage(int branch_stage)
  {
    if (branch_stage != STAGE_ID && branch_stage != STAGE_MEM)
      throw Exception::e(CPU_EXCEPTION, "Branch decision should be at ID or MEM stages only");

    status[KEY_BRANCH_STAGE] = branch_stage;
  }

  void CpuPipelined::set_branch_type(int branch_type)
  {
    if (branch_type != BRANCH_NON_TAKEN && branch_type != BRANCH_FLUSH && branch_type != BRANCH_DELAYED)
      throw Exception::e(CPU_UNDEF_EXCEPTION, "Undefined branch processing technique");

    status[KEY_BRANCH_TYPE] = branch_type;
  }
} /* namespace */
