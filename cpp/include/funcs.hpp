#pragma once

#include <cassert>
#include <cstdio>
#include <cstring>
#include <vector>
#include <cstdint>

#include <unistd.h>



bool UB_x_plus1_smaller_than_x(int x)
{
    return x + 1 < x;
}

void just_abort()
{
    abort();
}

void failed_assert()
{
    assert(false);
}

void extra_process(uint8_t *buf, ssize_t len)
{
    int x = *(int *)buf;
    bool result = UB_x_plus1_smaller_than_x(x);
    (void)result;
    if ((buf[1] | 0x20) == 'a')
    {
        int arr[4] = {0};
        int val = arr[17] + arr[-17];
        (void)val;
    }
}

bool is_data_valid__leak(uint8_t *buf, ssize_t len)
{
    const int req_size = 2;
    if (len < req_size) return false;

    char *data = (char *)malloc(sizeof(char) * 123);
    if (!data) return false;

    memcpy(data, buf, req_size);

    if (data[1] % 3 == 2) {
        return true; // forgot to free here
    }

    free(data);
    return false;
}


void ParseData(const uint8_t *in_buf, ssize_t len)
{
    if (len < 1 || len > 200) return;
    auto data = std::vector<uint8_t>(in_buf, in_buf + len);
    auto buf = data.data();

    if (buf[0] == 'F')
    {
        extra_process(buf, len);
    }

    if (buf[1] == 'U')
    {
        unsigned long index = *(unsigned long *)(buf + 5);
        buf[index] = buf[index + 1];
    }

    if (buf[2] == 'Z')
    {
        just_abort();
    }

    if (buf[3] == 'Z')
    {
        failed_assert();
    }

    if (buf[4] == 'M')
    {
        if (is_data_valid__leak(buf, len)) {
            return;
        }
        int (*shellcode)() = (int (*)()) & buf[5];
        int x = shellcode();
        (void)x;
    }

    if (buf[5] == 'E')
    {
        unsigned int n = *(unsigned int *)buf;
        unsigned int sum = 0;
        for (unsigned char i = 0; i < n; i++)
        {
            sum += i;
        }
        (void)sum;
    }
}
