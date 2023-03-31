#ifndef MIPS_SIM_MEM_H
#define MIPS_SIM_MEM_H

#include <cstring>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <vector>

#define MEM_TEXT_REGION  0
#define MEM_DATA_REGION  1
#define MEM_STACK_REGION 2
#define MEM_KDATA_REGION 3
#define MEM_KTEXT_REGION 4

#define MEM_DATA_START  0x10010000
#define MEM_DATA_SIZE   0x00100000
#define MEM_TEXT_START  0x00400000
#define MEM_TEXT_SIZE   0x00100000
#define MEM_STACK_START 0x7ff00000
#define MEM_STACK_SIZE  0x00100000
#define MEM_KDATA_START 0x90000000
#define MEM_KDATA_SIZE  0x00100000
#define MEM_KTEXT_START 0x80000000
#define MEM_KTEXT_SIZE  0x00100000

namespace mips_sim
{

typedef struct {
    uint32_t start, size;
    uint8_t *mem;
} mem_region_t;


#define MEM_NREGIONS (sizeof(MEM_REGIONS)/sizeof(mem_region_t))

class Memory
{
  public:
    Memory( void );
    Memory( Memory const& ) = default;
    ~Memory( void );

    void lock( void );
    void unlock( void );

    /**
     * if address = 0, sets the new block contiguously in data memory
     * returns address of allocated block
     */
    uint32_t allocate_space(uint32_t size, uint32_t address = 0);
    uint32_t get_allocated_length(uint32_t address) const;

    bool address_aligned( uint32_t address ) const;
    uint32_t align_address( uint32_t address ) const;

    void mem_write_32(uint32_t address, uint32_t value);
    void mem_write_8(uint32_t address, uint8_t value);
    uint32_t mem_read_32(uint32_t address) const;
    uint8_t mem_read_8(uint32_t address) const;
    void print_memory( uint32_t start, uint32_t length,
                       std::ostream &out = std::cout ) const;

    void clear( void );

    /* these 2 functions allow to recover a specific state */
    void snapshot(int region);
    void reset(int region);

  private:

    mem_region_t get_memory_region(uint32_t address) const;

    bool locked; /* if true, only reserved space can be accessed */

    mem_region_t MEM_REGIONS[5] = {
      { MEM_TEXT_START, MEM_TEXT_SIZE, nullptr },
      { MEM_DATA_START, MEM_DATA_SIZE, nullptr },
      { MEM_STACK_START, MEM_STACK_SIZE, nullptr },
      { MEM_KDATA_START, MEM_KDATA_SIZE, nullptr },
      { MEM_KTEXT_START, MEM_KTEXT_SIZE, nullptr }
    };

    std::vector<mem_region_t> allocated_regions;

    mem_region_t MEM_SNAPSHOT[5] = {
      { MEM_TEXT_START, MEM_TEXT_SIZE, nullptr },
      { MEM_DATA_START, MEM_DATA_SIZE, nullptr },
      { MEM_STACK_START, MEM_STACK_SIZE, nullptr },
      { MEM_KDATA_START, MEM_KDATA_SIZE, nullptr },
      { MEM_KTEXT_START, MEM_KTEXT_SIZE, nullptr }
    };

};

} /* namespace */
#endif
