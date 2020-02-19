#!/bin/bash

echo "start install nim"

git clone https://github.com/nim-lang/Nim.git
cd Nim && sh build_all.sh

export NIM=/home/travis/build/nim-lang-cn/website/Nim/bin
export NIMBLE_DIR=/home/travis/.nimble
export PATH=$PATH:$NIM:$NIMBLE

source ~/.bashrc 

nim -v
