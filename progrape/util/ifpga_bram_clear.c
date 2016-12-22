/*
 * ifpga_bram_clear.c
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
#include "pg4.h"

//#define NMAX (0x1<<10) // 4KB
//#define NMAX (0x1<<11) // 8KB
//#define NMAX (0x1<<12) // 16KB
//#define NMAX (0x1<<13) // 32KB
#define NMAX (0x1<<14) // 64KB

unsigned int* ptr;
unsigned int* bar1;

int main(int argc,char *argv[])
{
  int devid = 0;
  int n = NMAX;
  int val = 0x1234567;
  int i;

  if(argc > 1){
    n = atoi(argv[1]);
  }
  if(argc > 2){
    val = atoi(argv[2]);
  }

  printf("n = %d\n",n);
  printf("filled by %x\n",val);

  pg4_open(devid);
  bar1 = pg4_get_bar1ptr(devid);
  printf("BAR0: %lx\n",pg4_getbaseaddr(devid,0));
  printf("BAR1: %lx\n",pg4_getbaseaddr(devid,1));

  for(i = 0; i < n; i++) {
    pg4_writebase1(devid, i, val);
  }

  return 0;
}
