// Time-stamp: <2006-09-04 13:41:34 hamada>
// by T.Hamada
//
// <2006-09-04 13:33:47 hamada>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "pg4.h"

void rst(int devid, int d, int msec)
{
  d = 0xff & d;
  WriteBase0(devid, 0x4, d);
  usleep(msec*1000);
}

int main(int argc, char* argv[])
{
  int devid=0;
  int i;

  pg4_open(devid);
  
  for(i=0;i<16;i++){
    int x;
    x = 0xff&(1<<(i%8));
    rst(devid, x, 100);
    rst(devid, 0, 1);
  }

  rst(devid, 0xff, 1000);
  rst(devid, 0x0, 0);

  pg4_close(devid);

  return 0;
}
