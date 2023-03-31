#include "utils.h"
#include "exception.h"

#include <cmath>
#include <cstdio>
#include <cstring>
#include <cassert>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <fstream>

using namespace std;

namespace mips_sim
{
static size_t find_instruction(instruction_t instruction);

bool Utils::file_exists (const string & filename)
{
  ifstream f(filename.c_str());
  return f.good();
}

uint32_t Utils::address_align_4( uint32_t address )
{
  uint32_t padding = (address & 3)?(4 - (address & 3)):0;

  return address + padding;
}

string Utils::hex32(const uint32_t value, const int length)
{
  stringstream ss;
  ss << hex << setw(length) << setfill('0') << value;

  return ss.str();
}

void Utils::double_to_word(const double f, uint32_t word[])
{
  memcpy(word, &f, sizeof(double));
}

void Utils::float_to_word(const float f, uint32_t word[])
{
  memcpy(word, &f, sizeof(float));
}

float Utils::word_to_float(const uint32_t w[])
{
  float f;
  memcpy(&f, w, sizeof(float));
  return f;
}

double Utils::word_to_double(const uint32_t w[])
{
  double d;
  memcpy(&d, w, sizeof(double));
  return d;
}

static size_t find_instruction(instruction_t instruction)
{
  size_t instruction_index = UNDEF32;
  for (size_t i=0; i<(sizeof(instructions_def)/sizeof(instruction_format_t)); ++i)
  {
    if (instruction.opcode == instructions_def[i].opcode)
    {
      if (instruction.opcode == OP_RTYPE || instruction.opcode == OP_FTYPE)
      {
        /* BC1T & BC1F are special cases */
        if (instruction.opcode == OP_FTYPE && instruction.cop == 8)
        {
          if (instruction.rt == 0)
            instruction_index = Utils::find_instruction_by_name("bc1f");
          else if (instruction.rt == 1)
            instruction_index = Utils::find_instruction_by_name("bc1t");
          else
            assert(0);
          break;
        }
        else if (instruction.funct == instructions_def[i].subopcode)
        {
          instruction_index = i;
          break;
        }
      }
      else
      {
        instruction_index = i;
        break;
      }
    }
  }

  assert(instruction_index != UNDEF32);

  return instruction_index;
}

uint32_t Utils::find_instruction_by_name(const string & opname)
{
  uint32_t instruction_index = UNDEF32;
  string instruction_name = opname;

  if (opname.find_first_of('.') != string::npos)
  {
    instruction_name = opname.substr(0, opname.length()-1);
  }

  for (uint32_t i=0; i<(sizeof(instructions_def)/sizeof(instruction_format_t)); ++i)
  {
    if (instruction_name == instructions_def[i].opname)
    {
      instruction_index = i;
      break;
    }
  }

  if (instruction_index == UNDEF32)
  {
    throw Exception::e(PARSER_UNDEF_EXCEPTION, "Undefined instruction " + opname);
  }

  return instruction_index;
}

uint8_t Utils::find_register_by_name(const string & regname)
{
  uint8_t register_index = UNDEF8;
  for (uint8_t i=0; i<(sizeof(registers_def)/sizeof(register_format_t)); ++i)
  {
    if (regname == registers_def[i].regname_generic ||
        regname == registers_def[i].regname_int ||
        regname == registers_def[i].regname_fp)
    {
      register_index = i;
      break;
    }
  }

  if (register_index > 32)
  {
    throw Exception::e(PARSER_UNDEF_EXCEPTION, "Undefined register " + regname);
  }

  return register_index;
}

string Utils::get_register_name(const size_t reg_index)
{
  return registers_def[reg_index].regname_int;
}

string Utils::get_fp_register_name(const size_t reg_index)
{
  return registers_def[reg_index].regname_fp;
}

string Utils::decode_instruction(const instruction_t instruction)
{
  stringstream ss;
  size_t instruction_index;

  if (instruction.code == 0)
    return "nop";

  instruction_index = find_instruction(instruction);

  ss << instructions_def[instruction_index].opname;
  if (instructions_def[instruction_index].opname.find_last_of('.') != string::npos)
  {
    if (instruction.cop == 0)
      ss << "s";
    else if (instruction.cop == 1)
      ss << "d";
    else
      assert(0);
  }

  ss << " ";
  if (instructions_def[instruction_index].format == FORMAT_R)
  {
    if (instruction.funct == SUBOP_JR || instruction.funct == SUBOP_JALR)
    {
      ss << registers_def[instruction.rs].regname_int;
    }
    else if (instruction.funct == SUBOP_SLL || instruction.funct == SUBOP_SRL)
    {
      ss << registers_def[instruction.rd].regname_int << ", ";
      ss << registers_def[instruction.rt].regname_int << ", ";
      ss << static_cast<uint32_t>(instruction.shamt);
    }
    else if (instruction.funct != SUBOP_SYSCALL)
    {
      ss << registers_def[instruction.rd].regname_int << ", ";
      ss << registers_def[instruction.rs].regname_int << ", ";
      ss << registers_def[instruction.rt].regname_int;
    }
  }
  else if (instructions_def[instruction_index].format == FORMAT_F)
  {
    /* not bc1t / bc1f */
    if (instruction.cop != 8)
    {
      if (instructions_def[instruction_index].symbols_count == 3)
      {
        ss << registers_def[instruction.rs].regname_fp << ", ";
        ss << registers_def[instruction.rt].regname_fp;
      }
      else
      {
        ss << registers_def[instruction.rd].regname_fp << ", ";
        ss << registers_def[instruction.rs].regname_fp << ", ";
        ss << registers_def[instruction.rt].regname_fp;
      }
    }
    else
    {
      ss << "0x" << hex << instruction.addr_i;
    }
  }
  else if (instructions_def[instruction_index].format == FORMAT_J)
  {
    ss << "0x" << hex << instruction.addr_j;
  }
  else
  {
    if (instruction.opcode == OP_BNE || instruction.opcode == OP_BEQ)
    {
      ss << registers_def[instruction.rs].regname_int << ", ";
      ss << registers_def[instruction.rt].regname_int << ", ";
      ss << "0x" << hex << instruction.addr_i;
    }
    else
    {
      ss << registers_def[instruction.rt].regname_int << ", ";
      if (instruction.opcode == OP_LW || instruction.opcode == OP_SW ||
          instruction.opcode == OP_LB || instruction.opcode == OP_SB ||
          instruction.opcode == OP_LWC1 || instruction.opcode == OP_SWC1)
      {
        ss << "0x" << hex << instruction.addr_i << "(";
        ss << registers_def[instruction.rs].regname_int << ")";
      }
      else if (instruction.opcode == OP_LUI)
      {
        ss << "0x" << hex << instruction.addr_i;
      }
      else
      {
        ss << registers_def[instruction.rs].regname_int << ", ";
        ss << "0x" << hex << instruction.addr_i;
      }
    }
  }

  return ss.str();
}

string Utils::decode_instruction(const uint32_t instruction)
{
  return decode_instruction(fill_instruction(instruction));
}

uint32_t Utils::encode_instruction(const instruction_t instruction)
{
  uint32_t instcode = static_cast<uint32_t>(instruction.opcode << 26);
  if (instruction.opcode == OP_J || instruction.opcode == OP_JAL)
  {
    instcode |= instruction.addr_j;
  }
  else if (instruction.opcode == OP_FTYPE)
  {
    instcode |= static_cast<uint32_t>(instruction.cop << 21);
    instcode |= static_cast<uint32_t>(instruction.rs << 16);
    if (instruction.cop == 8)
    {
      instcode |= instruction.addr_i;
    }
    else
    {
      instcode |= static_cast<uint32_t>(instruction.rt << 11);
      instcode |= static_cast<uint32_t>(instruction.rd << 6);
      instcode |= instruction.funct;
    }
  }
  else
  {
    instcode |= static_cast<uint32_t>(instruction.rs << 21);
    instcode |= static_cast<uint32_t>(instruction.rt << 16);
    if (instruction.opcode != OP_RTYPE)
    {
      instcode |= instruction.addr_i;
    }
    else
    {
      instcode |= static_cast<uint32_t>(instruction.rd << 11);
      instcode |= static_cast<uint32_t>(instruction.shamt << 6);
      instcode |= instruction.funct;
    }
  }
  return instcode;
}

instruction_t Utils::fill_instruction(const uint32_t instruction_code)
{
  instruction_t instruction;

  instruction.code = instruction_code;
  instruction.opcode = instruction.code >> 26;

  instruction.fp_op = (instruction.opcode == OP_FTYPE);
  if (instruction.fp_op)
  {
    /* F format fields */
    instruction.cop = (instruction.code >> 21) & 0x1F;
    instruction.rs  = (instruction.code >> 16) & 0x1F;
    instruction.rt  = (instruction.code >> 11) & 0x1F;
    instruction.rd  = (instruction.code >> 6) & 0x1F;
  }
  else
  {
    /* R format fields */
    instruction.rs = (instruction.code >> 21) & 0x1F;
    instruction.rt = (instruction.code >> 16) & 0x1F;
    instruction.rd = (instruction.code >> 11) & 0x1F;
    instruction.shamt = (instruction.code >> 6) & 0x1F;
  }
  instruction.funct = instruction.code & 0x3F;
  /* I format fields */
  instruction.addr_i = instruction.code & 0xFFFF;
  /* J format fields */
  instruction.addr_j = instruction.code & 0x3FFFFFF;

  return instruction;
}

uint32_t Utils::assemble_instruction(const string & instruction_str)
{
  uint32_t instcode = 0;
  char instruction_cstr[100];
  char * tok;
  instruction_t instruction = {};

  strcpy(instruction_cstr, instruction_str.c_str());
  tok = strtok(instruction_cstr, " ");
  if (tok == nullptr)
    return 0;
  size_t instruction_index = find_instruction_by_name(tok);

  instruction_format_t instruction_def = instructions_def[instruction_index];

  instruction.opcode = static_cast<uint8_t>(instruction_def.opcode);
  if (instruction_def.format == FORMAT_R)
  {
    if (!strcmp(tok, "syscall"))
    {
      instruction.funct = SUBOP_SYSCALL;
    }
    else
    {
      instruction.funct = static_cast<uint8_t>(instruction_def.subopcode);

      if (instruction.funct == SUBOP_JR)
      {
        tok = strtok(nullptr, ", ");
        instruction.rs = find_register_by_name(tok);
      }
      else
      {
        tok = strtok(nullptr, ", ");
        instruction.rd = find_register_by_name(tok);
        tok = strtok(nullptr, ", ");
        instruction.rs = find_register_by_name(tok);
        tok = strtok(nullptr, ", ");
        instruction.rt = find_register_by_name(tok);
      }
    }
  }
  else if (instruction_def.format == FORMAT_I)
  {
    tok = strtok(nullptr, ",() ");
    instruction.rt = find_register_by_name(tok);
    tok = strtok(nullptr, ",() ");
    if (instruction.opcode == OP_LW || instruction.opcode == OP_SW ||
        instruction.opcode == OP_LB || instruction.opcode == OP_SB ||
        instruction.opcode == OP_LWC1 || instruction.opcode == OP_SWC1)
    {
      if (tok[1] == 'x')
        instruction.addr_i = static_cast<uint16_t>(strtol(tok, nullptr, 16));
      else
        instruction.addr_i = static_cast<uint16_t>(atoi(tok));
      tok = strtok(nullptr, ",() ");
      instruction.rs = find_register_by_name(tok);
    }
    else if (instruction.opcode == OP_LUI)
    {
      if (tok[1] == 'x')
        instruction.addr_i = static_cast<uint16_t>(strtol(tok, nullptr, 16));
      else
        instruction.addr_i = static_cast<uint16_t>(atoi(tok));
    }
    else
    {
      instruction.rs = find_register_by_name(tok);
      tok = strtok(nullptr, ",() ");
      if (tok[1] == 'x')
        instruction.addr_i = static_cast<uint16_t>(strtol(tok, nullptr, 16));
      else
        instruction.addr_i = static_cast<uint16_t>(atoi(tok));
    }

    if (instruction.opcode == OP_BEQ || instruction.opcode == OP_BNE)
    {
      /* swap Rs & Rt */
      uint8_t aux = instruction.rs;
      instruction.rs = instruction.rt;
      instruction.rt = aux;
    }
  }
  else if (instruction_def.format == FORMAT_J)
  {
    tok = strtok(nullptr, ", ");
    if (tok[1] == 'x')
      instruction.addr_j = static_cast<uint32_t>(strtol(tok, nullptr, 16));
    else
      instruction.addr_j = static_cast<uint32_t>(atoi(tok));
  }
  else if (instruction_def.format == FORMAT_F)
  {
       if (instruction_str.find_last_of('.') == strlen(tok)-2)
      {
        char precision = tok[strlen(tok)-1];
        if (precision == 's')
        {
          instruction.cop = 0;
        }
        else if (precision == 'd')
        {
          instruction.cop = 1;
        }
        else
        {
          throw Exception::e(PARSER_UNDEF_EXCEPTION, string("Unknown instruction ") + tok);
        }
      }

      switch (instruction_def.symbols_count)
      {
        case 4:
        {
          tok = strtok(nullptr, ", ");
          instruction.rd = find_register_by_name(tok);
          tok = strtok(nullptr, ", ");
          instruction.rs = find_register_by_name(tok);
          tok = strtok(nullptr, ", ");
          instruction.rt = find_register_by_name(tok);
          instruction.funct = static_cast<uint8_t>(instruction_def.subopcode);
        }
        break;
        case 3:
        {
          if (instruction_def.subopcode == SUBOP_FPMOV)
          {
            tok = strtok(nullptr, ", ");
            instruction.rd = find_register_by_name(tok);
            tok = strtok(nullptr, ", ");
            instruction.rt = find_register_by_name(tok);
          }
          else
          {
            tok = strtok(nullptr, ", ");
            instruction.rt = find_register_by_name(tok);
            tok = strtok(nullptr, ", ");
            instruction.rs = find_register_by_name(tok);
          }
          instruction.funct = static_cast<uint8_t>(instruction_def.subopcode);
        }
        break;
        case 2:
        {
          instruction.cop = 8;
          tok = strtok(nullptr, ", ");
          if (tok[1] == 'x')
            instruction.addr_i = static_cast<uint16_t>(strtol(tok, nullptr, 16));
          else
            instruction.addr_i = static_cast<uint16_t>(atoi(tok));
        }
        break;
        default:
          assert(0);
      }
  }

  instcode = Utils::encode_instruction(instruction);
  return instcode;
}

} /* namespace */
