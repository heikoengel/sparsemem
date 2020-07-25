--====================================================================--
-- simple_ram.vhd
--====================================================================--
--
-- Copyright (C) 2020 Heiko Engel
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
-- Date: 2020-07-25
--
--====================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sparsemem_pkg.all;

entity simple_ram is

  generic (
    G_ADDR_WITH : natural range 2 to 64 := 30);    -- address width
  port (
    I_CLK   : in  std_logic;            -- clock
    I_ARST  : in  std_logic;            -- async reset
    I_ADDR  : in  std_logic_vector(G_ADDR_WITH-1 downto 0);  -- address input
    I_WDATA : in  std_logic_vector(31 downto 0);   -- write data input
    I_WE    : in  std_logic;            -- write-enable
    I_RE    : in  std_logic;            -- read-enable
    O_RDATA : out std_logic_vector(31 downto 0));  -- read data output

end entity simple_ram;

architecture sim of simple_ram is

begin  -- architecture sim

  MEM_INTF_P : process (I_CLK, I_ARST) is
    variable mem : SparseMem;
  begin  -- process MEM_INTF_P
    if I_ARST = '1' then
      O_RDATA <= (others => '0');
    elsif rising_edge(I_CLK) then          -- rising clock edge
      if I_RE = '1' then
        O_RDATA <= std_logic_vector(mem.get(unsigned(I_ADDR)));
      end if;
      if I_WE = '1' then
        mem.set(unsigned(I_ADDR), unsigned(I_WDATA));
      end if;
    end if;
  end process MEM_INTF_P;

end architecture sim;
