#include <stdio.h>
#include <math.h>
#ifndef LONG
#define LONG unsigned long long int
#endif
#ifndef PGINT
#define PGINT unsigned long long int
#endif


void
force_double(double x[][3], double m[], double eps2, double a[][3], int n)
{
    int             i, j;
    double          sx_0;
    double          sx_1;
    double          sx_2;
    double          xi_0;
    double          xj_0;
    double          xi_1;
    double          xj_1;
    double          xi_2;
    double          xj_2;
    double          dx2_0;
    double          dx2_1;
    double          dx2_2;
    double          ieps2;
    double          x2y2;
    double          z2e2;
    double          r2;
    double          r1;
    double          r3;
    double          r3i;
    double          mj;
    double          mf;
    double          dx_0;
    double          dx_1;
    double          fs;
    double          dx_2;
    double          fx_0;
    double          fx_1;
    double          fx_2;


    for (i = 0; i < n; i++) {
	xi_0 = x[i][0];
	xi_1 = x[i][1];
	xi_2 = x[i][2];
	ieps2 = eps2;

	sx_0 = 0.0;
	sx_1 = 0.0;
	sx_2 = 0.0;

	for (j = n - 1; j >= 0; j--) {
	    xj_0 = x[j][0];
	    xj_1 = x[j][1];
	    xj_2 = x[j][2];
	    mj = m[j];

	    dx_0 = xi_0 - xj_0;
	    dx_1 = xi_1 - xj_1;
	    dx_2 = xi_2 - xj_2;
	    dx2_0 = dx_0 * dx_0;
	    dx2_1 = dx_1 * dx_1;
	    dx2_2 = dx_2 * dx_2;
	    x2y2 = dx2_0 + dx2_1;
	    z2e2 = dx2_2 + ieps2;
	    r2 = x2y2 + z2e2;
	    r1 = sqrt(r2);
	    r3 = r2 * r1;
	    if (r3 != 0.0) {
		r3i = 1.0 / r3;
	    } else {
		r3i = 0.0;
	    }
	    mf = r3i * mj;
	    fs = mf * pow(2.0, (double) 31);
	    fx_0 = fs * dx_0;
	    fx_1 = fs * dx_1;
	    fx_2 = fs * dx_2;
	    sx_0 += fx_0;
	    sx_1 += fx_1;
	    sx_2 += fx_2;
	}
	a[i][0] = sx_0 * (-1.0 / pow(2.0, (double) 31));
	a[i][1] = sx_1 * (-1.0 / pow(2.0, (double) 31));
	a[i][2] = sx_2 * (-1.0 / pow(2.0, (double) 31));
    }
}
