# clairvoyant

clairvoyant is:

- an enhanced version of [The Potato Processor](https://github.com/skordal/potato) with an image super-resolution accelerator
- my FPGA Ignite 2024 Hackathon project

## Setup

Because the super-resolution functionality uses custom instructions, you need to use [clairvoyant's own custom RISC-V compiler](https://github.com/kagandikmen/clairvoyant-compiler), which is a slightly modified version of the [RISC-V GNU Compiler Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain).

## Current Status of the Project

Hardware description, custom instructions and the tests are considered implemented and fully functional as of 2024-08-18.  

## Known Issues

- Yet no function libraries enabling the use of the super-resolution functionality are implemented as of 2024-08-18.

## Contributing

Pull requests, suggestions, bug fixes etc. are all welcome.

## License

Both my own work and The Potato Processor are released under BSD-3-Clause license. No copyright infringement intended. See [`LICENSE`](LICENSE) for details.

