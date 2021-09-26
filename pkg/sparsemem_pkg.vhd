--====================================================================--
--! @file sparsemem_pkg.vhd
--====================================================================--
--
-- Copyright (C) 2021 Heiko Engel
--
-- This source file may be used and distributed without restriction provided
-- that this copyright statement is not removed from the file and that any
-- derivative work contains the original copyright notice and the associated
-- disclaimer.
--
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version.
--
-- This source is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
-- for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
--
-- Date: 2021-09-10
--
--====================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sparsemem_pkg is
  generic (
    G_ADDR_WIDTH : natural;             -- Memory address width
    G_DATA_WIDTH : natural);            -- Memory data width
  -----------------------------------------------------------------------------
  --! # SparseMem
  --! SparseMem is a resource-friendly VHDL model for large memory
  --! simulations.
  --!
  --! Address and data width are configurable with package generics.
  --!
  --! Note that each address holds one data word of the configured
  --! width. A finer-grained Byte- or Word-addressing has to be
  --! implemented in the instatiating entity if needed.
  -----------------------------------------------------------------------------

  --! @brief protected SparseMem type with read/write access
  --! functions/procedures.
  type SparseMem is protected

    ---------------------------------------------------------------------------
    --! @brief Get the memory content at [addr].
    --! @param addr memory address as unsigned value
    --! @return memory content at [addr] as unsigned value or
    --! C_SPARSEMEM_UNINITIZALIED when [addr] is not initialized.
    ---------------------------------------------------------------------------
    impure function get (
      addr : unsigned)
      return unsigned;

    ---------------------------------------------------------------------------
    --! @brief Set the memory content at [addr] to [data].
    --! @param addr memory address as unsigned value
    --! @param data data to be written as unsigned value
    ---------------------------------------------------------------------------
    procedure set (
      addr : in unsigned;
      data : in unsigned);

    ---------------------------------------------------------------------------
    --! @brief Clear all entries of the memory
    ---------------------------------------------------------------------------
    procedure clear;

    ---------------------------------------------------------------------------
    --! @brief Get the memory content at [addr].
    --! @param addr memory address as (32 bit) signed integer
    --! @return memory content at [addr] as 32 bit unsigned or
    --! C_SPARSEMEM_UNINITIZALIED when [addr] is not initialized.
    --!
    --! Note that integer data types can only cover 32 bit signed
    --! values. This overload cannot be used for address offsets
    --! greater than 2**31.
    ---------------------------------------------------------------------------
    impure function get (
      addr : integer)
      return unsigned;

    ---------------------------------------------------------------------------
    --! @brief Set the memory content at [addr] to [data].
    --! @param addr memory address as (32 bit) signed integer
    --! @param data data to be written as (32 bit) signed integer. Negative
    --! values will set the memory address to the 32 bit two's complement.
    --!
    --! Note that integer data types can only cover 32 bit signed
    --! values. This overload cannot be used for address and data
    --! values greater than 2**31.
    ---------------------------------------------------------------------------
    procedure set (
      addr : integer;
      data : integer);

    ---------------------------------------------------------------------------
    --! @brief Get the memory content at [addr].
    --! @param addr memory address as std_logic_vector
    --! @return memory content at [addr] as std_logic_vector or
    --! C_SPARSEMEM_UNINITIZALIED when [addr] is not initialized.
    ---------------------------------------------------------------------------
    impure function get (
      addr : std_logic_vector)
      return std_logic_vector;

    ---------------------------------------------------------------------------
    --! @brief Set the memory content at [addr] to [data].
    --! @param addr memory address as std_logic_vector value
    --! @param data data to be written as std_logic_vector
    ---------------------------------------------------------------------------
    procedure set (
      addr : std_logic_vector;
      data : std_logic_vector);

  end protected;

  --! @brief value to return for reads to uninitialized memory locations
  constant C_SPARSEMEM_UNINITIZALIED : unsigned(G_DATA_WIDTH-1 downto 0) := (others => 'X');

end package sparsemem_pkg;

package body sparsemem_pkg is

  type SparseMem is protected body

  type MemEntry;
  type MemPtr is access MemEntry;

  -- Each list entry consists of an address, the data value and a
  -- pointer to the next list entry.
  type MemEntry is record
    data      : unsigned(G_DATA_WIDTH-1 downto 0);
    addr      : unsigned(G_ADDR_WIDTH-1 downto 0);
    nextEntry : MemPtr;
  end record MemEntry;

  variable root : MemPtr := null;

  -----------------------------------------------------------------------------
  -- Return the memory content at [addr] or C_SPARSEMEM_UNINITIZALIED
  -- when [addr] is not yet initialized.
  -----------------------------------------------------------------------------
  impure function get (
    addr : unsigned)
    return unsigned is
    variable entry : MemPtr := root;
  begin
    -- iterate over all list entries
    while entry /= null loop
      if entry.addr = addr then
        -- found requested address, return data
        return entry.data;
      else
        -- address does not match, continue with next list item
        entry := entry.nextEntry;
      end if;
    end loop;
    -- no matching list entry found, this address is uninitialized
    return C_SPARSEMEM_UNINITIZALIED;
  end function get;

  -----------------------------------------------------------------------------
  -- Set the memory content at [addr] to [data].
  -----------------------------------------------------------------------------
  procedure set (
    addr : unsigned;
    data : unsigned) is
    variable entry     : MemPtr := root;
    variable newEntry  : MemPtr;
    variable nextEntry : MemPtr;
  begin

    if entry = null then
      -- no entry in the list, add addr/data as the first entry
      newEntry      := new MemEntry;
      newEntry.data := data;
      newEntry.addr := addr;
      root          := newEntry;
      return;
    end if;

    -- iterate over all list items
    while entry /= null loop

      if entry.addr = addr then
        -- existing entry, replace the old data with the new data
        entry.data := data;
        return;
      end if;

      if entry.addr < addr then
        -- current address is lower that the target address
        if entry.nextEntry = null then
          -- next entry doesn't exists -> append a new entry at the
          -- end of the list
          newEntry        := new MemEntry;
          newEntry.data   := data;
          newEntry.addr   := addr;
          entry.nextEntry := newEntry;
          return;
        else
          -- next entry exists
          if entry.nextEntry.addr > addr then
            -- next entry address is higher than the target address ->
            -- insert a new entry here.
            newEntry           := new MemEntry;
            newEntry.data      := data;
            newEntry.addr      := addr;
            newEntry.nextEntry := entry.nextEntry;  -- link to next
            entry.nextEntry    := newEntry;         -- insert the new here
            return;
          else
            -- next entry address is not higher than the target
            -- address -> continue with the next entry
            entry := entry.nextEntry;
          end if;
        end if;
      end if;
    end loop;
  end procedure set;


  -----------------------------------------------------------------------------
  -- Clear all entries of the memory.
  -----------------------------------------------------------------------------
  procedure clear is
    variable entry : MemPtr := root;
  begin
    -- iterate until list is empty
    while root /= null loop
      -- remove the first entry, then move the root pointer to the
      -- next entry.
      entry := root;
      root  := entry.nextEntry;
      deallocate(entry);
    end loop;
  end procedure clear;


  -------------------------------------------------------------------------------
  -- Integer overloads for get/set
  -------------------------------------------------------------------------------
  impure function get (
    addr : integer)
    return unsigned is
  begin
    return get(to_unsigned(addr, G_ADDR_WIDTH));
  end function get;

  procedure set (
    addr : integer;
    data : integer) is
  begin
    set(to_unsigned(addr, G_ADDR_WIDTH), to_unsigned(data, G_DATA_WIDTH));
  end procedure set;

  -------------------------------------------------------------------------------
  -- std_logic_vector overloads for get/set
  -------------------------------------------------------------------------------
  impure function get (
    addr : std_logic_vector)
    return std_logic_vector is
  begin
    return std_logic_vector(get(unsigned(addr)));
  end function get;

  procedure set (
    addr : std_logic_vector;
    data : std_logic_vector) is
  begin
    set(unsigned(addr), unsigned(data));
  end procedure set;

end protected body;

end package body sparsemem_pkg;
