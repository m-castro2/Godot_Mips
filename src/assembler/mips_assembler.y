%{
  #include "../utils.h"
  #include "../mem.h"
  #include "../exception.h"
  #include "mips_assembler.h"

  #include <iostream>
  #include <sstream>
  #include <cstring>
  #include <cassert>
  #include <vector>
  #include <memory>
  #include <algorithm>

  #define MEM_TYPE_WORD   1
  #define MEM_TYPE_FLOAT  2
  #define MEM_TYPE_DOUBLE 3
  #define MEM_TYPE_STRING 4
  #define MEM_TYPE_SPACE  5

  using namespace std;
  using namespace mips_sim;

  int yyparse();
  int assemble_file(FILE *fp, shared_ptr<Memory> memory);

  extern "C"
  {
    #include "mips_parser_lex.hpp"

    int yylex( void );

    void yyerror(const char *str)
    {
      cerr << "error: " << str << endl;
    }

    int yywrap()
    {
      return 1;
    }
  }

  struct Label
  {
    std::string name;
    uint32_t line;
  };

  struct Instruction
  {
    uint32_t instcode;
    uint32_t line;
    bool has_branch_label;
    bool relative;
    int has_data_label; /* 1: high, 2: low */
    std::string label;
  };

  struct Memsection
  {
    string label;
    int type; /* 1: word, 2: float, 3: double, 4: asccii, 5: space */
    uint32_t position;
    uint32_t length;
    vector<string> values;
  };

  static vector<string> values;
  static vector<Label> labels;
  static vector<Instruction> instructions;
  static vector<Memsection> memsections;

  static uint32_t line;
  static uint32_t mem_pos;

%}

%union {
  uint32_t ival;
  char * tval;
}

%destructor { free ($$); } <tval>

%token COMMA
%token SYSCALL
%token TEXT_SECTION
%token DATA_SECTION
%token LAOPCODE
%token LUIOPCODE
%token OBRACKET
%token CBRACKET
%token <tval> DATATAG
%token <tval> LABELTAG
%token <tval> LABELJUMP
%token <ival> REGISTER
%token <ival> FREGISTER
%token <tval> IOPCODE
%token <tval> JOPCODE
%token <tval> ROPCODE
%token <tval> FOPCODE
%token <tval> F2ROPCODE
%token <tval> FBROPCODE
%token <tval> IMOPCODE
%token <tval> FMOPCODE
%token <ival> INTVALUE
%token <tval> FLOATVALUE
%token <tval> TEXTVALUE
%token <ival> EOL

%start program

%%

program: TEXT_SECTION instructions_sequence DATA_SECTION data_sequence
  | DATA_SECTION data_sequence TEXT_SECTION instructions_sequence
  | TEXT_SECTION instructions_sequence;

instructions_sequence:
    instructions_sequence instruction
    {
      line++;
    }
    |
    instruction
    {
      line++;
    };

instruction:
		ROPCODE REGISTER COMMA REGISTER COMMA REGISTER
		{
      stringstream ss;
      ss << $1 << " $" << $2 << ", $" << $4 << ", $" << $6;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
		}
  | FOPCODE FREGISTER COMMA FREGISTER COMMA FREGISTER
    {
      stringstream ss;
      ss << $1 << " $" << $2 << ", $" << $4 << ", $" << $6;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
    }
  | F2ROPCODE FREGISTER COMMA FREGISTER
    {
      stringstream ss;
      ss << $1 << " $" << $2 << ", $" << $4;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
    }
  | FBROPCODE LABELJUMP
    {
      stringstream ss;
      ss << $1 << " " << $2;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, true, true, 0, $2});
      free($1); free($2);
    }
	|	IOPCODE REGISTER COMMA REGISTER COMMA INTVALUE
		{
      stringstream ss;
      ss << $1 << " $" << $2 << ", $" << $4 << ", " << $6;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
		}
  |	IOPCODE REGISTER COMMA REGISTER COMMA LABELJUMP
		{
      stringstream ss;
      ss << $1 << " $" << $2 << ", $" << $4 << ", " << $6;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, true, true, 0, $6});
      free($1); free($6);
		}
  |	LUIOPCODE REGISTER COMMA INTVALUE
		{
      stringstream ss;
      ss << "lui $" << $2 << ", " << $4;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
		}
	|	IMOPCODE REGISTER COMMA INTVALUE OBRACKET REGISTER CBRACKET
		{
      stringstream ss;
      ss << $1 << " $" << $2 << ", " << $4 << "($" << $6 << ")";
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
		}
  |	FMOPCODE FREGISTER COMMA INTVALUE OBRACKET REGISTER CBRACKET
    {
      stringstream ss;
      ss << $1 << " $" << $2 << ", " << $4 << "($" << $6 << ")";
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
    }
	|	JOPCODE LABELJUMP
		{
      stringstream ss;
      ss << $1 << " " << $2;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, true, false, 0, $2});
      free($1); free($2);
		}
  |	LAOPCODE REGISTER COMMA LABELJUMP
		{
      /* decompose in lui & ori */
      stringstream ss1, ss2;
      ss1 << "lui $" << $2 << ", 0";
      ss2 << "ori $" << $2 << ", $" << $2 << ", 0";
      uint32_t instcode = Utils::assemble_instruction(ss1.str());
      instructions.push_back({instcode, line, false, false, 1, $4});
      line++;
      instcode = Utils::assemble_instruction(ss2.str());
      instructions.push_back({instcode, line, false, false, 2, $4});
      free($4);
		}
  |	JOPCODE REGISTER
		{
      stringstream ss;
      ss << $1 << " $" << $2;
      uint32_t instcode = Utils::assemble_instruction(ss.str());
      instructions.push_back({instcode, line, false, false, 0, ""});
      free($1);
		}
  | SYSCALL
    {
      uint32_t instcode = Utils::assemble_instruction("syscall");
      instructions.push_back({instcode, line, false, false, 0, ""});
    }
  | LABELTAG
    {
      labels.push_back({$1, line});
      line--;
      free($1);
    }
	;

  data_sequence: data_sequence data_line | data_line;

  data_line:
      LABELTAG DATATAG array_values
      {
        uint32_t last_pos = mem_pos;
        int type = 0;
        reverse(values.begin(), values.end());
        if (!strcmp($2, "word"))
        {
          type = MEM_TYPE_WORD;
          mem_pos += values.size() * 4;
        }
        else if (!strcmp($2, "float"))
        {
          type = MEM_TYPE_FLOAT;
          mem_pos += values.size() * 4;
        }
        else if (!strcmp($2, "double"))
        {
          type = MEM_TYPE_DOUBLE;
          mem_pos += values.size() * 8;
        }
        else if (!strcmp($2, "asciiz"))
        {
          type = MEM_TYPE_STRING;
          assert(values.size() == 1);
          /* round up to word size */
          mem_pos += Utils::address_align_4(values[0].length());
        }
        else if (!strcmp($2, "space"))
        {
          type = MEM_TYPE_SPACE;
          assert(values.size() == 1);
          mem_pos += stoi(values[0]);
        }
        memsections.push_back({$1, type, last_pos, mem_pos-last_pos, values});
        values.clear();
      }
      ;

  array_values:
      FLOATVALUE
      {
        values.push_back($1);
      }
      | FLOATVALUE COMMA array_values
      {
        values.push_back($1);
      }
      | INTVALUE
      {
        values.push_back(to_string($1));
      }
      | INTVALUE COMMA array_values
      {
        values.push_back(to_string($1));
      }
      | TEXTVALUE
      {
        string s = $1;
        /* remove quotes */
        assert(s[0] == s[s.length()-1] && s[0] == '\"');
        values.push_back(s.substr(1, s.length()-2));
      }
%%

namespace mips_sim
{

/******************************************************************************/

static void setup_memory(shared_ptr<Memory> memory)
{
  uint32_t next_address;
  uint32_t alloc_address;
  uint32_t words_to_mem[2];

  memory->lock();
  /* process data memory sections */
  next_address = MEM_DATA_START;
  for (Memsection memsection : memsections)
  {
    alloc_address = memory->allocate_space(memsection.length);
    assert(alloc_address == next_address);

    /* copy data */
    for (string s : memsection.values)
    {
      if (memsection.type == MEM_TYPE_WORD)
      {
        memory->mem_write_32(next_address,
                              stoi(s));
        next_address += 4;
      }
      else if (memsection.type == MEM_TYPE_FLOAT)
      {
        Utils::float_to_word(stof(s), words_to_mem);
        memory->mem_write_32(next_address,
                             words_to_mem[0]);
        next_address += 4;
      }
      else if (memsection.type == MEM_TYPE_DOUBLE)
      {
        Utils::double_to_word(stod(s), words_to_mem);
        memory->mem_write_32(next_address,
                             words_to_mem[0]);
        memory->mem_write_32(next_address + 4,
                             words_to_mem[1]);
        next_address += 8;
      }
      else if (memsection.type == MEM_TYPE_STRING)
      {
        uint32_t writevalue;
        uint32_t str_len = s.length();

        for (uint32_t i=0; i<str_len; i++)
        {
          memory->mem_write_8(next_address + i, static_cast<uint8_t>(s[i]));
        }

        next_address += memsection.length;
      }
      else if (memsection.type == MEM_TYPE_SPACE)
      {
        next_address += stoi(s);
      }
    }
  }

  /* process code memory */
  alloc_address = memory->allocate_space(static_cast<uint32_t>((instructions.size()+2) * 4),
                                         MEM_TEXT_START);
  assert(alloc_address == MEM_TEXT_START);

  next_address = MEM_TEXT_START;
  for (Instruction instruction : instructions)
  {
    /* Read in the program. */
    memory->mem_write_32(next_address, instruction.instcode);
    next_address += 4;
  }
}

int assemble_file(const char filename[], shared_ptr<Memory> memory)
{
  int retval = 1;

  /* reset stuff */
  memory->clear();
  values.clear();
  labels.clear();
  instructions.clear();
  memsections.clear();
  line = 0;
  mem_pos = 0;

  /* parse file */
  if (Utils::file_exists(filename))
  {
    yyin = fopen(filename, "r");
    retval = yyparse();
    fclose(yyin);

    yylex_destroy();
  }

  /* process file */
  if (retval)
  {
    return 1;
  }
  /* rebuild instructions */
  for (Instruction & instruction : instructions)
  {
    if (instruction.has_branch_label)
    {
      bool label_found = false;
      for (Label label : labels)
      {
        if (!instruction.label.compare(label.name))
        {
          if (label_found)
            throw Exception::e(PARSER_DUPLABEL_EXCEPTION, "Dublicated label '"+label.name + "'");
          label_found = true;
          if (instruction.relative)
          {
            int rel_branch = label.line - instruction.line - 1;
            instruction.instcode |= (static_cast<uint32_t>(rel_branch) & 0xFFFF);
          }
          else
          {
            uint32_t abs_branch = MEM_TEXT_START/4 + static_cast<uint32_t>(label.line);
            instruction.instcode |= (abs_branch & 0x3FFFFFF);
          }
        }
      }
      if (!label_found)
        throw Exception::e(PARSER_NOLABEL_EXCEPTION, "Undefined label '"+instruction.label + "'");
    }
    else if (instruction.has_data_label > 0)
    {
      assert(instruction.has_data_label <= 2);
      bool label_found = false;
      for (Memsection mem_section : memsections)
      {
        if (!instruction.label.compare(mem_section.label))
        {
          if (label_found)
            throw Exception::e(PARSER_DUPLABEL_EXCEPTION, "Dublicated label '"+mem_section.label + "'");
          label_found = true;
          uint32_t address = MEM_DATA_START + mem_section.position;
          if (instruction.has_data_label == 1)
            instruction.instcode |= (address >> 16 & 0xFFFF);
          else
            instruction.instcode |= (address & 0xFFFF);
        }
      }
      if (!label_found)
        throw Exception::e(PARSER_NOLABEL_EXCEPTION, "Undefined label '"+instruction.label + "'");
    }
  }

  setup_memory(memory);

  return 0;
}

void print_file(std::string output_file)
{
  for (Instruction & instruction : instructions)
  {
    cout << Utils::hex32(instruction.instcode)
         << " # " << Utils::decode_instruction(instruction.instcode)
         << endl;
  }
}

} /* namespace */
