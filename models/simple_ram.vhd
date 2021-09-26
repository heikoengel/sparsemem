--====================================================================--
-- simple_ram.vhd
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
-- Date: 2021-09-26
--
--====================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_ram is

  generic (
    G_RESET_POL  : std_logic             := '1';   -- Reset polarity
    G_ADDR_WIDTH : natural range 2 to 64 := 30);   -- address width
  port (
    I_CLK   : in  std_logic;            -- clock
    I_ARST  : in  std_logic;            -- async reset
    I_ADDR  : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);  -- address input
    I_WDATA : in  std_logic_vector(31 downto 0);   -- write data input
    I_WE    : in  std_logic;            -- write-enable
    I_RE    : in  std_logic;            -- read-enable
    O_RDATA : out std_logic_vector(31 downto 0));  -- read data output

end entity simple_ram;

architecture sim of simple_ram is

  package sparsemem_32x32 is
      new work.sparsemem_pkg generic map(G_ADDR_WIDTH => G_ADDR_WIDTH, G_DATA_WIDTH => 32);

begin  -- architecture sim

  MEM_INTF_P : process (I_CLK, I_ARST) is
    variable mem : sparsemem_32x32.SparseMem;
  begin  -- process MEM_INTF_P
    if I_ARST = G_RESET_POL then
      O_RDATA <= (others => '0');
    elsif rising_edge(I_CLK) then       -- rising clock edge
      if I_RE = '1' then
        O_RDATA <= std_logic_vector(mem.get(unsigned(I_ADDR)));
      end if;
      if I_WE = '1' then
        mem.set(unsigned(I_ADDR), unsigned(I_WDATA));
      end if;
    end if;
  end process MEM_INTF_P;

end architecture sim;
