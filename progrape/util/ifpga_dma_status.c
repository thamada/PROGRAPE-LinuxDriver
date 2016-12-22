// Time-stamp: "2006-12-07 19:19:22 hamada"
// Copyright (c) 2006 by Tsuyoshi Hamada, All rights reserved.

#include <stdio.h>
#include <stdlib.h>
#include "pg4.h"

unsigned int* ptr;
unsigned int* bar1;

int main(int argc,char *argv[])
{
  int devid = 0;

  pg4_open(devid);
  bar1 = pg4_get_bar1ptr(devid);
  printf("BAR0: %lx\n",pg4_getbaseaddr(devid,0));
  printf("BAR1: %lx\n",pg4_getbaseaddr(devid,1));

  pg4_DMAcheck(devid);

  return 0;
}
