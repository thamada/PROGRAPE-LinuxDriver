//Time-stamp: <2006-09-07 13:45:36 hamada>
//Copyright(c) 2006 by Tsuyoshi Hamada. All rights reserved.

#include "pg_util.h"
// Funtion Prototyping
void            pg_fix_sub_32(int x, int y, LONG * z);
void            pg_fix_sub_32(int x, int y, LONG * z);
void            pg_fix_sub_32(int x, int y, LONG * z);
void            pg_conv_ftol_fix32_log17_man8(LONG x, LONG * z);
void            pg_conv_ftol_fix32_log17_man8(LONG x, LONG * z);
void            pg_conv_ftol_fix32_log17_man8(LONG x, LONG * z);
void            pg_log_shift_log17_1(LONG x, LONG * z);
void            pg_log_shift_log17_1(LONG x, LONG * z);
void            pg_log_shift_log17_1(LONG x, LONG * z);
void            pg_log_unsigned_add_itp_log17_man8_cut6(LONG x, LONG y,
							LONG * z);
void            pg_log_unsigned_add_itp_log17_man8_cut6(LONG x, LONG y,
							LONG * z);
void            pg_log_unsigned_add_itp_log17_man8_cut6(LONG x, LONG y,
							LONG * z);
void            pg_log_shift_log17_m1(LONG x, LONG * z);
void            pg_log_mul_17(LONG x, LONG y, LONG * z);
void            pg_log_sdiv_17(LONG x, LONG y, LONG * z);
void            pg_log_mul_17(LONG x, LONG y, LONG * z);
void            pg_log_mul_17(LONG x, LONG y, LONG * z);
void            pg_log_mul_17(LONG x, LONG y, LONG * z);
void            pg_log_expadd_m31_17_8(LONG x, LONG * z);
void            pg_log_expadd_m31_17_8(LONG x, LONG * z);
void            pg_log_expadd_m31_17_8(LONG x, LONG * z);
void            pg_conv_ltof_log17_man8_fix57(LONG x, LONG * z);
void            pg_conv_ltof_log17_man8_fix57(LONG x, LONG * z);
void            pg_conv_ltof_log17_man8_fix57(LONG x, LONG * z);
void            pg_fix_accum_f57_s64(LONG x, LONG * z);
void            pg_fix_accum_f57_s64(LONG x, LONG * z);
void            pg_fix_accum_f57_s64(LONG x, LONG * z);

static double XFACTOR=0.0;
static double MFACTOR=0.0;
void set_range(double xfac, double mfac)
{
  XFACTOR = xfac;
  MFACTOR = mfac;
}



#define NJMAX 16384
static LONG _a[NJMAX][3];
static unsigned int _xi[NJMAX][3];
void dump_foset(int n)
{
  int i;
  static int flag=0;
  static FILE* fp;

  if(flag==0){
    fp = fopen("xxx.log","w");
    flag=1;
  }

  for(i=0;i<n;i++){
    //    fprintf(fp,"%08x,",_xi[i][0]);
    //    fprintf(fp,"%08x,",_xi[i][1]);
    //    fprintf(fp,"%08x,",_xi[i][2]);
    fprintf(fp,"%04d,",i);
    fprintf(fp,"%016llx,",_a[i][0]);
    fprintf(fp,"%016llx,",_a[i][1]);
    fprintf(fp,"%016llx,",_a[i][2]);

    fprintf(fp,"\n");
  }
  fflush(fp);
}



// API
void
force(double x[][3], double m[], double eps2, double a[][3], int n)
{
    int             i, j;
    LONG            sx_0;
    LONG            sx_1;
    LONG            sx_2;
    int             xi_0;
    int             xj_0;
    int             xi_1;
    int             xj_1;
    int             xi_2;
    int             xj_2;
    LONG            xij_0;
    LONG            xij_1;
    LONG            xij_2;
    LONG            x2_0;
    LONG            x2_1;
    LONG            x2_2;
    LONG            ieps2;
    LONG            x2y2;
    LONG            z2e2;
    LONG            r2;
    LONG            r1;
    LONG            mj;
    LONG            r3;
    LONG            dx_0;
    LONG            dx_1;
    LONG            mf;
    LONG            dx_2;
    LONG            fx_0;
    LONG            fx_1;
    LONG            fx_2;
    LONG            fxs_0;
    LONG            fxs_1;
    LONG            fxs_2;
    LONG            ffx_0;
    LONG            ffx_1;
    LONG            ffx_2;


    for (i = 0; i < n; i++) {
	/*
	 * CONVERT(xi_0,fix) 
	 */ xi_0 =
	    ((int) (XFACTOR*x[i][0] * (pow(2.0, (double) 32) / (2.0)) + 0.5)) &
	    0xFFFFFFFF;
	/*
	 * CONVERT(xi_1,fix) 
	 */ xi_1 =
	    ((int) (XFACTOR*x[i][1] * (pow(2.0, (double) 32) / (2.0)) + 0.5)) &
	    0xFFFFFFFF;
	/*
	 * CONVERT(xi_2,fix) 
	 */ xi_2 =
	    ((int) (XFACTOR*x[i][2] * (pow(2.0, (double) 32) / (2.0)) + 0.5)) &
	    0xFFFFFFFF;
	/*
	 * CONVERT(ieps2,log) 
	 */ if (eps2 == 0.0) {
	    ieps2 = 0;
	} else if (eps2 > 0.0) {
	    ieps2 =
		(((int)
		  (pow(2.0, 8.0) *
		   log(XFACTOR*XFACTOR*eps2 *
		       ((pow(2.0, (double) 32) / (2.0)) *
			(pow(2.0, (double) 32) / (2.0)))) /
		   log(2.0))) & 0x7FFF) | 0x8000;
	} else {
	    ieps2 =
		(((int)
		  (pow(2.0, 8.0) *
		   log(-XFACTOR*XFACTOR*eps2 *
		       ((pow(2.0, (double) 32) / (2.0)) *
			(pow(2.0, (double) 32) / (2.0)))) /
		   log(2.0))) & 0x7FFF) | 0x18000;
	}

      _xi[i][0] = xi_0;
      _xi[i][1] = xi_1;
      _xi[i][2] = xi_2;


	sx_0 = 0;
	sx_1 = 0;
	sx_2 = 0;

	for (j = n - 1; j >= 0; j--) {
	    /*
	     * CONVERT(xj_0,fix) 
	     */ xj_0 =
		((int) (XFACTOR*x[j][0] * (pow(2.0, (double) 32) / (2.0)) + 0.5)) &
		0xFFFFFFFF;
	    /*
	     * CONVERT(xj_1,fix) 
	     */ xj_1 =
		((int) (XFACTOR*x[j][1] * (pow(2.0, (double) 32) / (2.0)) + 0.5)) &
		0xFFFFFFFF;
	    /*
	     * CONVERT(xj_2,fix) 
	     */ xj_2 =
		((int) (XFACTOR*x[j][2] * (pow(2.0, (double) 32) / (2.0)) + 0.5)) &
		0xFFFFFFFF;
	    /*
	     * CONVERT(mj,log) 
	     */ if (m[j] == 0.0) {
		mj = 0;
	    } else if (m[j] > 0.0) {
		mj = (((int)
		       (pow(2.0, 8.0) *
			log(MFACTOR*m[j] * (pow(2.0, 95.38) / (1.0e-2))) /
			log(2.0))) & 0x7FFF) | 0x8000;
	    } else {
		mj = (((int)
		       (pow(2.0, 8.0) *
			log(-MFACTOR*m[j] * (pow(2.0, 95.38) / (1.0e-2))) /
			log(2.0))) & 0x7FFF) | 0x18000;
	    }

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
	    pg_log_expadd_m31_17_8(fx_0, &fxs_0);
	    pg_log_expadd_m31_17_8(fx_1, &fxs_1);
	    pg_log_expadd_m31_17_8(fx_2, &fxs_2);
	    pg_conv_ltof_log17_man8_fix57(fxs_0, &ffx_0);
	    pg_conv_ltof_log17_man8_fix57(fxs_1, &ffx_1);
	    pg_conv_ltof_log17_man8_fix57(fxs_2, &ffx_2);
	    pg_fix_accum_f57_s64(ffx_0, &sx_0);
	    pg_fix_accum_f57_s64(ffx_1, &sx_1);
	    pg_fix_accum_f57_s64(ffx_2, &sx_2);
	}

	_a[i][0] = sx_0;
	_a[i][1] = sx_1;
	_a[i][2] = sx_2;


	a[i][0] = (XFACTOR*XFACTOR/MFACTOR)*
	    ((double) (((long long int) sx_0) << 0)) *
	    ((-(pow(2.0, (double) 32) / (2.0)) *
	      (pow(2.0, (double) 32) / (2.0)) * pow(2.0,31.0) /
						    
	      (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
	a[i][1] =(XFACTOR*XFACTOR/MFACTOR)*
	    ((double) (((long long int) sx_1) << 0)) *
	    ((-(pow(2.0, (double) 32) / (2.0)) *
	      (pow(2.0, (double) 32) / (2.0)) * pow(2.0,31.0) /
	      (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
	a[i][2] =(XFACTOR*XFACTOR/MFACTOR)*
	    ((double) (((long long int) sx_2) << 0)) *
	    ((-(pow(2.0, (double) 32) / (2.0)) *
	      (pow(2.0, (double) 32) / (2.0)) * pow(2.0,31.0) /
	      (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
    }
    dump_foset(n);

}
