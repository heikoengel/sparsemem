--====================================================================--
-- tb_sparsemem.vhd
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

entity tb_sparsemem is

end entity tb_sparsemem;

architecture sim of tb_sparsemem is

  constant slv_uninit : std_logic_vector(C_SPARSEMEM_DATA_WIDTH-1 downto 0) :=
    std_logic_vector(C_SPARSEMEM_UNINITIZALIED);
  shared variable mem : SparseMem;

begin  -- architecture sim

  stimuli_p : process is
  begin  -- process stimuli_p

    report "Read from unitialized address";
    assert std_logic_vector(mem.get(0)) = slv_uninit report
      "Wrong output at 0, expected uninitialized" severity error;

    report "Write to addr 0 and read back";
    mem.set(0, 0);
    assert mem.get(0) = 0 report "Wrong output, expected 0" severity error;

    report "Write to 0x3000, 0x3001, 0x2fff and read back";
    mem.set(16#3000#, 14);
    mem.set(16#3001#, 15);
    mem.set(16#2FFF#, 16);
    assert mem.get(16#2FFF#) = 16 report
      "Wrong output at 0x2FFF, expected 16" severity error;
    assert mem.get(16#3000#) = 14 report
      "Wrong output at 0x3000, expected 14" severity error;
    assert mem.get(16#3001#) = 15 report
      "Wrong output at 0x3001, expected 15" severity error;

    report "Overwrite 0x3000 and read back";
    mem.set(16#3000#, 13);
    assert mem.get(16#3000#) = 13 report
      "Wrong output at 0x3000, expected 13" severity error;

    report "Clear memory";
    mem.clear;

    report "Read 0x2FFF - 0x3000, expecting uninitialized";
    assert std_logic_vector(mem.get(16#2FFF#)) = slv_uninit report
      "Wrong output at 0x2FFF, expected unitialized" severity error;
    assert std_logic_vector(mem.get(16#3000#)) = slv_uninit report
      "Wrong output at 0x3000, expected unitialized" severity error;
    assert std_logic_vector(mem.get(16#3001#)) = slv_uninit report
      "Wrong output at 0x3001, expected unitialized" severity error;

    std.env.stop;
    wait;
  end process stimuli_p;

end architecture sim;
