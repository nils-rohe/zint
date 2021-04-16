#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <cstdint>
#include <iostream>
#include "common.h"
#include "gs1.h"
#include <unistd.h>

int ZBarcode_Buffer(struct zint_symbol *symbol, int rotate_angle);

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size)
{
  return 0;
}
