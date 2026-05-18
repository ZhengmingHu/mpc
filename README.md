# MPC — High-Performance Multiport Cache

MPC is a configurable, high-performance multiport cache RTL design written in SystemVerilog. It supports up to three independent upstream request channels and routes them through a banked cache architecture with a crossbar interconnect, enabling parallel access while maintaining cache coherency.

## Architecture

```
                  ┌─────────┐
   channel_0 ────▶│         │     ┌──────────────────┐
   channel_1 ────▶│  XBAR   │────▶│  Bank 0  ┌──────┐│
   channel_2 ────▶│         │     │  Bank 1  │ HTU  ││──▶ Memory
                   └─────────┘     │  Bank 2  │  RC  ││      Interface
                                   │  Bank 3  │  MC  ││      Arbiter
                                   └──────────┴──────┘│
                                   └──────────────────┘
```

### Key Components

| Module | Description |
|--------|-------------|
| **XBAR** | Crossbar interconnect routing requests from 3 channels to multiple banks; uses age-based arbitration when requests contend for the same bank |
| **HTU** (Hit/Tag Unit) | Tag array, meta array, reference counter, and replacer — determines cache hit/miss |
| **RC** (Read Cache) | Data array backed by SRAM, serves read hits |
| **MC** (Miss Cache) | Handles cache misses, manages refill FSM for RAE/WAE operations |
| **ISU** (Issue Unit) | Credit manager, LSQ (load-store queue), ROB (reorder buffer), refill buffer, and inflight tracking |
| **Write Buffer** | Buffers pending write operations |
| **Memory Interface Arbiter** | N-to-1 arbiter serializing access to external main memory |
| **Slice** | Top-level wrapper instantiating all submodules with configurable parameters |

### Configurable Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ways` | 4 | Set associativity |
| `sets` | 64 | Number of cache sets |
| `banks` | 4 | Number of independent banks |
| `clWidth` | 256 | Cacheline width (bits) |
| `clWordWidth` | 128 | Data word width (bits) |
| `addrWidth` | 32 | Address width (bits) |
| `robSize` | 8 | Reorder buffer depth |
| `lsqSize` | 32 | Load-store queue depth |
| `wbufSize` | 16 | Write buffer depth |
| `kobSize` | 64 | KO bank size |
| `mainDelay` | 95 | Main memory access latency (cycles) |

## Directory Structure

```
mpc/
├── rtl/                  # SystemVerilog RTL source
│   ├── mpc.sv            # Core MPC module
│   ├── mpc_wrapper.sv    # Configurable top-level wrapper
│   ├── xbar/             # Crossbar interconnect
│   ├── htu/              # Hit/tag unit
│   ├── rc/               # Read cache (data array)
│   ├── mc/               # Miss cache
│   ├── isu/              # Issue unit
│   ├── wbuf/             # Write buffer
│   ├── mem/              # Memory interface + arbiter
│   ├── slice/            # Slice wrapper
│   ├── lib/              # Shared library modules (arbiter, mux, SRAM, etc.)
│   └── include/          # Types and definitions
├── vcs/                  # VCS testbenches (per-module verification)
├── verilator/            # Verilator-based difftest environment
├── cachesim/             # C-based cache simulator for performance analysis
└── filelist/             # File lists for synthesis/simulation
```

## Supported Operations

- **Load/Store** with configurable data sizes: byte, half, word, double, quad
- **Cache management**: RAE (Read-and-Evict), WAE (Write-and-Evict), Write-Back
- **Refill** operations for both load and store misses

## Verification

- **VCS testbenches**: Per-module unit tests in `vcs/`
- **Verilator difftest**: Full-system verification against a reference model in `verilator/`
- **Cachesim**: Standalone C-based cache simulator for performance and MPKI analysis

## Benchmarks

- CoreMark
- Microbench
- MCbench
- NPU benchmarks

## Quick Start

1. Source the setup script: `source setup.sh`
2. Build with VCS or Verilator using the file lists in `filelist/`
3. Run individual module testbenches from `vcs/`

## License

Proprietary. All rights reserved.
