#include "mem.h"
#include "utils.h"
#include "exception.h"

#include <stdio.h>
#include <cassert>
#include <sstream>
#include <iomanip>

namespace mips_sim
{

using namespace std;

Memory::Memory( void )
{
  locked = false;

  /* initialize memory */
  for (size_t i = 0; i < MEM_NREGIONS; i++) {
    MEM_REGIONS[i].mem = static_cast<uint8_t *>(malloc(MEM_REGIONS[i].size));
    memset(MEM_REGIONS[i].mem, 0, MEM_REGIONS[i].size);
  }

  /* reserve for stack */
  allocate_space(MEM_STACK_SIZE, MEM_STACK_START);
}

void Memory::clear( void )
{
  for (size_t r=0; r<MEM_NREGIONS; r++)
  {
    assert(MEM_REGIONS[r].mem != nullptr);
    memset(MEM_REGIONS[r].mem, 0, MEM_REGIONS[r].size);
    if (MEM_SNAPSHOT[r].mem != nullptr)
    {
      free(MEM_SNAPSHOT[r].mem);
      MEM_SNAPSHOT[r].mem = nullptr;
    }
  }
  allocated_regions.clear();
}

void Memory::snapshot(int r)
{
  if (MEM_SNAPSHOT[r].mem == nullptr)
    MEM_SNAPSHOT[r].mem = static_cast<uint8_t *>(malloc(MEM_SNAPSHOT[r].size));

  memcpy(MEM_SNAPSHOT[r].mem, MEM_REGIONS[r].mem, MEM_SNAPSHOT[r].size);
}

void Memory::reset(int r)
{
  assert(MEM_SNAPSHOT[r].mem != nullptr);

  memcpy(MEM_REGIONS[r].mem, MEM_SNAPSHOT[r].mem, MEM_SNAPSHOT[r].size);
}

Memory::~Memory()
{
  /* initialize memory */
  for (size_t i = 0; i < MEM_NREGIONS; i++) {
    if (MEM_REGIONS[i].mem)
    {
      free(MEM_REGIONS[i].mem);
      MEM_REGIONS[i].mem = nullptr;
    }

    if (MEM_SNAPSHOT[i].mem)
    {
      free(MEM_SNAPSHOT[i].mem);
      MEM_SNAPSHOT[i].mem = nullptr;
    }
  }
}

void Memory::lock() { locked = true; }

void Memory::unlock() { locked = false; }

uint32_t Memory::allocate_space(uint32_t size, uint32_t address)
{
  mem_region_t mem_region;
  uint32_t alloc_address = address;

  if (alloc_address)
  {
    bool locked_state = locked;

    /* check for collision with another block */
    for (mem_region_t region : allocated_regions)
    {
      if (alloc_address >= region.start &&
          alloc_address < (region.start + region.size))
      {
        throw Exception::e(MEMORY_ALLOC_EXCEPTION,
                           "Memory allocation overlaps another region",
                           alloc_address);
      }
    }
    /* temporary unlock memory for allocation */
    locked = false;
    mem_region = get_memory_region(address);
    locked = locked_state;
  }
  else
  {
    /* select next free space */
    mem_region = MEM_REGIONS[MEM_DATA_REGION];
    alloc_address = MEM_DATA_START;

    /* select last free address */
    for (mem_region_t region : allocated_regions)
    {
      if (get_memory_region(region.start).start == MEM_DATA_START)
      {
        uint32_t end_address = region.start + region.size;
        alloc_address = (alloc_address < end_address)?end_address:alloc_address;
      }
    }
  }

  if ((alloc_address + size) <= (mem_region.start + mem_region.size))
  {
    allocated_regions.push_back({alloc_address, size, nullptr});
  }
  else
  {
    stringstream ss;
    ss << "Memory allocation beyond the region limit: Address "
       << Utils::hex32(alloc_address) << " / size " << size << " Bytes";
    throw Exception::e(MEMORY_ALLOC_EXCEPTION, ss.str());
  }

  return alloc_address;
}

uint32_t Memory::get_allocated_length(uint32_t address) const
{
  for (mem_region_t block : allocated_regions)
  {
    if (address >= block.start && address < block.start + block.size)
    {
      return block.start + block.size - address;
    }
  }

  throw Exception::e(MEMORY_ALLOC_EXCEPTION,
                     "Unallocated memory address",
                      address);
}

bool Memory::address_aligned( uint32_t address ) const
{
  return Utils::address_align_4(address) == address;
}

uint32_t Memory::align_address( uint32_t address ) const
{
  return Utils::address_align_4(address);
}

mem_region_t Memory::get_memory_region(uint32_t address) const
{
  bool valid_address = !locked;

  if (locked)
  {
    /* check if address is valid */
    for (mem_region_t region : allocated_regions)
    {
      if (address >= region.start &&
          address < (region.start + region.size))
      {
        valid_address = true;
        break;
      }
    }
  }


  if (valid_address)
  {
    for (size_t i = 0; i < MEM_NREGIONS; i++)
    {
      if (address >= MEM_REGIONS[i].start &&
              address < (MEM_REGIONS[i].start + MEM_REGIONS[i].size))
      {
        return MEM_REGIONS[i];
      }
    }
  }
  else
  {
    throw Exception::e(MEMORY_ACCESS_EXCEPTION,
                       "Invalid memory address",
                        address);
  }

  throw Exception::e(MEMORY_LOCK_EXCEPTION,
                     "Access to invalid memory space",
                      address);
}

uint32_t Memory::mem_read_32(uint32_t address) const
{
  if (address & 0x3)
    throw Exception::e(MEMORY_ALIGN_EXCEPTION,
                       "Memory address is not aligned",
                       address);

  mem_region_t mem_region = get_memory_region(address);
  uint32_t offset = address - mem_region.start;

  uint32_t v = static_cast<uint32_t>
           ((mem_region.mem[offset+3] << 24) |
            (mem_region.mem[offset+2] << 16) |
            (mem_region.mem[offset+1] <<  8) |
            (mem_region.mem[offset+0] <<  0));

  return v;
}

uint8_t Memory::mem_read_8(uint32_t address) const

{
  mem_region_t mem_region = get_memory_region(address);
  uint32_t offset = address - mem_region.start;

  uint8_t v = mem_region.mem[offset];

  return v;
}

void Memory::mem_write_32(uint32_t address, uint32_t value)
{
  if (address & 0x3)
    throw Exception::e(MEMORY_ALIGN_EXCEPTION,
                       "Memory address is not aligned",
                       address);

  mem_region_t mem_region = get_memory_region(address);
  uint32_t offset = address - mem_region.start;

  mem_region.mem[offset+3] = (value >> 24) & 0xFF;
  mem_region.mem[offset+2] = (value >> 16) & 0xFF;
  mem_region.mem[offset+1] = (value >>  8) & 0xFF;
  mem_region.mem[offset+0] = (value >>  0) & 0xFF;
}

void Memory::mem_write_8(uint32_t address, uint8_t value)
{
  mem_region_t mem_region = get_memory_region(address);
  uint32_t offset = address - mem_region.start;

  mem_region.mem[offset] = value;
}

void Memory::print_memory( uint32_t start, uint32_t length, ostream &out ) const
{
  for (size_t i = 0; i < MEM_NREGIONS; i++)
  if (start >= MEM_REGIONS[i].start &&
      start+length <= (MEM_REGIONS[i].start + MEM_REGIONS[i].size))
  {
    try
    {
      for (uint32_t mem_addr=start; mem_addr<start+length; mem_addr+=16)
      {
        uint32_t word = mem_read_32(mem_addr);
        out << setw(8) << setfill(' ') << Utils::hex32(mem_addr) << " [" << Utils::hex32(word) << "]";
        word = mem_read_32(mem_addr + 4);
        out << " [" << Utils::hex32(word) << "]";
        word = mem_read_32(mem_addr + 8);
        out << " [" << Utils::hex32(word) << "]";
        word = mem_read_32(mem_addr + 12);
        out << " [" << Utils::hex32(word) << "]" << endl;
      }
    }
    catch (int)
    {
      out << endl;
      /* ignore */
    }
    return;
  }

  stringstream ss;
  ss << "Read access to invalid memory space: Start "
     << Utils::hex32(start) << " / size " << length << " Bytes";
  throw Exception::e(MEMORY_ALLOC_EXCEPTION, ss.str());
}

} /* namespace */
