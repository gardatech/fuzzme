#include <iostream>
#include <cstdio>
#include "../include/funcs.hpp"

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
    ParseData(Data, Size);
    return 0;
}
