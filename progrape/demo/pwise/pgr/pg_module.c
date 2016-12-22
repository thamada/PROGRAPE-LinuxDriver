// 
// PGR parametrized arithmetic modules for software emulators
// Copyright (c) 2004-2005 by Tsuyoshi Hamada and Naohito Nakasato
// All rights reserved.
// 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>

#ifndef LONG
#define LONG unsigned long long int
#endif

// ----------------------------------------------------------- : No. 0
/*
 * nbit : 32-bit 
 */
/*
 * ADDSUB : SUB 
 */
#include<stdio.h>
void
pg_fix_sub_32(int x, int y, LONG * z)
{
    unsigned int    _x;
    unsigned int    _y;
    int             _z;
    _x = 0xFFFFFFFF & x;
    _y = 0xFFFFFFFF & y;
    _z = (int) (_x - _y);
    _z = 0xFFFFFFFF & _z;
    (*z) = (LONG) _z;
}
// ----------------------------------------------------------- : No. 1
/*
 * nbit_fix : 32-bit 
 */
/*
 * nbit_log : 17-bit 
 */
/*
 * nbit_man : 8-bit 
 */
#include<stdio.h>
#include<math.h>
void
pg_conv_ftol_fix32_log17_man8(LONG x, LONG * z)
{
    int             fixdata;
    int             fixdata_msb = 0;
    int             logdata_sign = 0;
    int             fixdata_body = 0;
    int             abs = 0;
    int             abs_decimal = 0;
    int             logdata_nonzero = 0;
    int             penc_out = 0;	/* Output of penc */
    int             table_adr = 0;
    int             table_overflow = 0;
    int             logdata;
    int             logdata_mantissa = 0;
    int             logdata_exponent = 0;
    fixdata = (int) x;

    /*
     * SIGN BIT 
     */
    fixdata_msb = 0x1 & (fixdata >> 31);
    logdata_sign = fixdata_msb;

    /*
     * ABSOLUTE 
     */
    fixdata_body = 0x7FFFFFFF & fixdata;
    {
	int             inv_fixdata_body = 0;
	inv_fixdata_body = 0x7FFFFFFF ^ fixdata_body;
	if (fixdata_msb == 0x1) {
	    abs = 0x7FFFFFFF & (inv_fixdata_body + 1);
	} else {
	    abs = fixdata_body;
	}
    }
    abs_decimal = 0x3FFFFFFF & abs;

    /*
     * GENERATE NON-ZERO BIT (ALL BIT OR) 
     */
    if (abs != 0x0) {
	logdata_nonzero = 0x1;
    } else {
	logdata_nonzero = 0x0;
    }

    {				/* PRIORITY ENCODER */
	int             i;
	int             count = 0;
	for (i = 31; i >= 0; i--) {
	    int             buf;
	    buf = 0x1 & (abs >> i);
	    if (buf == 0x1) {
		count = i;
		break;
	    }
	    count = i;
	}
	penc_out = count;
    }
    penc_out = 0x1F & penc_out;	/* 5-bit */

    /*
     * SHIFTER 
     */
    {
	int             seed = 0;
	if (penc_out >= 10) {
	    seed = abs_decimal;
	    table_adr = 0x3FF & (seed >> (penc_out - 10));
	} else {
	    seed = abs_decimal << 10;
	    table_adr = 0x3FF & (seed >> penc_out);
	}
    }

    /*
     * TABLE 
     */
    /*
     * TABLE INPUT WIDTH = 10-bit 
     */
    /*
     * TABLE OUTPUT WIDTH = 8-bit 
     */
    {
	int             adr = 0;
	double          adr_double = 0.0;
	double          data_double = 0.0;
	int             data;
	adr = 0x3FF & table_adr;
	adr_double = (((double) adr) + 0.5) / 1024.000000;
	data_double =
	    256.000000 * (log(1.0 + adr_double)) / log(2.0) + 0.5;
	data = (int) data_double;
	/*
	 * CHECK OVERFLOW 
	 */
	if ((0x1 & (data >> 8)) == 0x1) {
	    data = 0;
	    table_overflow = 1;	/* overflow flag */
	} else {
	    table_overflow = 0;
	}
	logdata_mantissa = 0xFF & data;
    }

    /*
     * ADDER (GENERATE EXPONENT PART) 
     */
    logdata_exponent = 0x1F & (penc_out + table_overflow);

    logdata =
	logdata_sign << 16 | logdata_nonzero << 15 | logdata_exponent << 8
	| logdata_mantissa;

    (*z) = (LONG) logdata;
    return;
}
// ----------------------------------------------------------- : No. 2
/*
 * UNSIGNED logarithmic shifter(power 2^[nshift]) 
 */
/*
 * nbit : 17-bit 
 */
/*
 * nshift : 1-bit 
 */
/*
 * --- [NOTE!] --- Input/Output width of this component is different !
 * Input Width : 17-bit. [17-bit Signed Logarithmic Format] Onput Width : 
 * 16-bit. [17-bit Unsigned Logarithmic Format without a sign bit.] 
 */

/*
 * --- [NOTE!] --- nshift must be 2, 1, -1 or -2. 
 */

#include<stdio.h>
void
pg_log_shift_log17_1(LONG x, LONG * z)
{
    int             x_sign = 0;	/* Sign Flag: 1-bit (for debug) */
    int             x_nonzero = 0;	/* NonZero Flag: 1-bit */
    int             x_body = 0;	/* 15-bit */
    int             zz = 0;	/* 16-bit */

    x_sign = 0x1 & (((int) x) >> 16);
    x_nonzero = 0x1 & (((int) x) >> 15);
    x_body = 0x7FFF & ((int) x);

    zz = (x_nonzero << 15) | (0x7FFF & (x_body << 1));
    zz &= 0xFFFF;
    *z = (LONG) zz;

    return;
}
// ----------------------------------------------------------- : No. 3
/*
 * logarithmic UNSIGNED adder using interpolated table 
 */
/*
 * nbit_log : 17-bit 
 */
/*
 * nbit_man : 8-bit 
 */
/*
 * --- [NOTE!] --- Input/Output width of this component is 16-bit.  
 */

static long double
log_tab_plus_func(long double x)
{
    long double     f;
    f = logl(1.0 + powl(2.0, -1.0 * x)) / logl(2.0);
    return f;
}

static void
calc_chebyshev_coefficient(long double xk_min,
			   long double xk_max,
			   long double *coef0, long double *coef1)
{
    long double     (*_func) (long double);
    long double     x0, x1, bma, bpa, cc0, cc1;
    long double     f[2];
    x0 = -0.5 * sqrtl(2.0);
    x1 = 0.5 * sqrtl(2.0);
    bma = 0.5 * (xk_max - xk_min);
    bpa = 0.5 * (xk_max + xk_min);
    _func = &log_tab_plus_func;
    f[0] = (*_func) (x0 * bma + bpa);
    f[1] = (*_func) (x1 * bma + bpa);
    cc0 = 0.5 * (f[0] + f[1]);
    cc1 = 0.5 * sqrtl(2.0) * (f[1] - f[0]);
    (*coef0) = cc0 - cc1;
    (*coef1) = (-1.0) * cc1 / bma;
}

void
pg_log_unsigned_add_itp_log17_man8_cut6(LONG x, LONG y, LONG * z)
{
    int             logimage_x, logimage_y, logimage_z;
    int             signz = 0;	/* 1-bit */
    int             x1 = 0;	/* 17-bit */
    int             y1 = 0;	/* 17-bit */
    int             xy = 0;	/* 17-bit (x1 - y1) */
    int             yx = 0;	/* 17-bit (y1 - x1) */
    int             yx_msb = 0;	/* 1-bit SIGN of yx */
    int             x2 = 0;	/* 16-bit output of Left-MUX */
    int             d0 = 0;	/* 16-bit output of Right-MUX */
    int             d0_low_part = 0;	/* TABLE INPUT */
    int             d0_high_part = 0;	/* MUX Middle INPUT */
    int             df = 0;	/* MUX Middle OUTPUT */
    int             table_data = 0;	/* TABLE OUTPUT */
    int             logimage_ZperX = 0;	/* Logimage of (Real)Z/X */

    logimage_x = (int) x;
    logimage_y = (int) y;

    /*
     * SIGN EVALUATION ---------------------------- nonz(X) | nonz(Y) -> 
     * sign(Z) --------+------------------- 0 | 0 -> 0 0 | 1 -> sign(Y) 
     * 1 | 0 -> sign(X) 1 | 1 -> sign(X) ---------------------------- 
     */
    {
	int             nonzx, nonzy, signx, signy;
	signx = (logimage_x >> 16) & 0x1;
	signy = (logimage_y >> 16) & 0x1;
	nonzx = (logimage_x >> 15) & 0x1;
	nonzy = (logimage_y >> 15) & 0x1;
	if ((nonzx == 0x0) && (nonzy == 0x0)) {
	    signz = 0x0;
	} else if ((nonzx == 0x0) && (nonzy == 0x1)) {
	    signz = signy;
	} else if ((nonzx == 0x1) && (nonzy == 0x0)) {
	    signz = signx;
	} else {		/* (nonzx==0x1)&&(nonzy==0x1) */
	    signz = signx;
	}
    }

    /*
     * RESET FUNCTION 
     */
    {
	int             nonzx;
	int             nonzy;
	nonzx = 0x1 & (logimage_x >> 15);
	nonzy = 0x1 & (logimage_y >> 15);
	if (nonzx == 0x0)
	    logimage_x &= 0x0;
	if (nonzy == 0x0)
	    logimage_y &= 0x0;
    }

    x1 = 0xFFFF & logimage_x;	/* The MSB(17th-bit) is zero. */
    y1 = 0xFFFF & logimage_y;	/* The MSB(17th-bit) is zero. */

    /*
     * SUB (Y-X),(X-Y) 
     */
    yx = 0x1FFFF & (y1 - x1);
    xy = 0x1FFFF & (x1 - y1);

    yx_msb = 0x1 & (yx >> 16);

    /*
     * MUX Left 
     */
    if (yx_msb == 0x1) {
	x2 = 0xFFFF & logimage_x;
    } else {
	x2 = 0xFFFF & logimage_y;
    }

    /*
     * MUX Right 
     */
    if (yx_msb == 0x1) {
	d0 = 0xFFFF & xy;
    } else {
	d0 = 0xFFFF & yx;
    }

    /*
     * =========================== ROM C0 input = 6 bits ROM C1 input = 6 
     * bits ROM C0 output = 10 bits ROM C1 output = 9 bits BIT
     * EXTENSION = 2 bits =========================== 
     */
    /*
     * =========================== table input = 12 bits table output = 9 
     * bits =========================== 
     */
    d0_low_part = 0xFFF & d0;	/* 12-bit */
    d0_high_part = 0xF & (d0 >> 12);

    /*
     * MUX Middle 
     */
    if (d0_high_part == 0x0) {
	df = 0x1;
    } else {
	df = 0x0;
    }

    /*
     * TABLE LOG_ADD 
     */
    {
	long long int   adr, dx, rom_c0, rom_c1;
	long double     xk_min, xk_max, coef0, coef1;
	long long int   f;
	adr = (long long int) (d0_low_part >> 6);
	dx = (long long int) (0x3F & d0_low_part);
	xk_min = (long double) (adr << 6);
	xk_max = (long double) (((adr + 0x1LL) << 6) - 0x1LL);
	xk_min = (xk_min + 0.25) / (long double) (0x1LL << 8);
	xk_max = (xk_max + 0.25) / (long double) (0x1LL << 8);
	calc_chebyshev_coefficient(xk_min, xk_max, &coef0, &coef1);
	rom_c0 = (long long int) (coef0 * powl(2.0, 10.0) + 0.5);
	rom_c1 = (long long int) (coef1 * powl(2.0, 10.0) + 0.5);
	f = (rom_c0 - ((rom_c1 * dx) >> 8)) >> 2;
	if (f < 0)
	    f = 0x0LL;
	f &= 0xFFLL;
	if (d0_low_part == 0)
	    f = 0x1LL << 8;
	table_data = (int) (f);	/* TABLE OUTPUT : 9-bit */
    }

    /*
     * MUX Last 
     */
    if (df == 0x1) {
	logimage_ZperX = table_data;
    } else {
	logimage_ZperX = 0;
    }

    /*
     * ADDER :16-bit width 
     */
    {
	int             add_out = 0;
	add_out = x2 + logimage_ZperX;
	add_out &= 0xFFFF;
	/*
	 * WITH SIGN-BIT (2002/07/26) 
	 */
	logimage_z = (signz << 16) | add_out;
    }

    (*z) = (LONG) logimage_z;

    return;
}
// ----------------------------------------------------------- : No. 4
/*
 * UNSIGNED logarithmic shifter(power 2^[nshift]) 
 */
/*
 * nbit : 17-bit 
 */
/*
 * nshift : m1-bit 
 */
/*
 * --- [NOTE!] --- Input/Output width of this component is different !
 * Input Width : 17-bit. [17-bit Signed Logarithmic Format] Onput Width : 
 * 16-bit. [17-bit Unsigned Logarithmic Format without a sign bit.] 
 */

/*
 * --- [NOTE!] --- nshift must be 2, 1, -1 or -2. 
 */

#include<stdio.h>
void
pg_log_shift_log17_m1(LONG x, LONG * z)
{
    int             x_sign = 0;	/* Sign Flag: 1-bit (for debug) */
    int             x_nonzero = 0;	/* NonZero Flag: 1-bit */
    int             x_body = 0;	/* 15-bit */
    int             zz = 0;	/* 16-bit */

    x_sign = 0x1 & (((int) x) >> 16);
    x_nonzero = 0x1 & (((int) x) >> 15);
    x_body = 0x7FFF & ((int) x);

    zz = (x_nonzero << 15) | (0x7FFF & (x_body >> 1));
    zz &= 0xFFFF;
    *z = (LONG) zz;

    return;
}
// ----------------------------------------------------------- : No. 5
/*
 * nbit : 17-bit 
 */
/*
 * MULDIV : MUL 
 */
#include<stdio.h>
void
pg_log_mul_17(LONG x, LONG y, LONG * z)
{
    int             xx, yy;
    int             _signbit_x = 0;
    int             _signbit_y = 0;
    int             _signbit_z = 0;
    int             _nonzbit_x = 0;
    int             _nonzbit_y = 0;
    int             _nonzbit_z = 0;
    int             _x = 0;
    int             _y = 0;
    int             _z = 0;
    xx = (int) x;
    yy = (int) y;
    _signbit_x = 0x1 & (xx >> 16);
    _signbit_y = 0x1 & (yy >> 16);
    _signbit_z = _signbit_x ^ _signbit_y;
    _nonzbit_x = 0x1 & (xx >> 15);
    _nonzbit_y = 0x1 & (yy >> 15);
    _nonzbit_z = _nonzbit_x & _nonzbit_y;
    _x = 0x7FFF & xx;
    _y = 0x7FFF & yy;
    _z = _x + _y;
    _z = 0x7FFF & _z;
    _z = _signbit_z << 16 | _nonzbit_z << 15 | _z;
    _z = 0x1FFFF & (_z);
    *z = (LONG) _z;
    return;
}
// ----------------------------------------------------------- : No. 6
/*
 * nbit : 17-bit 
 */
/*
 * MULDIV : SDIV 
 */
#include<stdio.h>
void
pg_log_sdiv_17(LONG x, LONG y, LONG * z)
{
    int             xx, yy;
    int             _signbit_x = 0;
    int             _signbit_y = 0;
    int             _signbit_z = 0;
    int             _nonzbit_x = 0;
    int             _nonzbit_y = 0;
    int             _nonzbit_z = 0;
    int             _x = 0;
    int             _y = 0;
    int             _z = 0;
    xx = (int) x;
    yy = (int) y;
    _signbit_x = 0x1 & (xx >> 16);
    _signbit_y = 0x1 & (yy >> 16);
    _signbit_z = _signbit_x ^ _signbit_y;
    _nonzbit_x = 0x1 & (xx >> 15);
    _nonzbit_y = 0x1 & (yy >> 15);
    _nonzbit_z = _nonzbit_x & _nonzbit_y;
    _x = 0x7FFF & xx;
    _y = 0x7FFF & yy;
    _z = _x - _y;
    if (_y > _x)
	_z = 0;
    _z = 0x7FFF & _z;
    _z = _signbit_z << 16 | _nonzbit_z << 15 | _z;
    _z = 0x1FFFF & (_z);
    *z = (LONG) _z;
    return;
}
// ----------------------------------------------------------- : No. 7
// PGR LNS ExpADD
// exp add (-31)
// 1-bit : sign flag
// 1-bit : non-zero flag
// 7-bit : exponent
// 8-bit : mantissa
// Revision 2005/06/13

void
pg_log_expadd_m31_17_8(LONG x, LONG * z)
{
    LONG            signx, nonzx, nonzz, manx;
    LONG            expx, expz, eadd;
    LONG            expz0, is_underflow;

    signx = 0x1ULL & (x >> 16);
    nonzx = 0x1ULL & (x >> 15);
    expx = 0x7fULL & (x >> 8);
    manx = 0xffULL & (x);
    eadd = 0xe1ULL;		// -31
    expz0 = 0xffULL & (expx + eadd);	// 8-bit signed arithmetic !!
    expz = 0x7fULL & (expz0);
    is_underflow = 0x1ULL & (expz0 >> 7);
    if (is_underflow == 1)
	nonzz = 0;
    else
	nonzz = nonzx;		// it doesn't treat overflow!

    *z = (signx << 16) | (nonzz << 15) | (expz << 8) | manx;
    return;
}

// ----------------------------------------------------------- : No. 8
/*
 * nbit_log : 17-bit 
 */
/*
 * nbit_man : 8-bit 
 */
/*
 * nbit_fix : 57-bit 
 */
#include<stdio.h>
#include<math.h>
void
pg_conv_ltof_log17_man8_fix57(LONG x, LONG * z)
{
    int             logdata;
    int             logdata_sign = 0;
    int             logdata_nonzero = 0;
    int             logdata_exponent = 0;
    int             logdata_mantissa = 0;
    int             fixdata_sign = 0;
    LONG            fixdata;
    LONG            fixdata_absolute = 0;
    int             table_adr = 0;
    int             table_data = 0;
    int             shift_indata = 0;
    int             shift_control = 0;
    logdata = (int) x;

    /*
     * VECTOR PREPARATION 
     */
    logdata_sign = 0x1 & (logdata >> 16);
    logdata_nonzero = 0x1 & (logdata >> 15);
    logdata_exponent = 0x7F & (logdata >> 8);
    logdata_mantissa = 0xFF & logdata;

    /*
     * SIGN BIT 
     */
    fixdata_sign = logdata_sign;

    /*
     * TABLE 
     */
    table_adr = logdata_mantissa;
    {
	double          x = 0.0;
	double          y = 0.0;
	double          depth = 256.000000;
	x = pow(2.0, ((double) table_adr) / depth);
	y = (256.000000 * (x - 1.0)) + 0.5;
	table_data = (int) y;
	table_data &= 0xFF;
    }

    /*
     * MULTIPLEXOR 
     */
    {
	int             muxout = 0;
	if (logdata_nonzero == 0x1) {
	    muxout = 0x1 << 8 | table_data;
	} else {
	    muxout = 0x0;
	}
	shift_indata = muxout;
    }

    /*
     * SHIFTER 
     */
    shift_control = logdata_exponent;
    {
	LONG            shift_out = 0;
	LONG            seed = 0;
	if (shift_control < 8 * sizeof(LONG)) {
	    seed = ((LONG) shift_indata) << shift_control;
	} else {
	    seed = 0x0LL;
	}
	shift_out = seed >> 8;
	fixdata_absolute = 0x00FFFFFFFFFFFFFFULL & shift_out;
    }

    fixdata = ((LONG) fixdata_sign) << 56 | fixdata_absolute;
    (*z) = (LONG) fixdata;

    return;
}
// ----------------------------------------------------------- : No. 9
/*
 * Fixed-Point Accumulate Registor
 */
/*
 * nbit_fx(input) : 57-bit 
 */
/*
 * nbit_sx(register): 64-bit 
 */
/*
 * --- [NOTE!] --- The format of input data is not the 2's complement one.
 * MSB means a sign flag, and the other part means abusolute(not<0)
 * integer. 
 */

#include<stdio.h>
#include<math.h>
void
pg_fix_accum_f57_s64(LONG fdata, LONG * sdata)
{
    LONG            fx = 0;	/* 57-bit */
    LONG            sx = 0;	/* 64-bit */
    LONG            fx_sign = 0;	/* 1-bit : sign flag of fdata */
    LONG            fx_abs = 0;	/* 56-bit : absolute part of fdata */
    fx = 0x01FFFFFFFFFFFFFFULL & fdata;
    sx = 0xFFFFFFFFFFFFFFFFULL & (*sdata);
    fx_sign = 0x1 & (fdata >> 56);
    fx_abs = 0x00FFFFFFFFFFFFFFULL & fdata;
    if (fx_sign == 0x0) {
	sx = sx + fx_abs;
    } else {
	sx = sx - fx_abs;
    }

    *sdata = 0xFFFFFFFFFFFFFFFFULL & sx;
    return;
}
