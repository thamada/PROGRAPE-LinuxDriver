#include "pg_util.h"
// Funtion Prototyping
void            pg_float_compare_26_16(LONG x, LONG y, LONG * z);
void            pg_float_compare_26_16(LONG x, LONG y, LONG * z);
void            pg_bits_inv_1(LONG x, LONG * z);
void            pg_bits_inv_1(LONG x, LONG * z);
void            pg_bits_and_1(LONG x, LONG y, LONG * z);
void            pg_bits_and_1(LONG x, LONG y, LONG * z);
void            pg_bits_and_1(LONG x, LONG y, LONG * z);
void            pg_bits_and_1(LONG x, LONG y, LONG * z);
void            pg_bits_join_56_1(LONG x, LONG y, LONG * z);
void            pg_bits_join_56_1(LONG x, LONG y, LONG * z);
void            pg_bits_join_56_1(LONG x, LONG y, LONG * z);
void            pg_bits_join_56_1(LONG x, LONG y, LONG * z);
void            pg_fix_smaccum_f57_s64(LONG x, LONG * z);
void            pg_fix_smaccum_f57_s64(LONG x, LONG * z);
void            pg_fix_smaccum_f57_s64(LONG x, LONG * z);
void            pg_fix_smaccum_f57_s64(LONG x, LONG * z);


// API
void
force_emu(double data_j[][2], double data_i[][2], double count_i[][4],
	  unsigned long long int fo[][4],
	  int ni, int nj)
{
    int             i, j;
    LONG            sx_0;
    LONG            sx_1;
    LONG            sx_2;
    LONG            sx_3;
    LONG            xj_0;
    LONG            xi_0;
    LONG            xj_1;
    LONG            xi_1;
    LONG            y_x;
    LONG            y_y;
    LONG            n_x;
    LONG            n_y;
    LONG            qq0;
    LONG            qq1;
    LONG            qq2;
    LONG            zero;
    LONG            qq3;
    LONG            q0;
    LONG            q1;
    LONG            q2;
    LONG            q3;

    zero = 0x0;

    for (i = 0; i < ni; i++) {
	/*
	 * CONVERT(xi_0,float) 
	 */ xi_0 = double2pgrfloat(data_i[i][0], 26, 16, 6);
	/*
	 * CONVERT(xi_1,float) 
	 */ xi_1 = double2pgrfloat(data_i[i][1], 26, 16, 6);

	sx_0 = 0;
	sx_1 = 0;
	sx_2 = 0;
	sx_3 = 0;

	for (j = nj - 1; j >= 0; j--) {
	    /*
	     * CONVERT(xj_0,float) 
	     */ xj_0 = double2pgrfloat(data_j[j][0], 26, 16, 6);
	    /*
	     * CONVERT(xj_1,float) 
	     */ xj_1 = double2pgrfloat(data_j[j][1], 26, 16, 6);

	    pg_float_compare_26_16(xj_0, xi_0, &y_x);
	    pg_float_compare_26_16(xj_1, xi_1, &y_y);
	    pg_bits_inv_1(y_x, &n_x);
	    pg_bits_inv_1(y_y, &n_y);
	    pg_bits_and_1(y_x, y_y, &qq0);
	    pg_bits_and_1(y_x, n_y, &qq1);
	    pg_bits_and_1(n_x, y_y, &qq2);
	    pg_bits_and_1(n_x, n_y, &qq3);
	    pg_bits_join_56_1(zero, qq0, &q0);
	    pg_bits_join_56_1(zero, qq1, &q1);
	    pg_bits_join_56_1(zero, qq2, &q2);
	    pg_bits_join_56_1(zero, qq3, &q3);
	    pg_fix_smaccum_f57_s64(q0, &sx_0);
	    pg_fix_smaccum_f57_s64(q1, &sx_1);
	    pg_fix_smaccum_f57_s64(q2, &sx_2);
	    pg_fix_smaccum_f57_s64(q3, &sx_3);
	}
	count_i[i][0] =
	    ((double) (((long long int) sx_0) << 0)) * (1.0) / pow(2.0,
								   0.0);
	count_i[i][1] =
	    ((double) (((long long int) sx_1) << 0)) * (1.0) / pow(2.0,
								   0.0);
	count_i[i][2] =
	    ((double) (((long long int) sx_2) << 0)) * (1.0) / pow(2.0,
								   0.0);
	count_i[i][3] =
	    ((double) (((long long int) sx_3) << 0)) * (1.0) / pow(2.0,
								   0.0);
	fo[i][0] = sx_0;
	fo[i][1] = sx_1;
	fo[i][2] = sx_2;
	fo[i][3] = sx_3;

    }
}
