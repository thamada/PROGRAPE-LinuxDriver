//Time-stamp: <2006-09-07 13:44:34 hamada>
//Copyright(c) 2000-2006 by Tsuyoshi Hamada. All rights reserved.

#include <stdio.h>
#include <math.h>
#include "nbodysim.h"

void dump_foset(int n){ return; }

void set_range(double xfac, double mfac)
{
  return;
}


void force(double x[][DIM],
	   double m[],
	   double eps2,
	   double a[][DIM],
	   int n)
{
  int i,j,d;
  double dx[3];

  for(i=0;i<n;i++) for(d=0;d<3;d++) a[i][d] = 0.0;

  for(i=0;i<n-1;i++){
    for(j=i+1;j<n;j++){
      double r2,r3;
      r2 = eps2;
      for(d=0;d<3;d++){
	dx[d] = x[j][d] - x[i][d];
	r2 += dx[d] * dx[d];
      }
      r3 = sqrt(r2)*r2;
      for(d=0;d<3;d++){
	a[i][d] +=  m[j]*dx[d]/r3;
	a[j][d] += -m[i]*dx[d]/r3;
      }
    }
  }
}
