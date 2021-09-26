# SparseMem

SparseMem is a resource-friendly VHDL model for large memory simulations.

The package is parametrized with generic and needs to be defined when
used, e.g.:

```vhdl
  package my_sparsemem is new work.sparsemem_pkg
    generic map(
        G_ADDR_WIDTH => 32,
        G_DATA_WIDTH => 32);

-- [...]

  variable mem : work.my_sparsemem.SparseMem;
  -- [...]
```

Note that each address holds one data word of the configured width.
With the above example config, there's a 32 bit word stored at each
address. Byte- or Word-addressing has to be implemented in the
instatiating entity if needed.

## Compilation

Example for Model/Questasim:
```
vcom pkg/sparsemem_pkg.vhd
```

## Usage

Use `sparsemem_pkg.vhd` in your own design and create a `new` package
with the address/data widths needed. An example is shown in
`models/simple_ram.vhd`.


## Simulation

A basic testbench for the `sparsemem_pkg` package is in `tb/tb_sparsemem.vhd`.
