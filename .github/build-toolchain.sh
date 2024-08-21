#!/bin/bash

cd /opt/
git clone https://github.com/kagandikmen/clairvoyant-compiler.git
mkdir cv32i
cd clairvoyant-compiler/
./configure --prefix=/opt/cv32i --with-arch=rv32i --with-abi=ilp32
make -j $(nproc)
export PATH=$PATH:/opt/cv32i/bin