#ifndef MIPS_SIM_CONTROL_UNIT_H
#define MIPS_SIM_CONTROL_UNIT_H

#include "../global_defs.h"

#include <vector>
#include <string>
#include <iostream>

#define MAX_MICROINSTRUCTIONS 32

namespace mips_sim
{

/* special sub-opcodes (opcode=0) */

typedef struct
{
  uint8_t opcode;
  uint8_t subopcode;
  size_t jump1;
  size_t jump2;
  size_t jump4;
} ctrl_dir_t;

#define SIGNAL_COUNT 16

typedef enum
{
  SIG_PCWRITE   = 0,
  SIG_PCSRC     = 1,
  SIG_IOD       = 2,
  SIG_MEMREAD   = 3,
  SIG_MEMWRITE  = 4,
  SIG_IRWRITE   = 5,
  SIG_MEM2REG   = 6,
  SIG_REGBANK   = 7,
  SIG_REGDST    = 8,
  SIG_REGWRITE  = 9,
  SIG_SELALUA   = 10,
  SIG_SELALUB   = 11,
  SIG_ALUSRC    = 12,
  SIG_ALUOP     = 13,
  SIG_BRANCH    = 14,
  SIG_CTRLDIR   = 15
} signal_t;

const std::string signal_names[] = {
 "PCWrite",  "PCSrc",  "IoD", "MemRead", "MemWrite", "IRWrite",
 "MemToReg", "RegBank", "RegDst", "RegWrite", "SelALUA", "SelALUB", "ALUSrc",
 "ALUOp", "Branch", "CtrlDir"
};

class ControlUnit
{
public:

  ControlUnit(const uint32_t uc_signal_bits[SIGNAL_COUNT],
              const int uc_microcode_matrix[][SIGNAL_COUNT],
              const ctrl_dir_t * uc_ctrl_dir);

  static std::vector<uint32_t> build_microcode(const int [][SIGNAL_COUNT],
                                               const uint32_t signals[SIGNAL_COUNT]);

  uint32_t test(uint32_t state, signal_t signal) const;

  void set(uint32_t & state, signal_t signal, int value = -1) const;

  uint32_t get_microinstruction(size_t index) const;

  size_t get_next_microinstruction_index(size_t current_index,
                                         uint8_t opcode,
                                         uint8_t subopcode = UNDEF8) const;

  uint32_t get_signal_bitmask( signal_t const signal[], size_t count ) const;

  void print_microcode( std::ostream &out = std::cout ) const;

  void print_microinstruction( size_t index, std::ostream &out = std::cout ) const;

  void print_signals( uint32_t microinstruction, std::ostream &out = std::cout ) const;

private:
  ctrl_dir_t find_ctrl_dir_entry(uint8_t opcode, uint8_t subopcode) const;

  uint32_t uc_signals[SIGNAL_COUNT];
  std::vector<uint32_t> uc_microcode;
  const ctrl_dir_t * uc_ctrl_dir;

  bool ctrl_dir_set;
};

} /* namespace */
#endif
