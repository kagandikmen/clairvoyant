# clairvoyant

clairvoyant is:

- A RISC-V image super-resolution core built on [The Potato Processor](https://github.com/skordal/potato)
- My FPGA Ignite 2024 Hackathon project

## In Action

**Original Image**                     | **Image Enhanced w/ clairvoyant**
:-------------------------------------:|:-------------------------------------:
![birdie original](docs/birdie.png)    | ![birdie_enhanced](docs/birdie_enhanced.png)

### Closer Look*

**Original Image** | **Image Enhanced w/ clairvoyant**
:-------------------------------:|:-----------------------------------:
![birdie resized closer look](docs/birdie_resized_closerlook.png) | ![birdie enhanced closer look](docs/birdie_enhanced_closerlook.png)

\
\* Both images are cropped and resized with ImageMagick for a closer inspection of the results. ImageMagick was run with `-filter box` option for demonstration purposes. Otherwise, it uses its own image enhancement algorithm during resizing, which delivers a similar result to clairvoyant's but is purely software-based.

## Setup

Because the super-resolution functionality uses custom instructions, you need to use [clairvoyant's own custom RISC-V compiler](https://github.com/kagandikmen/clairvoyant-compiler), which is a slightly modified version of the [RISC-V GNU Compiler Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain).

## Current Status of the Project

Tests on real hardware (AMD Zynq 7020 SoC on PYNQ-Z1) are completed as of 2024-09-01.

### Next Steps

- Function libraries to facilitate access to the super-resolution functionality

## Contributing

Pull requests, suggestions, bug fixes etc. are all welcome.

## License

Both clairvoyant and The Potato Processor are released under BSD-3-Clause license. See [`LICENSE`](LICENSE) for details.

