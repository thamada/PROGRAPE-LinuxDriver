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
    int             xi_0;
    int             xj_0;
    int             xi_1;
    int             xj_1;
    int             xi_2;
    int             xj_2;
    int             xij_0;
    int             xij_1;
    int             xij_2;
    int             x2_0;
    int             x2_1;
    int             x2_2;
    int             ieps2;
    int             x2y2;
    int             z2e2;
    int             r2;
    int             r1;
    int             mj;
    int             r3;
    int             dx_0;
    int             dx_1;
    int             mf;
    int             dx_2;
    int             fxs_0;
    int             fxs_1;
    int             fxs_2;
    double          ffx_0;
    double          ffx_1;
    double          ffx_2;


    for (i = 0; i < n; i++) {

	sx_0 = 0.0;
	sx_1 = 0.0;
	sx_2 = 0.0;

	for (j = n - 1; j >= 0; j--) {

	    pg_fix_sub_32(xi_0, xj_0, &xij_0);
	    pg_fix_sub_32(xi_1, xj_1, &xij_1);
	    pg_fix_sub_32(xi_2, xj_2, &xij_2);
	    pg_conv_ftol_fix32_log17_man8(xij_0, &dx_0);
	    pg_conv_ftol_fix32_log17_man8(xij_1, &dx_1);
	    pg_conv_ftol_fix32_log17_man8(xij_2, &dx_2);
	    pg_log_shift_log17_1(dx_0, &x2_0);
	    pg_log_shift_log17_1(dx_1, &x2_1);
	    pg_log_shift_log17_1(dx_2, &x2_2);
	    pg_log_unsigned_add_itp_log17_man8_cut6(x2_0, x2_1, &x2y2);
	    pg_log_unsigned_add_itp_log17_man8_cut6(x2_2, ieps2, &z2e2);
	    pg_log_unsigned_add_itp_log17_man8_cut6(x2y2, z2e2, &r2);
	    pg_log_shift_log17_m1(r2, &r1);
	    pg_log_mul_17(r2, r1, &r3);
	    pg_log_sdiv_17(mj, r3, &mf);
	    pg_log_mul_17(mf, dx_0, &fx_0);
	    pg_log_mul_17(mf, dx_1, &fx_1);
	    pg_log_mul_17(mf, dx_2, &fx_2);
	    pg_conv_ltof_log17_man8_fix57(fxs_0, &ffx_0);
	    pg_conv_ltof_log17_man8_fix57(fxs_1, &ffx_1);
	    pg_conv_ltof_log17_man8_fix57(fxs_2, &ffx_2);
	    sx_0 += ffx_0;
	    sx_1 += ffx_1;
	    sx_2 += ffx_2;
	}
	a[i][0] =
	    sx_0 * (-(pow(2.0, (double) 32) / (2.0)) *
		    (pow(2.0, (double) 32) / (2.0)) * pow(2.0,
							  -1.0 *
							  (double) -31) /
		    (pow(2.0, 95.38) / (1.0e-2)));
	a[i][1] =
	    sx_1 * (-(pow(2.0, (double) 32) / (2.0)) *
		    (pow(2.0, (double) 32) / (2.0)) * pow(2.0,
							  -1.0 *
							  (double) -31) /
		    (pow(2.0, 95.38) / (1.0e-2)));
	a[i][2] =
	    sx_2 * (-(pow(2.0, (double) 32) / (2.0)) *
		    (pow(2.0, (double) 32) / (2.0)) * pow(2.0,
							  -1.0 *
							  (double) -31) /
		    (pow(2.0, 95.38) / (1.0e-2)));
    }
}
