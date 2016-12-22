// Time-stamp: "2006-12-07 13:35:12 hamada"
// Copyright (c) 2006 by Tsuyoshi Hamada, All rights reserved.

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
  int i;

  if(argc > 1){
    n = atoi(argv[1]);
  }
  printf("n = %d\n",n);

  pg4_open(devid);
  bar1 = pg4_get_bar1ptr(devid);
  printf("BAR0: %lx\n",pg4_getbaseaddr(devid,0));
  printf("BAR1: %lx\n",pg4_getbaseaddr(devid,1));

  for(i = 0; i < n; i++) {
    unsigned int x;
    x = pg4_readbase1(devid, i);
    printf("%x : %x\n",i,x);
  }


  return 0;
}
