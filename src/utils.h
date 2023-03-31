#ifndef MIPS_SIM_UTILS_H
#define MIPS_SIM_UTILS_H

#include "global_defs.h"
#include <cstdint>

namespace mips_sim
{

class Utils
{
public:
  static bool file_exists(const std::string & filename);

  static uint32_t address_align_4(uint32_t address);
  
  static std::string hex32(const uint32_t value, const int length=8);
  static void float_to_word(const float f, OUT uint32_t word[]);
  static void double_to_word(const double f, OUT uint32_t word[]);
  static float word_to_float(const uint32_t word[]);
  static double word_to_double(const uint32_t word[]);

  static uint32_t find_instruction_by_name(const std::string & opname);
  static uint8_t find_register_by_name(const std::string & regname);
  static std::string get_register_name(const size_t reg_index);
  static std::string get_fp_register_name(const size_t reg_index);

  static std::string decode_instruction(const instruction_t instruction);
  static std::string decode_instruction(const uint32_t instruction);
  static uint32_t encode_instruction(const instruction_t instruction);
  static uint32_t assemble_instruction(const std::string & instruction_str);

  static instruction_t fill_instruction(const uint32_t instruction_code);
};

} /* namespace */
#endif
