# SparseMem

SparseMem is a resource-friendly VHDL model for large memory simulations.

With the default config, the model implements a 64 bit address range
with 32 bit storage elements:

* Address range: (63 downto 0)
* Data width   : (31 downto 0)

Different address and data width settings can be set by changing the
corresponding constants in the package.

Note that each address holds one data word of the configured width.
With the default config, there's a 32 bit word stored at each
address. Byte- or Word-addressing has to be implemented in the
instatiating entity if needed.

## Compilation

Example for Model/Questasim:
```
vcom pkg/sparsemem_pkg.vhd
```

## Usage

Embed `sparsemem_pkg.vhd` into your own design. An example is shown in `rtl/simple_ram.vhd`.


## Simulation

A basic testbench for the `sparsemem_pkg` package is in `tb/tb_sparsemem.vhd`.
