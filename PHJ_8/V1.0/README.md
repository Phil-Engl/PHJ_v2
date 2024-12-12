# Line-rate AXI Stream Compression Core
Clone with `--recurse-submodules` to also clone the Coyote submodule or execute `git submodule update --init` after cloning.

Simulation:
```Bash
source /opt/sgrt/cli/enable/vivado
./sim_setup.sh
vivado build_hw/sim/test.xpr
```

Thereafter, start simulation.

The input generation can be changed in tst/c_gen.svh and assertions may be added to tst/c_scb.svh to check correctness of results.

Compression IP core generated from Vitis Libraries https://github.com/Xilinx/Vitis_Libraries/tree/main/data_compression/L1/tests/gzipc_static_8KB by executing `make run CSYNTH=1 DEVICE=u55c` and taking the vhdl sources from `./gzip_compress_test.prj/sol1/syn/vhdl/`.

## Related projects
This repo is used as part of the storage deduplication system in https://github.com/fpgasystems/dedup and implements an arbiter for a GZip compression core to be able to compress multiple pages in parallel.