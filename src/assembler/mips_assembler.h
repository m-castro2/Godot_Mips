#ifndef MIPS_SIM_ASSEMBLER_H
#define MIPS_SIM_ASSEMBLER_H


#include <string>
#include <memory>
#include "mem.h"

namespace mips_sim
{
int assemble_file(const char filename[], std::shared_ptr<mips_sim::Memory> memory);
void print_file(std::string output_file);

} /* namespace */
#endif
