#!/bin/bash
set -e
mkdir -p src/main/tools
cp logging.h src/main/tools/
clang++ -std=c++17 -I. build-runfiles.cc logging.cc -o build-runfiles
file build-runfiles
