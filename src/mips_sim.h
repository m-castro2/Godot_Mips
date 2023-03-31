#ifndef MIPS_SIM_H
#define MIPS_SIM_H
#include "assembler/mips_assembler.h"
#include "mem.h"
#include "utils.h"
#include "exception.h"
#include <iostream>
#include <fstream>

using namespace mips_sim;

uint32_t load_program(string program_filename)//, Memory & memory);
{
  ifstream prog(program_filename);
  size_t i = 0;
  uint32_t word;
  uint32_t words_read = 0;

  /* Open program file. */
  if (!prog) {
    cerr << "Error: Can't open program file " << program_filename << endl;
    exit(-1);
  }

  /* Read in the program. */
  i = 0;
  while (prog >> hex >> word) { //fscanf(prog, "%x\n", &word) != EOF) {
    cout << "Write " << Utils::hex32(word) << " to " << i << endl;
    //memory.mem_write_32(static_cast<uint32_t>(MEM_TEXT_START + i), word);
    i += 4;
    words_read++;
  }

  return words_read;
}

int run_batch(string input_file, int run_mode, int cpu_mode, ostream & outstream)
{
    return 1;
}
#endif//MIPS_SIM_H