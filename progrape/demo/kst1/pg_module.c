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
// PGR Floating-Point Compare 
// by T.Hamada (2004/08/31) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// if(x>y) f=1; else f=0; 
void
pg_float_compare_26_16(LONG opx, LONG opy, LONG * f)
{
    LONG            x, y;
    LONG            nonzx, nonzy;
    LONG            signx, signy;
    LONG            expx, expy;
    LONG            manx, many;
    LONG            exp_x, exp_y;
    LONG            fx, fy;	// nbit_float-2 -bit
    LONG            fxy;
    LONG            fxy_sign;	// (fx >= fy) ? 0 : 1
    LONG            xney;	// (fx != fy) ? 1 : 0
    LONG            flag;
    x = (LONG) opx;
    y = (LONG) opy;
    signx = 0x1ULL & (x >> 25);
    signy = 0x1ULL & (y >> 25);
    nonzx = 0x1ULL & (x >> 24);
    nonzy = 0x1ULL & (y >> 24);
    expx = 0xFFULL & (x >> 16);
    expy = 0xFFULL & (y >> 16);
    // biassing exponent
    exp_x = (0x1ULL << 7) ^ expx;
    exp_y = (0x1ULL << 7) ^ expy;
    manx = 0xFFFFULL & x;
    many = 0xFFFFULL & y;

    fx = 0xFFFFFFULL & ((exp_x << 16) | manx);
    fy = 0xFFFFFFULL & ((exp_y << 16) | many);
    fxy = 0x1FFFFFFULL & (fx - fy);	// nbit_float-1
    fxy_sign = 0x1ULL & (fxy >> 24);	// nbit_float-2

    // xney
    if ((0xFFFFFFULL & fxy) == 0x0ULL) {	// nbit_float-2
	xney = 0;
    } else {
	xney = 1;
    }

    if ((nonzx == 0ULL) && (nonzy == 1ULL)) {
	if (signy == 0ULL) {
	    flag = 0;		// x=0, y>0
	} else {
	    flag = 1;		// x=0, y<0
	}
    } else if ((nonzx == 1ULL) && (nonzy == 0ULL)) {
	if (signx == 0ULL) {
	    flag = 1;		// x>0, y=0
	} else {
	    flag = 0;		// x=0, y<0
	}
    } else if ((nonzx == 1ULL) && (nonzy == 1ULL)) {
	if ((signx == 0ULL) && (signy == 0ULL)) {
	    if (xney == 0) {	// fx == fy
		flag = 0;	// x=y>0
	    } else {		// fx != fy
		if (fxy_sign == 0ULL) {
		    flag = 1;	// |x|>|y|
		} else {
		    flag = 0;	// |x|<|y|
		}
	    }
	} else if ((signx == 1ULL) && (signy == 1ULL)) {
	    if (xney == 0) {	// fx == fy
		flag = 0;	// x=y<0
	    } else {		// fx != fy
		if (fxy_sign == 0ULL) {
		    flag = 0;	// |x|>|y|, x<0, y<0
		} else {
		    flag = 1;	// |x|<|y|, x<0, y<0
		}
	    }
	} else if ((signx == 0ULL) && (signy == 1ULL)) {
	    flag = 1;		// x>0, y<0
	} else {		// (signx == 1ULL)&&(signy == 0ULL)
	    flag = 0;		// x<0, y>0
	}
    } else {			// (nonzx == 0ULL) && (nonzy == 0ULL)
	flag = 0;		// x=y=0
    }

    (*f) = flag;
}

// ----------------------------------------------------------- : No. 1
/*
 * nbit : 1-bit 
 */
#include<stdio.h>
void
pg_bits_inv_1(LONG x, LONG * z)
{
    LONG            _x;
    LONG            _z;
    _x = 0x1ULL & (LONG) x;
    _z = ~(_x);
    *z = 0x1ULL & _z;
}
// ----------------------------------------------------------- : No. 2
/*
 * nbit : 1-bit 
 */
void
pg_bits_and_1(LONG x, LONG y, LONG * z)
{
    LONG            _x;
    LONG            _y;
    LONG            _z;
    _x = 0x1ULL & (LONG) x;
    _y = 0x1ULL & (LONG) y;
    _z = _x & _y;
    *z = 0x1ULL & _z;
}
// ----------------------------------------------------------- : No. 3
/*
 * opx nbit : 56-bit 
 */
/*
 * opy nbit : 1-bit 
 */
/*
 * z...z = x...x y...y (57-bit)
 */
void
pg_bits_join_56_1(LONG x, LONG y, LONG * z)
{
    LONG            _x;
    LONG            _y;
    LONG            _z;
    _x = 0xFFFFFFFFFFFFFFULL & (LONG) x;
    _y = 0x1ULL & (LONG) y;
    _z = (_x << 1) | _y;
    *z = 0x1FFFFFFFFFFFFFFULL & _z;
}
// ----------------------------------------------------------- : No. 4
/*
 * Fixed-Point SM Accumulate Registor
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
pg_fix_smaccum_f57_s64(LONG fdata, LONG * sdata)
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
