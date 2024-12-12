#!/bin/bash

cp cr_sim.tcl.in coyote/scripts
mkdir build_hw
cd build_hw
/usr/bin/cmake ..
make project
make sim
