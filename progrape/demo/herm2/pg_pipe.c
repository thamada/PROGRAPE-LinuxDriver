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
void            pg_float_sqrt_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_recipro_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_expadd_31_26_16(LONG x, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);
void            pg_float_expadd_31_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_unsigned_add_26_16(LONG x, LONG y, LONG * z);
void            pg_float_unsigned_add_26_16(LONG x, LONG y, LONG * z);
void            pg_float_expadd_1_26_16(LONG x, LONG * z);
void            pg_float_unsigned_add_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_expadd_31_26_16(LONG x, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_mult_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_sub_26_16(LONG x, LONG y, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);
void            pg_float_fixaccum_26_16_57_64(LONG x, LONG * z);


// API
void
force(double x[][3], double v[][3], double m[], double p[], double a[][3],
      double jk[][3], int n)
{
    int             i, j;
    LONG            rx;
    LONG            sx_0;
    LONG            sx_1;
    LONG            sx_2;
    LONG            tx_0;
    LONG            tx_1;
    LONG            tx_2;
    LONG            xj_0;
    LONG            xi_0;
    LONG            xj_1;
    LONG            xi_1;
    LONG            xj_2;
    LONG            xi_2;
    LONG            dx2_0;
    LONG            dx2_1;
    LONG            dx2_2;
    LONG            x2y2;
    LONG            r1;
    LONG            r3;
    LONG            r5;
    LONG            r5i;
    LONG            mj;
    LONG            r2;
    LONG            mp;
    LONG            ps;
    LONG            mf;
    LONG            fx_0;
    LONG            fx_1;
    LONG            fx_2;
    LONG            vj_0;
    LONG            vi_0;
    LONG            vj_1;
    LONG            vi_1;
    LONG            vj_2;
    LONG            vi_2;
    LONG            fs;
    LONG            dv_0;
    LONG            dv_1;
    LONG            dv_2;
    LONG            xv_0;
    LONG            xv_1;
    LONG            xv_2;
    LONG            xv1;
    LONG            xv2x2;
    LONG            xv2;
    LONG            mr5i;
    LONG            xv2x3;
    LONG            jk2a;
    LONG            dx_0;
    LONG            dx_1;
    LONG            jk2s;
    LONG            dx_2;
    LONG            jk1_0;
    LONG            jk2_0;
    LONG            jk1_1;
    LONG            jk2_1;
    LONG            jk1_2;
    LONG            jk2_2;
    LONG            jk0_0;
    LONG            jk0_1;
    LONG            jk0_2;


    for (i = 0; i < n; i++) {
	/*
	 * CONVERT(xi_0,float) 
	 */ xi_0 = double2pgrfloat(x[i][0], 26, 16, 6);
	/*
	 * CONVERT(xi_1,float) 
	 */ xi_1 = double2pgrfloat(x[i][1], 26, 16, 6);
	/*
	 * CONVERT(xi_2,float) 
	 */ xi_2 = double2pgrfloat(x[i][2], 26, 16, 6);
	/*
	 * CONVERT(vi_0,float) 
	 */ vi_0 = double2pgrfloat(v[i][0], 26, 16, 6);
	/*
	 * CONVERT(vi_1,float) 
	 */ vi_1 = double2pgrfloat(v[i][1], 26, 16, 6);
	/*
	 * CONVERT(vi_2,float) 
	 */ vi_2 = double2pgrfloat(v[i][2], 26, 16, 6);

	rx = 0;
	sx_0 = 0;
	sx_1 = 0;
	sx_2 = 0;
	tx_0 = 0;
	tx_1 = 0;
	tx_2 = 0;

	for (j = n - 1; j >= 0; j--) {
	    /*
	     * CONVERT(xj_0,float) 
	     */ xj_0 = double2pgrfloat(x[j][0], 26, 16, 6);
	    /*
	     * CONVERT(xj_1,float) 
	     */ xj_1 = double2pgrfloat(x[j][1], 26, 16, 6);
	    /*
	     * CONVERT(xj_2,float) 
	     */ xj_2 = double2pgrfloat(x[j][2], 26, 16, 6);
	    /*
	     * CONVERT(vj_0,float) 
	     */ vj_0 = double2pgrfloat(v[j][0], 26, 16, 6);
	    /*
	     * CONVERT(vj_1,float) 
	     */ vj_1 = double2pgrfloat(v[j][1], 26, 16, 6);
	    /*
	     * CONVERT(vj_2,float) 
	     */ vj_2 = double2pgrfloat(v[j][2], 26, 16, 6);
	    /*
	     * CONVERT(mj,float) 
	     */ mj = double2pgrfloat(m[j], 26, 16, 6);

	    pg_float_sub_26_16(xj_0, xi_0, &dx_0);
	    pg_float_sub_26_16(xj_1, xi_1, &dx_1);
	    pg_float_sub_26_16(xj_2, xi_2, &dx_2);
	    pg_float_mult_26_16(dx_0, dx_0, &dx2_0);
	    pg_float_mult_26_16(dx_1, dx_1, &dx2_1);
	    pg_float_mult_26_16(dx_2, dx_2, &dx2_2);
	    pg_float_unsigned_add_26_16(dx2_0, dx2_1, &x2y2);
	    pg_float_unsigned_add_26_16(dx2_2, x2y2, &r2);
	    pg_float_sqrt_26_16(r2, &r1);
	    pg_float_mult_26_16(r2, r1, &r3);
	    pg_float_mult_26_16(r3, r2, &r5);
	    pg_float_recipro_26_16(r5, &r5i);
	    pg_float_mult_26_16(r5i, mj, &mr5i);
	    pg_float_mult_26_16(mr5i, r2, &mf);
	    pg_float_mult_26_16(mf, r2, &mp);
	    pg_float_expadd_31_26_16(mp, &ps);
	    pg_float_fixaccum_26_16_57_64(ps, &rx);
	    pg_float_expadd_31_26_16(mf, &fs);
	    pg_float_mult_26_16(fs, dx_0, &fx_0);
	    pg_float_mult_26_16(fs, dx_1, &fx_1);
	    pg_float_mult_26_16(fs, dx_2, &fx_2);
	    pg_float_fixaccum_26_16_57_64(fx_0, &sx_0);
	    pg_float_fixaccum_26_16_57_64(fx_1, &sx_1);
	    pg_float_fixaccum_26_16_57_64(fx_2, &sx_2);
	    pg_float_sub_26_16(vj_0, vi_0, &dv_0);
	    pg_float_sub_26_16(vj_1, vi_1, &dv_1);
	    pg_float_sub_26_16(vj_2, vi_2, &dv_2);
	    pg_float_mult_26_16(fs, dv_0, &jk1_0);
	    pg_float_mult_26_16(fs, dv_1, &jk1_1);
	    pg_float_mult_26_16(fs, dv_2, &jk1_2);
	    pg_float_mult_26_16(dx_0, dv_0, &xv_0);
	    pg_float_mult_26_16(dx_1, dv_1, &xv_1);
	    pg_float_mult_26_16(dx_2, dv_2, &xv_2);
	    pg_float_unsigned_add_26_16(xv_0, xv_1, &xv1);
	    pg_float_unsigned_add_26_16(xv_2, xv1, &xv2);
	    pg_float_expadd_1_26_16(xv2, &xv2x2);
	    pg_float_unsigned_add_26_16(xv2x2, xv2, &xv2x3);
	    pg_float_mult_26_16(mr5i, xv2x3, &jk2a);
	    pg_float_expadd_31_26_16(jk2a, &jk2s);
	    pg_float_mult_26_16(jk2s, dx_0, &jk2_0);
	    pg_float_mult_26_16(jk2s, dx_1, &jk2_1);
	    pg_float_mult_26_16(jk2s, dx_2, &jk2_2);
	    pg_float_sub_26_16(jk1_0, jk2_0, &jk0_0);
	    pg_float_sub_26_16(jk1_1, jk2_1, &jk0_1);
	    pg_float_sub_26_16(jk1_2, jk2_2, &jk0_2);
	    pg_float_fixaccum_26_16_57_64(jk0_0, &tx_0);
	    pg_float_fixaccum_26_16_57_64(jk0_1, &tx_1);
	    pg_float_fixaccum_26_16_57_64(jk0_2, &tx_2);
	}
	p[i] =
	    ((double) (((long long int) rx) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	a[i][0] =
	    ((double) (((long long int) sx_0) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	a[i][1] =
	    ((double) (((long long int) sx_1) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	a[i][2] =
	    ((double) (((long long int) sx_2) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	jk[i][0] =
	    ((double) (((long long int) tx_0) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	jk[i][1] =
	    ((double) (((long long int) tx_1) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	jk[i][2] =
	    ((double) (((long long int) tx_2) << 0)) *
	    ((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
    }
}
