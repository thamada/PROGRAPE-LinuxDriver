#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*
 * ifpga_get_barinfo.c -- to get infomation of pci bar regsters
 *
 * Copyright (C) 2006-2007 Tsuyoshi Hamada
 *                                All rights reserved.
 * 
 * No warranty is attached; 
 * I cannot take responsibility for errors or fitness for use.
 *
 */

#include "pg4.h"

int main(int argc, char* argv[])
{
  int devid  = 0;
  int bar    = 0;
  int is_size = 0;
  unsigned long z = 0;

  if (argc < 3) {
    fprintf(stderr, "%s <devid> <bar_num> <adr=0/size=1>\n", argv[0]);
    exit(-1);
  }
  
  if(argc == 3) is_size = 0; else is_size = atoi(argv[3]);

  devid = atoi(argv[1]);
  bar   = atoi(argv[2]);
  
  pg4_open(devid);

  if(is_size)
    z = 0xffffffff & pg4_getbaseaddr_size(devid, bar);
  else
    z = 0xffffffff & pg4_getbaseaddr(devid, bar);

  printf("0x%08lx\n",z);
  pg4_close(devid);

  return 1;
}
