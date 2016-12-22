/*
 * pfpga_info.c
 *
 * Copyright (C) 2006-2007 Tsuyoshi Hamada
 *                                All rights reserved.
 * 
 * No warranty is attached; 
 * I cannot take responsibility for errors or fitness for use.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXBD 8
#include "pg4.h"

int main(int argc, char* argv[])
{
  int devid=0;
  char info[1024];

  pg4_open(devid);
  pg4_get_pfpga_info(devid, info);
  pg4_close(devid);

  printf("%s\n", info);

  return 1;
}
