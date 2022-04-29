#!/bin/bash

rm -rf build && \
mkdir build && \
go-fuzz-build -o build/fuzzme.zip
