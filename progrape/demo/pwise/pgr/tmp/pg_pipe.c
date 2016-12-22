#include "pg_util.h"
// Funtion Prototyping
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_unsigned_add_26_16(LONG x, LONG y, LONG * z);
void            pg_float_unsigned_add_26_16(LONG x, LONG y, LONG * z);
void            pg_float_unsigned_add_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sqrt_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_recipro_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_expadd_31_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_fixaccum_26_16(LONG x, LONG * z);
void            pg_float_fixaccum_26_16(LONG x, LONG * z);
void            pg_float_fixaccum_26_16(LONG x, LONG * z);


// API
void
force(double x[][3], double m[], double eps2, double a[][3], int n)
{
    int             i, j;
    LONG            sx_0;
    LONG            sx_1;
    LONG            sx_2;
    LONG            xi_0;
    LONG            xj_0;
    LONG            xi_1;
    LONG            xj_1;
    LONG            xi_2;
    LONG            xj_2;
    LONG            dx2_0;
    LONG            dx2_1;
    LONG            dx2_2;
    LONG            ieps2;
    LONG            x2y2;
    LONG            z2e2;
    LONG            r2;
    LONG            r1;
    LONG            r3;
    LONG            r3i;
    LONG            mj;
    LONG            mf;
    LONG            dx_0;
    LONG            dx_1;
    LONG            fs;
    LONG            dx_2;
    LONG            fx_0;
    LONG            fx_1;
    LONG            fx_2;


    for (i = 0; i < n; i++) {
	/*
	 * CONVERT(xi_0,float) 
	 */ xi_0 = double2pgpgfloat_r(x[i][0], 26, 16, 6);
	/*
	 * CONVERT(xi_1,float) 
	 */ xi_1 = double2pgpgfloat_r(x[i][1], 26, 16, 6);
	/*
	 * CONVERT(xi_2,float) 
	 */ xi_2 = double2pgpgfloat_r(x[i][2], 26, 16, 6);
	/*
	 * CONVERT(ieps2,float) 
	 */ ieps2 = double2pgpgfloat_r(eps2, 26, 16, 6);

	sx_0 = 0;
	sx_1 = 0;
	sx_2 = 0;

	for (j = n - 1; j >= 0; j--) {
	    /*
	     * CONVERT(xj_0,float) 
	     */ xj_0 = double2pgpgfloat_r(x[j][0], 26, 16, 6);
	    /*
	     * CONVERT(xj_1,float) 
	     */ xj_1 = double2pgpgfloat_r(x[j][1], 26, 16, 6);
	    /*
	     * CONVERT(xj_2,float) 
	     */ xj_2 = double2pgpgfloat_r(x[j][2], 26, 16, 6);
	    /*
	     * CONVERT(mj,float) 
	     */ mj = double2pgpgfloat_r(m[j], 26, 16, 6);

	    pg_float_sub_26_16(xi_0, xj_0, &dx_0);
	    pg_float_sub_26_16(xi_1, xj_1, &dx_1);
	    pg_float_sub_26_16(xi_2, xj_2, &dx_2);
	    pg_float_mult_26_16(dx_0, dx_0, &dx2_0);
	    pg_float_mult_26_16(dx_1, dx_1, &dx2_1);
	    pg_float_mult_26_16(dx_2, dx_2, &dx2_2);
	    pg_float_unsigned_add_26_16(dx2_0, dx2_1, &x2y2);
	    pg_float_unsigned_add_26_16(dx2_2, ieps2, &z2e2);
	    pg_float_unsigned_add_26_16(x2y2, z2e2, &r2);
	    pg_float_sqrt_26_16(r2, &r1);
	    pg_float_mult_26_16(r2, r1, &r3);
	    pg_float_recipro_26_16(r3, &r3i);
	    pg_float_mult_26_16(r3i, mj, &mf);
	    pg_float_expadd_31_26_16(mf, &fs);
	    pg_float_mult_26_16(fs, dx_0, &fx_0);
	    pg_float_mult_26_16(fs, dx_1, &fx_1);
	    pg_float_mult_26_16(fs, dx_2, &fx_2);
	    pg_float_fixaccum_26_16_57_64(fx_0, &sx_0);
	    pg_float_fixaccum_26_16_57_64(fx_1, &sx_1);
	    pg_float_fixaccum_26_16_57_64(fx_2, &sx_2);
	}
	a[i][0] =
	    ((double) (((long long int) sx_0) << 0)) *
	    ((-1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	a[i][1] =
	    ((double) (((long long int) sx_1) << 0)) *
	    ((-1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	a[i][2] =
	    ((double) (((long long int) sx_2) << 0)) *
	    ((-1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
    }
}
