#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <cstdint>
#include <iostream>
#include "common.h"
#include "gs1.h"
#include <unistd.h>
#include <fuzzer/FuzzedDataProvider.h>

int ZBarcode_Buffer(struct zint_symbol *symbol, int rotate_angle);

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size)
{
  if (Size < 4)
    return 0;


  FuzzedDataProvider fdp( Data, Size );


  int sym_number = fdp.ConsumeIntegral<int>();
  if (sym_number < 0){
    return 0;
  }

  struct zint_symbol *my_symbol;
  my_symbol = ZBarcode_Create();
  my_symbol->symbology= sym_number;
  //std::cout << "symbology= " << my_symbol->symbology << "\n";
  std::string input = fdp.ConsumeRandomLengthString();
  //std::cout << "input= " << input << "\n";
  const unsigned char* input_cstr = (const unsigned char *) input.c_str();
  ZBarcode_Encode(my_symbol, input_cstr, input.length());
  ZBarcode_Delete(my_symbol);

  return 0;
}
