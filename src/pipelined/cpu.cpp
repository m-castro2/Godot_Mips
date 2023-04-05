#include "cpu.h"
#include "../utils.h"
#include "../exception.h"

#include <cassert>
#include <sstream>
#include <iomanip>

using namespace std;
namespace mips_sim
{

Cpu::Cpu(shared_ptr<Memory> _memory, shared_ptr<ControlUnit> _control_unit)
  : memory(_memory), control_unit(_control_unit)
{
  loaded_instructions.reserve(400);
  loaded_instructions.push_back(0); /* start with a nop instruction */

  /* set default status */
  status["fp-add-delay"] = DEFAULT_FP_ADD_DELAY;
  status["mult-delay"]   = DEFAULT_MULT_DELAY;
  status["div-delay"]    = DEFAULT_DIV_DELAY;
  
  /* reset CPU but no memory */
  reset(false, false);
}

Cpu::~Cpu() {}

bool Cpu::is_ready( void ) const
{
  return ready;
}

void Cpu::reset( bool reset_data_memory, bool reset_text_memory )
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

const map<string, int> Cpu::get_status() const
{
  return status;
}

bool Cpu::set_status(map<string, int> new_status, bool merge)
{
  if (!merge)
  {
    if (new_status.size() != status.size() && !merge)
      return false;
  
    status = new_status;
  }
  else
  {
    for (const auto& entry : new_status)
    {
      status[entry.first] = entry.second;
    }
  }
    
  return true;
}

uint32_t Cpu::alu_compute_subop(uint32_t alu_input_a, uint32_t alu_input_b,
                                uint8_t shift_amount, uint32_t alu_op)
{
  uint32_t alu_output = 0xFFFFFFFF;

  switch(alu_op)
  {
    case SUBOP_SYSCALL:
      /* Syscall */
      syscall(gpr[2]); // call with reg $v0
      break;
    case SUBOP_SLL:
      alu_output = alu_input_b << shift_amount; break;
    case SUBOP_SRL:
      alu_output = alu_input_b >> shift_amount; break;
    case SUBOP_AND:
      alu_output = alu_input_a & alu_input_b; break;
    case SUBOP_OR:
      alu_output = alu_input_a | alu_input_b; break;
    case SUBOP_XOR:
      alu_output = alu_input_a ^ alu_input_b; break;
    case SUBOP_NOR:
      alu_output = ~(alu_input_a | alu_input_b); break;
    case SUBOP_JR:
    case SUBOP_JALR:
      alu_output = alu_input_a; break;
    case SUBOP_SLT:
      alu_output = (static_cast<int32_t>(alu_input_a) < static_cast<int32_t>(alu_input_b))
                   ?1:0;
      break;
    case SUBOP_SLTU:
      alu_output = (alu_input_a < alu_input_b)?1:0; break;
    case SUBOP_ADD:
      alu_output = static_cast<uint32_t>(static_cast<int32_t>(alu_input_a) +
                                         static_cast<int32_t>(alu_input_b));
      break;
    case SUBOP_ADDU:
      alu_output = alu_input_a + alu_input_b; break;
    case SUBOP_SUB:
      alu_output = static_cast<uint32_t>(static_cast<int>(alu_input_a) -
                                         static_cast<int32_t>(alu_input_b));
      break;
    case SUBOP_SUBU:
      alu_output = alu_input_a - alu_input_b; break;
    case SUBOP_MULT:
    {
      uint64_t v = static_cast<uint64_t>(static_cast<int32_t>(alu_input_a) *
                                         static_cast<int32_t>(alu_input_b));
      //TODO: Update HI/LO after stall
      HI = (v >> 32) & 0xFFFFFFFF;
      LO = v & 0xFFFFFFFF;
      execution_stall = status["mult-delay"];
    }
      break;
    case SUBOP_MULTU:
    {
      uint64_t v = static_cast<uint64_t>(alu_input_a * alu_input_b);
      //TODO: Update HI/LO after stall
      HI = (v >> 32) & 0xFFFFFFFF;
      LO = v & 0xFFFFFFFF;
      execution_stall = status["mult-delay"];
    }
      break;
    case SUBOP_DIV:
    {
      //TODO: Update HI/LO after stall
      /* HI = div, LO = mod */
      HI = static_cast<uint32_t>(static_cast<int32_t>(alu_input_a) / static_cast<int32_t>(alu_input_b));
      LO = static_cast<uint32_t>(static_cast<int32_t>(alu_input_a) % static_cast<int32_t>(alu_input_b));
      execution_stall = status["div-delay"];
    }
      break;
    case SUBOP_DIVU:
    {
      //TODO: Update HI/LO after stall
      /* HI = div, LO = mod */
      HI = alu_input_a / alu_input_b;
      LO = alu_input_a % alu_input_b;
      execution_stall = status["div-delay"];
    }
      break;
    default:
      throw Exception::e(CPU_UNDEF_EXCEPTION, "Undefined ALU operation ", alu_op);
  }

  return alu_output;
}

uint32_t Cpu::alu_compute_op(uint32_t alu_input_a, uint32_t alu_input_b, uint32_t alu_op) const
{
  uint32_t alu_output = 0xFFFFFFFF;
  switch(alu_op)
  {
    case OP_ADDI:
      alu_output = static_cast<uint32_t>(static_cast<int>(alu_input_a) + static_cast<int>(alu_input_b));
      break;
    case OP_ADDIU:
      alu_output = alu_input_a + alu_input_b;
      break;
    case OP_SLTI:
      alu_output = (static_cast<int>(alu_input_a) < static_cast<int>(alu_input_b))?1:0;
      break;
    case OP_SLTIU:
      alu_output = (alu_input_a < alu_input_b)?1:0;
      break;
    case OP_ANDI:
      alu_output = alu_input_a & alu_input_b;
      break;
    case OP_ORI:
      alu_output = alu_input_a | alu_input_b;
      break;
    case OP_XORI:
      alu_output = alu_input_a ^ alu_input_b;
      break;
    case OP_LUI:
      alu_output = alu_input_b<<16;
      break;
    default:
      throw Exception::e(CPU_UNDEF_EXCEPTION, "Undefined ALU operation ", alu_op);
  }

  return alu_output;
}

void Cpu::syscall( uint32_t value )
{
  switch(value)
  {
    case 1:
      /* print_integer $a0 */
      cout << "[SYSCALL] " << gpr[Utils::find_register_by_name("$a0")] << endl;
      break;
    case 2:
      /* print_float $f12 */
      cout << "[SYSCALL] " << Utils::word_to_float(&fpr[12]) << endl;
      break;
    case 3:
      /* print_double $f12 */
      cout << "[SYSCALL] " << Utils::word_to_double(&fpr[12]) << endl;
      break;
    case 4:
      {
        /* print_string $a0 */
        uint32_t address = gpr[Utils::find_register_by_name("$a0")];
        uint32_t alloc_length = memory->get_allocated_length(address);
        stringstream ss;
        for (uint32_t i=0; i<alloc_length; ++i)
        {
          ss << static_cast<char>(memory->mem_read_8(address + i));
        }
        cout << "[SYSCALL] " << ss.str() << endl;
      }
      break;
    case 5:
      {
        /* read_integer -> $v0 */
        //TODO: Fails in CLI mode
        int readvalue;
        cout << "[SYSCALL] Input an integer value: ";
        cin >> readvalue;
        gpr[Utils::find_register_by_name("$v0")] = static_cast<uint32_t>(readvalue);
      }
      break;
    case 6:
      {
        /* read_float -> $f0 */
        //TODO: Fails in CLI mode
        float readvalue;
        cout << "[SYSCALL] Input a float value: ";
        cin >> readvalue;
        Utils::float_to_word(readvalue, &fpr[Utils::find_register_by_name("$f0")]);
      }
      break;
    case 7:
      {
        /* read_double -> $f0 */
        //TODO: Fails in CLI mode
        double readvalue;
        cout << "[SYSCALL] Input a double value: ";
        cin >> readvalue;
        Utils::double_to_word(readvalue, &fpr[Utils::find_register_by_name("$f0")]);
      }
      break;
    case 8:
      {
        /* read_string -> $a0 of up to $a1 chars ma*/
        //TODO: Fails in CLI mode
        string readvalue;
        uint32_t address = gpr[Utils::find_register_by_name("$a0")];
        uint32_t max_length = gpr[Utils::find_register_by_name("$a1")];
        uint32_t str_len;

        cout << "[SYSCALL] Input a string value [max_length=" << max_length << "]: ";
        cin >> readvalue;
        str_len = static_cast<uint32_t>(readvalue.length());

        if (str_len > max_length)
          str_len = max_length;

        for (uint32_t i=0; i<str_len; i++)
        {
          memory->mem_write_8(address + i, static_cast<uint8_t>(readvalue[i]));
        }

        //gpr[Utils::find_register_by_name("$a1")] = static_cast<uint32_t>(str_len);
      }
      break;
    case 9:
      {
        /* allocate $a0 Bytes in data memory. Returns address in $v0 */
        uint32_t block_size = gpr[Utils::find_register_by_name("$a0")];
        uint32_t address;

        /* align block size with memory */
        block_size = memory->align_address(block_size);

        address = memory->allocate_space(block_size);

        cout << "[SYSCALL] " << block_size << " Bytes allocated at " << Utils::hex32(address) << endl;

        gpr[Utils::find_register_by_name("$v0")] = address;
      }
      break;
    case 10:
      //TODO: Send stop signal or something
      /* exit program */
      cout << "[SYSCALL] Program done." << endl;
      ready = false;
      break;
    case 41:
      {
        /* random_integer $a0(seed) --> $a0 */
        srand(gpr[Utils::find_register_by_name("$a0")]);
        int rvalue = rand();
        cout << "[SYSCALL] Random integer: " << rvalue << endl;
        gpr[Utils::find_register_by_name("$a0")] = static_cast<uint32_t>(rvalue);
      }
      break;
    case 42:
      {
        /* random_integer < $a1, $a0(seed) --> $a0 */
        int rvalue, ulimit;
        srand(gpr[Utils::find_register_by_name("$a0")]);
        ulimit = static_cast<int>(gpr[Utils::find_register_by_name("$a1")]);
        rvalue = rand() % ulimit;
        cout << "[SYSCALL] Random integer below " << ulimit << ": " << rvalue << endl;
        gpr[Utils::find_register_by_name("$a0")] = static_cast<uint32_t>(rvalue);
      }
      break;
    case 43:
      {
        /* random_float $a0(seed) --> $f0 */
        srand(gpr[Utils::find_register_by_name("$a0")]);
        float rvalue = rand() / 0x7FFFFFFF;
        cout << "[SYSCALL] Random float: " << rvalue << endl;
        Utils::float_to_word(rvalue, &fpr[Utils::find_register_by_name("$f0")]);
      }
      break;
    case 44:
      {
        /* random_double $a0(seed) --> $f0 */
        srand(gpr[Utils::find_register_by_name("$a0")]);
        double rvalue = rand() / 0x7FFFFFFF;
        cout << "[SYSCALL] Random float: " << rvalue << endl;
        Utils::double_to_word(rvalue, &fpr[Utils::find_register_by_name("$f0")]);
      }
      break;
    default:
      throw Exception::e(CPU_SYSCALL_EXCEPTION, "Undefined syscall", value);
  }
}

string Cpu::register_str(size_t reg_id, bool fp, bool show_value, bool show_double) const
{
  string regname;
  uint32_t regvalue[2];

  regname = fp?registers_def[reg_id].regname_fp:registers_def[reg_id].regname_int;
  regvalue[0] = fp?fpr[reg_id]:gpr[reg_id];
  if (show_double)
    regvalue[1] = fpr[reg_id+1];

  stringstream ss;
  ss << setw(4) << setfill(' ') << regname;
  if (show_value && !fp)
    ss << setw(10) << static_cast<int>(regvalue[0]);
  ss << " [" << Utils::hex32(regvalue[0]) << "]";
  if (show_value && fp)
  {
    ss << setw(9) << scientific << setprecision(2) << Utils::word_to_float(regvalue);
    if (show_double)
      ss << " / " << setw(9) << scientific << setprecision(2) << Utils::word_to_double(regvalue);
    else
      ss << setw(12) << " ";
  }

  return ss.str();
}

void Cpu::print_registers( ostream &out ) const
{
  out << setw(134) << setfill('-') << " " << endl;
  for (size_t i=0; i<16; ++i)
  {
    out << "|" << register_str(i, false, true, false);
    out << " |" << register_str(i+8, false, true, false);
    out << " | " << register_str(i, true, true, !(i%2));
    out << " | " << register_str(i+8, true, true, !(i%2));
    out << " |" << endl;
  }
  out << setw(134) << setfill('-') << " " << endl;
}

void Cpu::print_int_registers( ostream &out ) const
{
  out << setw(110) << setfill('-') << " " << endl;
  for (size_t i=0; i<8; ++i)
  {
    out << "|" << register_str(i, false, true, false);
    out << " |" << register_str(i+8, false, true, false);
    out << " |" << register_str(i+16, false, true, false);
    out << " |" << register_str(i+24, false, true, false);
    out << " |" << endl;
  }
  out << setw(110) << setfill('-') << " " << endl;
}

void Cpu::print_fp_registers( ostream &out ) const
{
  out << setw(80) << setfill('-') << " " << endl;
  for (size_t i=0; i<16; ++i)
  {
    out << "| " << register_str(i, true, true, !(i%2));
    out << " | " << register_str(i+8, true, true, !(i%2));
    out << " |" << endl;
  }
  out << setw(80) << setfill('-') << " " << endl;
}

uint32_t Cpu::read_register( size_t reg_index) const
{
  assert(reg_index < 32);

  return gpr[reg_index];
}

uint32_t Cpu::read_fp_register( size_t reg_index) const
{
  assert(reg_index < 32);

  return fpr[reg_index];
}

void Cpu::write_register( size_t reg_index, uint32_t value)
{
  if (reg_index == 0)
    throw Exception::e(CPU_REG_EXCEPTION, "Cannot write register $0");
  assert(reg_index < 32);

  gpr[reg_index] = value;
}

void Cpu::write_fp_register( size_t reg_index, uint32_t value)
{
  assert(reg_index < 32);

  fpr[reg_index] = value;
}

float Cpu::read_register_f( size_t reg_index ) const
{
  assert(reg_index < 32);

  return Utils::word_to_float(&fpr[reg_index]);
}

uint32_t Cpu::read_special_register(int id) const {
  switch (id)
  {
    case SPECIAL_PC:
      return PC;
    case SPECIAL_HI:
      return HI;
    case SPECIAL_LO:
      return LO;
  }
  return UNDEF32;
}

void Cpu::write_register_f( size_t reg_index, float value )
{
  assert(reg_index < 32);

  Utils::float_to_word(value, &fpr[reg_index]);
}

double Cpu::read_register_d( size_t reg_index ) const
{
  assert(reg_index < 32);

  return Utils::word_to_double(&fpr[reg_index]);
}

void Cpu::write_register_d( size_t reg_index, double value )
{
  if (reg_index % 2 == 1)
    throw Exception::e(CPU_REG_EXCEPTION, "Invalid register for double precision");

  assert(reg_index < 32);

  Utils::double_to_word(value, &fpr[reg_index]);
}

bool Cpu::next_cycle( ostream &out )
{
  cycle++;

  out << "------------------------------------------ cycle "
      << dec << cycle << endl;

  return true;
}

uint32_t Cpu::get_cycle( void ) const
{
  return cycle;
}

bool Cpu::run_to_cycle( uint32_t target_cycle, ostream &out)
{
  assert(target_cycle >= 0);

  ostream nullostream(nullptr);

  /* reset CPU and memory */
  reset( true, true );

  if (target_cycle > 0)
  {
    while(cycle < (target_cycle-1) && ready)
    {
      if (!next_cycle(nullostream))
        return false;
    }
    next_cycle(out);
  }
  return true;
}

void Cpu::print_diagram( ostream &out ) const
{
  out << "Diagram not implemented" << endl;
}

const vector<uint32_t> & Cpu::get_loaded_instructions()
{
  return loaded_instructions;
}

} /* namespace */
