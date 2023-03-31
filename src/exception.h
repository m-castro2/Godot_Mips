#ifndef MIPS_SIM_EXCEPTION_H
#define MIPS_SIM_EXCEPTION_H

/* bits [6..31] - Exception type */
/* bits [0..5] - Specific type */
#define MEMORY_EXCEPTION          64
#define MEMORY_ALLOC_EXCEPTION    65
#define MEMORY_LOCK_EXCEPTION     66
#define MEMORY_ACCESS_EXCEPTION   67
#define MEMORY_ALIGN_EXCEPTION    68

#define PARSER_EXCEPTION          128
#define PARSER_UNDEF_EXCEPTION    129
#define PARSER_DUPLABEL_EXCEPTION 130
#define PARSER_NOLABEL_EXCEPTION  131

#define CTRL_EXCEPTION           192
#define CTRL_UNDEF_EXCEPTION     193
#define CTRL_BAD_JUMP_EXCEPTION  194

#define CPU_EXCEPTION            256
#define CPU_UNIMPL_EXCEPTION     257
#define CPU_UNDEF_EXCEPTION      258
#define CPU_SYSCALL_EXCEPTION    259
#define CPU_REG_EXCEPTION        260

namespace mips_sim
{

extern uint32_t err_v;
extern int err_no;
extern std::string err_msg;

class Exception
{
public:
  static int e(int exception, std::string message, uint32_t value = 0)
  {
    err_no = exception;
    err_msg = message;
    err_v = value;

    return err_no;
  }
};

} /* namespace */
#endif
