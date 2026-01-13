# Simple NoC (Network-on-Chip)

## Overview

This project is a **simple Network-on-Chip (NoC)** implementation designed for **learning and teaching purposes**.
It implements a **4×4 mesh topology** with a **deterministic XY routing algorithm**, focusing on clarity and modularity rather than performance optimization.

The NoC is written in **SystemVerilog** and verified using **Synopsys VCS 2018**.

## Features

- **4×4 Mesh Topology**
  - 16 routers with 16 nodes arranged in a 2D mesh
  - Each router connects to up to 5 ports: Local, North, South, East, West
- **XY Routing Algorithm**
- **Simple Router Microarchitecture**
  - Allocator
  - Buffer
  - Switch (Crossbar switch)

![](https://cdn.jsdelivr.net/gh/Knight112357/PicGo@main/img/Simple-NoC/Router_Architecture.png)

## Project Structure

```
Simple-NoC
├── filelist
│   ├── common_filelist.mk  # Common source files shared by multiple modules
│   └── *_filelist.mk       # Module- or test-specific file lists
├── testbench
│   ├── *_TB.sv             # SystemVerilog testbench files for verification 
│   └── utils               # Utilities for testbenches
├── vsrc
│   ├── include             # Global definitions and etc.
│   ├── interface           # SystemVerilog interfaces used for module communication
│   ├── node
│   ├── router
│   │   ├── allocator       # Arbitration and allocation logic for I/O resources
│   │   ├── buffer         
│   │   ├── switch          # Crossbar awitch
│   │   ├── Router.sv       # Top-level router module
│   │   └── Routing_Unit.sv # Routing computation unit (XY routing algorithm).
│   └── NOC.sv
├── .gitignore
├── Makefile
└── README.md
```

## Simulation

The simulation environment supports different **TOP-level modules**: `NOC`, `Router`, `Routing_Unit`, `Buffer_Unit`, `FIFO`. The default buffer implementation is **FIFO**. Use the `TOP` variable to select the module to be compiled and simulated.

Make sure **Synopsys VCS 2018** and **Verdi** are properly installed and configured.

```bash
# compile only
make compile TOP=NOC

# compile and simulate
make sim TOP=NOC

# build outputs are generated under:
# build/$TOP/

# waveform debugging
make verdi TOP=NOC

# clean
# clean build files for a specific TOP
make clean TOP=NOC
# clean all build and simulation files
make clean-all
```