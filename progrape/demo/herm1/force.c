//Time-stamp: <2006-11-19 23:15:38 hamada>
//Copyright(c) 2000-2006 by Tsuyoshi Hamada. All rights reserved.

#include <stdio.h>
#include <math.h>

#define DIM 3

// void  force(double x[][3], double v[][3], double m[], double p[], double a[][3], double jk[][3], int n)
        

void _force(double x[][DIM],
	    double v[][DIM],
	    double m[],
	    double p[],
	    double a[][DIM],
	    double jk[][DIM],
	    int n)
{
  int i,j,d;
  double eps2;
  double dx[DIM],dv[DIM];

  eps2 = 0.0;
  for(i=0;i<n;i++){
    p[i] = 0.0;
    for(d=0;d<DIM;d++) {
      a[i][d] = 0.0;
      jk[i][d] = 0.0;
    }
  }

  for(i=0;i<n-1;i++){
    for(j=i+1;j<n;j++){
      double r2,r3,r1,r5;
      double vr = 0.0;
      r2 = eps2;
      for(d=0;d<DIM;d++){
	dx[d] = x[j][d] - x[i][d];
	dv[d] = v[j][d] - v[i][d];
	r2 += dx[d] * dx[d];
	vr += dx[d] * dv[d];
      }
      r1 = sqrt(r2);
      r3 = r1 * r2;
      r5 = r2 * r2 * r1;

      // --- pot ---
      p[i] += m[j] / r1;
      p[j] += m[i] / r1;

      // --- a ---
      for(d=0;d<DIM;d++){
	a[i][d] +=  m[j]*dx[d]/r3;
	a[j][d] += -m[i]*dx[d]/r3;
      }

      // --- jerk ---
      for(d=0;d<DIM;d++){
	jk[i][d] +=  m[j]* ( (dv[d]/r3) - (3.0*vr*dx[d]/r5) );
	jk[j][d] += -m[i]* ( (dv[d]/r3) - (3.0*vr*dx[d]/r5) );
      }
    }
  }
}
