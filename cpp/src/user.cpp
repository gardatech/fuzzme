#include <iostream>
#include <cstdio>
#include <cassert>
#include <cstdint>

#include <unistd.h>

#include "../include/funcs.hpp"

int main(int argc, char *argv[])
{
    std::cout << "Enter your data: " << std::endl;

    uint8_t buf[20];
    ssize_t len = read(0, buf, sizeof buf);

    ParseData(buf, len);

    return 0;
}
