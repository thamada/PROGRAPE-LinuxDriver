// Time-stamp: "2006-12-07 19:19:07 hamada"
// Copyright (c) 2006 by Tsuyoshi Hamada, All rights reserved.

#include <stdio.h>
#include <stdlib.h>
#include "pg4.h"

unsigned int* ptr;
unsigned int* bar1;

int main(int argc,char *argv[])
{
  int devid = 0;
  int i;

  pg4_open(devid);
  bar1 = pg4_get_bar1ptr(devid);
  printf("BAR0: %lx\n",pg4_getbaseaddr(devid,0));
  printf("BAR1: %lx\n",pg4_getbaseaddr(devid,1));

  puts("clear DMA_CTRL register(0x2C).");
  WriteBase0(devid, 0x2C,   0); // 0x2C : DMA_CTRL ... clear

  puts("clear INT_STAT register(0x10).");
  WriteBase0(devid, 0x10,   0); // 0x14 : INT_MASK  [1:Enable INT/ 0:Disable INT]

  puts("clear INT_MASK register(0x14).");
  WriteBase0(devid, 0x14,   0); // 0x14 : INT_MASK  [1:Enable INT/ 0:Disable INT]

  pg4_DMAcheck(devid);

  return 0;
}
