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
// PGR Floating-Point Unsigned Adder 
// by N.Nakasato (2004/08/23) 
// by T.Hamada (2003/11/24) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// Format ---------------------------------------------------------
// | sign bit[25] | nonz bit[24] | exp bit[23..16] | man bit[15..0]
// ----------------------------------------------------------------
// (1)This operation can't handle exceptions like 
// (+/-)inf, NaN and denormalized numbers.  
// (2)Exponent is not biased.  
// (3)(+/-)Zero means: nonz bit == 0 
void
pg_float_unsigned_add_26_16(LONG opx, LONG opy, LONG * result)
{
    LONG            x, y, z;
    LONG            nonzx, nonzy, nonzz;
    LONG            signx, signy, signz;
    LONG            expx, expy;
    LONG            manx, many;
    LONG            expdif;	/* abs(expx-expy) */
    LONG            mana;	/* Winner(manx,many) */
    LONG            manb;	/* Loser(manx,many) */
    LONG            expz;
    LONG            manz = 0;
    LONG            manz_rd;
    LONG            Ulp, Sbit, Gbit;
    LONG            expz_a, expz_b;
    LONG            man_inc;
    LONG            nontobi;

    x = (LONG) opx;
    y = (LONG) opy;

    // begin unpack pgpgfloat
    // //////////////////////////////////////////////////
    // extract sign bit
    signx = 0x1ULL & (x >> 25);
    signy = 0x1ULL & (y >> 25);

    // extract non-zero bit
    nonzx = 0x1ULL & (x >> 24);
    nonzy = 0x1ULL & (y >> 24);

    // extract exponent
    expx = 0xFFULL & (x >> 16);
    expy = 0xFFULL & (y >> 16);

    // extract mantissa
    manx = 0xFFFFULL & x;
    many = 0xFFFFULL & y;
    // end unpack pgpgfloat
    // //////////////////////////////////////////////////

    // set signz
    signz = signx;

    // set nonz
    nonzz = nonzx | nonzy;

    // compare and swap (X , Y)
    /*
     * input : nonzx (0 : 0) input : nonzy (0 : 0) input : expx
     * (nbit_exp-1 : 0) input : expy (nbit_exp-1 : 0) input : manx
     * (nbit_man-1 : 0) input : many (nbit_man-1 : 0) output : expdif
     * (nbit_exp-1 : 0) output : expz (nbit_exp-1 : 0) output : mana
     * (nbit_man : 0) output : manb (nbit_man : 0) output : nontobi (0 : 
     * 0) 
     */
    {
	LONG            flag0, flag1;
	LONG            nygex;	// ((nonzx==0)&&(nonzy==1)) ? 1 : 0
	LONG            exp_x = (0x1ULL << 7) ^ expx;
	LONG            exp_y = (0x1ULL << 7) ^ expy;
	LONG            exy, eyx;
	LONG            xney;	// (expx != expy) ? 1 : 0
	LONG            eygex;	// (expy > expx) ? 1 : 0
	LONG            mxy;
	LONG            mygex;	// (many > manx) ? 1 : 0

	mxy = 0x1FFFFULL & ((0xFFFFULL & manx) - (0xFFFFULL & many));
	mygex = 0x1ULL & (mxy >> 16);

	exy = 0x1FFULL & (exp_x - exp_y);	// (nbit_exp+1)-bit
	eyx = 0xFFULL & (exp_y - exp_x);	// (nbit_exp)-bit
	eygex = (0x1ULL & (exy >> 8));

	if (eygex == 1)
	    expdif = eyx;
	else
	    expdif = (0xFFULL & exy);

	if (expdif == 0x0ULL)
	    xney = 0;
	else
	    xney = 1;

	// set nontobi
	if ((nonzx == 1) && (nonzy == 1))
	    nontobi = 0x1ULL;
	else
	    nontobi = 0x0ULL;

	// set nygex
	if ((nonzx == 0) && (nonzy == 1))
	    nygex = 0x1ULL;
	else
	    nygex = 0x0ULL;

	// set flag0
	if (xney == 0)
	    flag0 = mygex;
	else
	    flag0 = eygex;

	// set flag1
	if (nontobi == 0)
	    flag1 = nygex;
	else
	    flag1 = flag0;

	// swap
	if (flag1 == 0) {
	    expz = expx;	// 8-bit
	    mana = manx;	// 16-bit
	    manb = many;	// 16-bit
	} else {
	    expz = expy;	// 8-bit
	    mana = many;	// 16-bit
	    manb = manx;	// 16-bit
	}
    }

    // shift and add
    /*
     * input : expdif (nbit_exp-1 : 0) input : mana (nbit_man : 0) input : 
     * manb (nbit_man : 0) input : expz (nbit_exp-1 : 0) output : Sbit (0
     * : 0) output : Gbit (0 : 0) output : expz_a (nbit_exp-1 : 0) output
     * : manz (nbit_man-1 : 0) 
     */
    {
	LONG            eflag, is_tobi;
	if (expdif >= 18)
	    eflag = 0;
	else
	    eflag = 1;
	is_tobi = 0x1ULL & (~(eflag & nontobi));	// tobi <= (eflag) 
							// NAND (nontobi)
	if (is_tobi == 1) {
	    Sbit = 0;
	    Gbit = 1;
	    manz = 0xFFFFULL & mana;
	    expz_a = expz;
	} else {
	    int             shift;
	    LONG            tmp3;
	    LONG            mtr, mtrh, mtrl;
	    shift = (int) expdif;
	    // ADDITION
	    {
		LONG            addx, addy, guard;
		// manb separate between 'addy' and 'guard'
		{
		    LONG            one_manb = (0x10000ULL | manb);
		    guard = ((0x1ULL << (shift + 1)) - 1) & one_manb;	// 1+shift 
									// bit
		    addy = one_manb >> shift;	// (1+nbit_man-shift) bit
		    addy &= (0x1ULL << (17 - shift)) - 1;
		}

		// input : guard , shift
		// output : Sbit, Gbit
		if (shift == 0) {
		    Sbit = 0x0ULL;
		    Gbit = 0x0ULL;
		} else {
		    LONG            g2;
		    Sbit = 0x1ULL & (guard >> (shift - 1));
		    g2 = (((0x1ULL << (shift - 1)) - 1) & guard);
		    if (g2 != 0) {
			Gbit = 0x1ULL;
		    } else {
			Gbit = 0x0ULL;
		    }
		}

		addx = 0x10000ULL | mana;
		tmp3 = addx + addy;	// (nbit_man+2)-bit addition
		tmp3 &= 0x3FFFFULL;
		mtr = tmp3;
	    }

	    mtrh = 0x3ULL & (mtr >> 16);	/* mtr(17 downto 16) ,get
						 * integral part, 2bits */
	    mtrl = 0x1FFFFULL & mtr;	/* mtr(16 downto 0) ,get 1-bit
					 * integer & mantissa */

	    if (mtrh != 0x1ULL) {
		manz = 0xFFFFULL & (mtrl >> 1);	/* nbit_man bits (cut
						 * integer part) */
		expz_a = 0xFFULL & (expz + 0x1ULL);
	    } else {
		manz = 0xFFFFULL & mtrl;	/* nbit_man bits (cut
						 * integer part) */
		expz_a = expz;
	    }
	}
    }

    // unit in the last place
    Ulp = 0x1ULL & manz;


    /*
     * Generate Rounding bit (man_inc)
     */
    /*
     * input : signz ( 0 : 0 ) 
     */
    /*
     * input : Ulp ( 0 : 0 ) 
     */
    /*
     * input : Sbit ( 0 : 0 ) 
     */
    /*
     * input : Gbit ( 0 : 0 ) 
     */
    /*
     * output : man_inc ( 0 : 0 )
     */
    {
	int             rmode = 6;
	if (rmode == 0)
	    man_inc = 0;	/* Truncation */
	else if (rmode == 1)
	    man_inc = signz * (1 - (1 - Sbit) * (1 - Gbit));	/* Truncation 
								 * to Zero 
								 */
	else if (rmode == 2)
	    man_inc = Sbit;	/* Rounding to Plus Infinity */
	else if (rmode == 3)
	    man_inc = Sbit * Gbit;	/* Rounding to Minus Infinity */
	else if (rmode == 4)
	    man_inc = Sbit * (1 - signz * (1 - Gbit));	/* Rounding to
							 * Infinity */
	else if (rmode == 5)
	    man_inc = Sbit * (1 - (1 - signz) * (1 - Gbit));	/* Rounding 
								 * to Zero 
								 */
	else if (rmode == 6)
	    man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding 
								 * to Even 
								 */
	else if (rmode == 7)
	    man_inc = Sbit * (1 - Ulp * (1 - Gbit));	/* Rounding to Odd 
							 */
	else if (rmode == 8)
	    man_inc = Sbit + Gbit;	/* Force one */
	else
	    man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding 
								 * to Even 
								 */
    }

    man_inc &= nontobi;

    /*
     * Do Rounding 
     */
    /*
     * adder with overflow-flag 
     */
    /*
     * input : manz( nbit_man-1 : 0 ) 
     */
    /*
     * output : expz_b( nbit_exp-1 : 0 ) 
     */
    /*
     * output : manz_rd( nbit_man-1 : 0 ) 
     */
    {
	LONG            madd = 0x1FFFFULL & (manz + man_inc);
	LONG            cout = 0x1ULL & (madd >> 16);
	if (cout == 1ULL) {
	    expz_b = 0xFFULL & (expz_a + 0x1ULL);
	    manz_rd = 0x0ULL;
	} else {
	    expz_b = expz_a;
	    manz_rd = 0xFFFFULL & madd;
	}
    }

    // compose pgpgfloat
    z = (signz << 25) | (nonzz << 24) | (expz_b << 16) | manz_rd;

    (*result) = z;
}

// ----------------------------------------------------------- : No. 1
// ----------------------------------------------------- SUB-MODULE FOR
// FLOAT_UNSIGNED_SUB (BEGIN)
#ifndef PG_FLOAT_UNSIGNED_SUB
#define PG_FLOAT_UNSIGNED_SUB 1
// Loser mantissa shift
static void
pgsub_float_usub_shift_manb(int nbit_man,
			    LONG expdif, LONG manb, LONG * manb_shift)
{
    LONG            mb, mb_G, mb_SH, mb_SL;
    manb &= (0x1ULL << nbit_man) - 1;
    mb = ((0x1ULL << nbit_man) | manb) << ((nbit_man + 1) - expdif);
    if ((((0x1ULL << (nbit_man - 1)) - 1) & mb) == 0)
	mb_G = 0;
    else
	mb_G = 1;
    mb_SH = 0x1ULL & (mb >> nbit_man);
    mb_SL = 0x1ULL & (mb >> (nbit_man - 1));
    mb = ((0x1ULL << (nbit_man + 1)) - 1) & (mb >> (nbit_man + 1));
    *manb_shift = (mb << 3) | (mb_SH << 2) | (mb_SL << 1) | (mb_G);
}

// compare and swap (X , Y)
static void
pgsub_float_usub_swap(int nbit_float,
		      int nbit_man,
		      LONG signx,
		      LONG signy,
		      LONG nonzx,
		      LONG nonzy,
		      LONG expx,
		      LONG expy,
		      LONG manx,
		      LONG many,
		      LONG * expdif,
		      LONG * expz,
		      LONG * mana,
		      LONG * manb,
		      LONG * nontobi, LONG * signz, LONG * is_xeqy)
{
    LONG            flag0, flag1;
    LONG            nygex;	// ((nonzx==0)&&(nonzy==1)) ? 1 : 0
    LONG            nbit_exp = nbit_float - nbit_man - 2;
    LONG            exp_x = (0x1ULL << (nbit_exp - 1)) ^ expx;
    LONG            exp_y = (0x1ULL << (nbit_exp - 1)) ^ expy;
    LONG            exy, eyx;
    LONG            eygex;	// (expy > expx) ? 1 : 0
    LONG            exgey;	// (expx > expy) ? 1 : 0
    LONG            exeqy;	// (expx == expy) ? 1 : 0
    LONG            mxy, myx;
    LONG            mygex;	// (many > manx) ? 1 : 0
    LONG            mxgey;	// (manx > many) ? 1 : 0
    LONG            mxeqy;	// (manx == many) ? 1 : 0

    mxy =
	((0x1ULL << (nbit_man + 1)) -
	 1) & ((((0x1ULL << nbit_man) - 1) & manx) -
	       (((0x1ULL << nbit_man) - 1) & many));
    myx =
	((0x1ULL << (nbit_man + 1)) -
	 1) & ((((0x1ULL << nbit_man) - 1) & many) -
	       (((0x1ULL << nbit_man) - 1) & manx));
    mygex = 0x1ULL & (mxy >> nbit_man);
    mxgey = 0x1ULL & (myx >> nbit_man);
    if ((mxgey == 0) && (mygex == 0))
	mxeqy = 1;
    else
	mxeqy = 0;

    exy = ((0x1ULL << (nbit_exp + 1)) - 1) & (exp_x - exp_y);
    eyx = ((0x1ULL << (nbit_exp + 1)) - 1) & (exp_y - exp_x);
    eygex = (0x1ULL & (exy >> nbit_exp));
    exgey = (0x1ULL & (eyx >> nbit_exp));
    if ((exgey == 0) && (eygex == 0))
	exeqy = 1;
    else
	exeqy = 0;

    // set expdif
    if (eygex == 1)
	*expdif = (((0x1ULL << nbit_exp) - 1) & eyx);
    else
	*expdif = (((0x1ULL << nbit_exp) - 1) & exy);

    // set is_xeqy
    *is_xeqy = exeqy & mxeqy & nonzx & nonzy;

    // set nontobi
    if ((nonzx == 1) && (nonzy == 1))
	*nontobi = 0x1ULL;
    else
	*nontobi = 0x0ULL;

    // set nygex
    if ((nonzx == 0) && (nonzy == 1))
	nygex = 0x1ULL;
    else
	nygex = 0x0ULL;

    // set flag0
    if (exeqy == 1)
	flag0 = mygex;
    else
	flag0 = eygex;

    // set flag1
    if (*nontobi == 0)
	flag1 = nygex;
    else
	flag1 = flag0;

    // swap
    if (flag1 == 0) {
	*expz = expx;		// nbit_exp -bit
	*mana = manx;		// nbit_man -bit
	*manb = many;		// nbit_man -bit
	*signz = signx;
    } else {
	*expz = expy;		// nbit_exp -bit
	*mana = many;		// nbit_man -bit
	*manb = manx;		// nbit_man -bit
	*signz = 0x1ULL ^ signy;
    }
}

static void
pgsub_float_usub_adjust(int nbit_man, LONG x, int npenc, LONG * man,
			LONG * Sbit)
{
    LONG            z;
    int             shift = npenc - nbit_man - 1;
    LONG            msk = (0x1ULL << (nbit_man + 1)) - 1;
    if (shift < 0) {
	z = msk & (x << (-shift));
    } else {
	z = msk & (x >> shift);
    }
    // z : nbit_man+1 : 0.XXXX,Sbit
    *man = ((0x1ULL << nbit_man) - 1) & (z >> 1);
    *Sbit = 0x1ULL & z;
}

#ifndef PGSUB_PENC
#define PGSUB_PENC 1
/*
 * PRIORITY ENCODER 
 */
static void
penc(LONG x, int *penc_out)
{
    int             i;
    int             count = 0;
    for (i = 63; i >= 0; i--) {
	LONG            buf;
	buf = 0x1ULL & (x >> i);
	if (buf == 0x1ULL) {
	    count = i;
	    break;
	}
	count = i;
    }
    *penc_out = count;		/* X-bit */
}
#endif

/*
 * GUARD 
 */
static void
pgsub_float_usub_guard(int nbit_man, int npenc, LONG man, LONG * Gbit)
{
    LONG            guard;
    int             nguard = npenc - nbit_man - 1;
    if (nguard > 0) {
	LONG            mask;
	mask = (0x1ULL << (nguard)) - 1;
	guard = mask & man;
    } else {
	guard = 0;
    }
    if (guard != 0)
	*Gbit = 1;
    else
	*Gbit = 0;
}

static void
pgsub_float_unpack(int nbit_float, int nbit_man, LONG x,	// nbit_float 
								// bit
		   LONG y,	// nbit_float bit
		   LONG * signx,	// 1-bit
		   LONG * signy,	// 1-bit
		   LONG * nonzx,	// 1-bit
		   LONG * nonzy,	// 1-bit
		   LONG * expx,	// 2's complement : nbit_exp bit
		   LONG * expy,	// 2's complement : nbit_exp bit
		   LONG * manx,	// economic expression : nbit_man bit
		   LONG * many)	// economic expression : nbit_man bit
{
    int             nbit_exp = nbit_float - nbit_man - 2;
    // extract sign bit
    *signx = 0x1ULL & (x >> (nbit_float - 1));
    *signy = 0x1ULL & (y >> (nbit_float - 1));
    // extract non-zero bit
    *nonzx = 0x1ULL & (x >> (nbit_float - 2));
    *nonzy = 0x1ULL & (y >> (nbit_float - 2));
    // extract exponent
    *expx = ((0x1ULL << nbit_exp) - 1) & (x >> nbit_man);
    *expy = ((0x1ULL << nbit_exp) - 1) & (y >> nbit_man);
    // extract mantissa
    *manx = ((0x1ULL << nbit_man) - 1) & x;
    *many = ((0x1ULL << nbit_man) - 1) & y;
}

static void
pgsub_float_reva(int rmode,	// rounding mode
		 LONG Fbit,	// sign bit
		 LONG Ulp,	// Unit in the last place
		 LONG Sbit,	// Sticky bit
		 LONG Gbit,	// Guard bit
		 LONG * man_inc)	// 0 or 1;
{
    if (rmode == 0)
	*man_inc = 0;		/* Truncation */
    else if (rmode == 1)
	*man_inc = Fbit * (1 - (1 - Sbit) * (1 - Gbit));	/* Truncation 
								 * to Zero 
								 */
    else if (rmode == 2)
	*man_inc = Sbit;	/* Rounding to Plus Infinity */
    else if (rmode == 3)
	*man_inc = Sbit * Gbit;	/* Rounding to Minus Infinity */
    else if (rmode == 4)
	*man_inc = Sbit * (1 - Fbit * (1 - Gbit));	/* Rounding to
							 * Infinity */
    else if (rmode == 5)
	*man_inc = Sbit * (1 - (1 - Fbit) * (1 - Gbit));	/* Rounding 
								 * to Zero 
								 */
    else if (rmode == 6)
	*man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding to
							 * Even */
    else if (rmode == 7)
	*man_inc = Sbit * (1 - Ulp * (1 - Gbit));	/* Rounding to Odd 
							 */
    else if (rmode == 8)
	*man_inc = Sbit + Gbit;	/* Force one */
    else
	*man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding to
							 * Even */
}

static void     pgsub_float_rounding_normalize(	// 26,16,expz,manz,man_inc,&expzr,&manzr);
						  int nbit_float, int nbit_man, LONG expz,	// nbit_exp 
												// -bit
						  LONG manz,	// nbit_man 
								// -bit
								// (economic 
								// expression)
						  LONG man_inc,	// 1 -bit
						  LONG * expzr,	// nbit_exp 
								// -bit
						  LONG * manzr)	// nbit_man 
								// -bit
								// (economic 
								// expression)
{
    int             nbit_exp = nbit_float - nbit_man - 2;
    LONG            madd =
	((0x1ULL << (nbit_man + 1)) - 1) & (manz + man_inc);
    LONG            cout = 0x1ULL & (madd >> nbit_man);
    LONG            expz0;
    LONG            manz0;
    if (cout == 1ULL) {
	expz0 = ((0x1ULL << nbit_exp) - 1) & (expz + 0x1ULL);
	manz0 = 0x0ULL;
    } else {
	expz0 = expz;
	manz0 = ((0x1ULL << nbit_man) - 1) & madd;
    }
    *expzr = expz0;
    *manzr = manz0;
}
#endif
// ----------------------------------------------------- SUB-MODULE FOR
// FLOAT_UNSIGNED_SUB (END)
// PGR Floating-Point Unsigned Subtractor 
// by N.Nakasato (2004/08/23) 
// by T.Hamada (2004/09/06) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// Format ---------------------------------------------------------
// | sign bit[25] | nonz bit[24] | exp bit[23..16] | man bit[15..0]
// ----------------------------------------------------------------
// (1)This operation can't handle exceptions like 
// (+/-)inf, NaN and denormalized numbers.  
// (2)Exponent is not biased.  
// (3)(+/-)Zero means: nonz bit == 0 
void
pg_float_unsigned_sub_26_16(LONG opx, LONG opy, LONG * result)
{
    LONG            x, y, z;
    LONG            nonzx, nonzy, nonzz;
    LONG            signx, signy, signz;
    LONG            expx, expy;
    LONG            manx, many;
    LONG            expdif;	/* abs(expx-expy) */
    LONG            mana;	/* Winner(manx,many) */
    LONG            manb;	/* Loser(manx,many) */
    LONG            expz;
    LONG            manz = 0;
    LONG            Ulp, Sbit, Gbit;
    LONG            man_inc;
    LONG            manzr;
    LONG            expzr;
    LONG            is_xeqy;
    LONG            nontobi;
    LONG            eflag;	// 1: expdif < 18, 0: expdif >= 18
    LONG            is_tobi;

    x = (LONG) opx;
    y = (LONG) opy;

    // unpack pgpgfloat //////////////////////////////////////////////////
    pgsub_float_unpack(26, 16, x, y,
		       &signx, &signy,
		       &nonzx, &nonzy, &expx, &expy, &manx, &many);
    // ///////////////////////////////////////////////////////////////////

    nonzz = nonzx | nonzy;

    pgsub_float_usub_swap(26, 16,
			  signx, signy, nonzx, nonzy, expx, expy, manx,
			  many, &expdif, &expz, &mana, &manb, &nontobi,
			  &signz, &is_xeqy);

    // shift and subtract
    if (expdif < 18)
	eflag = 1;
    else
	eflag = 0;
    is_tobi = 0x1ULL ^ (eflag & nontobi);	// eflag NAND nontobi
    if (is_tobi == 1) {
	Sbit = 0;
	Gbit = 1;
	manz = 0xFFFFULL & mana;
    } else {
	int             npenc;
	LONG            manb_s;
	LONG            tmp3;
	// SHIFT bits
	// input : expdif : (log(nbit_man+1)/log(2))
	// input : manb : nbit_man
	// output : manb_s : nbit_man+4 , 1.XXXXSSG
	pgsub_float_usub_shift_manb(16, expdif, manb, &manb_s);
	manb_s &= 0xFFFFFULL;

	// SUBTRACTION 
	tmp3 = ((0x10000ULL | mana) << 3) - manb_s;
	tmp3 &= 0xFFFFFULL;	// nbit_man+4

	penc(tmp3, &npenc);	// penc : 0x10000 -> 16, 0x8000 -> 15, ...
	pgsub_float_usub_guard(16, npenc, tmp3, &Gbit);	// Gbit
	pgsub_float_usub_adjust(16, tmp3, npenc, &manz, &Sbit);	// adjust

	// subtract exponent with biasing 
	{
	    LONG            exp_inc;	// 5-bit because exp_inc is always 
					// >=0.
	    LONG            exp_z;
	    exp_inc = 0x1FULL & (LONG) (19 - npenc);	// 5-bit because
							// exp_inc is
							// always >=0.
	    exp_z = (0x80ULL) ^ expz;
	    exp_z = exp_z - exp_inc;
	    expz = (0x80ULL) ^ exp_z;
	}
    }
    manz &= 0xFFFFULL;
    expz &= 0xFFULL;
    // unit in the last place
    Ulp = 0x1ULL & manz;
    // begin Rounding Operation
    // ///////////////////////////////////////////////////////////////////////
    pgsub_float_reva(6, signz, Ulp, Sbit, Gbit, &man_inc);	// Rounding 
								// Evaluation
    man_inc &= nontobi;
    pgsub_float_rounding_normalize(26, 16, expz, manz, man_inc, &expzr, &manzr);	// Do 
											// Rounding 
											// and 
											// Normalize
    // end Rounding Operation
    // /////////////////////////////////////////////////////////////////////////

    // compose pgpgfloat
    nonzz &= (0x1ULL ^ is_xeqy);
    z = (signz << 25) | (nonzz << 24) | (expzr << 16) | manzr;

    (*result) = z;
}

// ----------------------------------------------------------- : No. 2
// PGR Floating-Point Sub 
// by N.Nakasato (2004/08/30) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// Format ---------------------------------------------------------
// | sign bit[25] | nonz bit[24] | exp bit[23..16] | man bit[15..0]
// ----------------------------------------------------------------
// (1)This operation can't handle exceptions like 
// (+/-)inf, NaN and denormalized numbers.  
// (2)Exponent is not biased.  
// (3)(+/-)Zero means: nonz bit == 0 
void
pg_float_sub_26_16(LONG opx, LONG opy, LONG * result)
{
    LONG            x, y;
    LONG            nonzx, nonzy;
    LONG            signx, signy;
    LONG            expx, expy;
    LONG            manx, many;

    x = (LONG) opx;
    y = (LONG) opy;

    // begin unpack pgpgfloat
    // //////////////////////////////////////////////////
    // extract sign bit
    signx = 0x1ULL & (x >> 25);
    signy = 0x1ULL & (y >> 25);

    // extract non-zero bit
    nonzx = 0x1ULL & (x >> 24);
    nonzy = 0x1ULL & (y >> 24);

    // extract exponent
    expx = 0xFFULL & (x >> 16);
    expy = 0xFFULL & (y >> 16);

    // extract mantissa
    manx = 0xFFFFULL & x;
    many = 0xFFFFULL & y;
    // end unpack pgpgfloat
    // //////////////////////////////////////////////////

    if (signx == signy) {
	pg_float_unsigned_sub_26_16(x, y, result);
    } else {
	LONG            xx, yy;
	if (signx == 0ULL) {
	    yy = (0ULL << 25) | (nonzy << 24) | (expy << 16) | many;
	    pg_float_unsigned_add_26_16(x, yy, result);
	} else {
	    xx = (1ULL << 25) | (nonzx << 24) | (expx << 16) | manx;
	    pg_float_unsigned_add_26_16(xx, y, result);
	}
    }

}

// ----------------------------------------------------------- : No. 3
// PGR Floating-Point Multiplier 
// by N. Nakasato (2004/8/23) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// nbit_exp : 8-bit 
void
pg_float_mult_26_16(LONG opx, LONG opy, LONG * result)
{
    LONG            x, y, z;
    LONG            nonzx, nonzy, nonzz;
    LONG            signx, signy, signz;
    LONG            expx, expy, expz;
    LONG            manx, many, manz;
    LONG            Ulp, Sbit, Gbit;
    LONG            exp_inc;

    x = (LONG) opx;
    y = (LONG) opy;
    // begin unpack pgpgfloat
    // //////////////////////////////////////////////////
    // extract sign bit
    signx = 0x1ULL & (x >> 25);
    signy = 0x1ULL & (y >> 25);

    // extract non-zero bit
    nonzx = 0x1ULL & (x >> 24);
    nonzy = 0x1ULL & (y >> 24);

    // extract exponent
    expx = 0xFFULL & (x >> 16);
    expy = 0xFFULL & (y >> 16);

    // extract mantissa
    manx = 0xFFFFULL & x;
    many = 0xFFFFULL & y;
    // end unpack pgpgfloat
    // //////////////////////////////////////////////////

    // flip hidden top-bit
    manx |= (0x1ULL << 16);
    many |= (0x1ULL << 16);

    // compute signz
    signz = 0x1ULL & (signx ^ signy);
    // compute non-zero bit
    nonzz = nonzx * nonzy;	// nonzz<= nonzx AND nonzy
    /*
     * Multiplier for mantissa 
     */
    manz = 0x3FFFFFFFFULL & (manx * many);	/* 34-bit */
    /*
     * Adder for exponent 
     */
    expz = 0xFFULL & (expx + expy);	/* Ignore overflow and biasing */
    /*
     * Store Ulp, Sbit, Gbit and exp_inc 
     */
    {
	LONG            muloh2b;	/* Top 2-bit of multiplier's
					 * outdata */
	LONG            nman;
	muloh2b = 0x3ULL & (manz >> 32);
	nman = 16;
	if (muloh2b == 0x1) {	/* If mult-result is "01.X,,X" */
	    exp_inc = 0;
	    Ulp = 0x1ULL & (manz >> nman);
	    Sbit = 0x1ULL & (manz >> (nman - 1));
	    if ((0x7FFFULL & manz) == 0)
		Gbit = 0;
	    else
		Gbit = 1;
	} else {		/* If mult-result is "1X.X,,X" */
	    exp_inc = 1;
	    Ulp = 0x1ULL & (manz >> (nman + 1));
	    Sbit = 0x1ULL & (manz >> nman);
	    if ((0xFFFFULL & manz) == 0)
		Gbit = 0;
	    else
		Gbit = 1;
	}
    }

    /*
     * manz Shift and Truncate 
     */
    if (exp_inc == 0)
	manz = 0xFFFFULL & (manz >> 16);
    else
	manz = 0xFFFFULL & (manz >> 17);

    /*
     * Rounding 
     */
    {
	LONG            man_inc;
	int             rmode = 6;
	if (rmode == 0)
	    man_inc = 0;	/* Truncation */
	else if (rmode == 1)
	    man_inc = signz * (1 - (1 - Sbit) * (1 - Gbit));	/* Truncation 
								 * to Zero 
								 */
	else if (rmode == 2)
	    man_inc = Sbit;	/* Rounding to Plus Infinity */
	else if (rmode == 3)
	    man_inc = Sbit * Gbit;	/* Rounding to Minus Infinity */
	else if (rmode == 4)
	    man_inc = Sbit * (1 - signz * (1 - Gbit));	/* Rounding to
							 * Infinity */
	else if (rmode == 5)
	    man_inc = Sbit * (1 - (1 - signz) * (1 - Gbit));	/* Rounding 
								 * to Zero 
								 */
	else if (rmode == 6)
	    man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding 
								 * to Even 
								 */
	else if (rmode == 7)
	    man_inc = Sbit * (1 - Ulp * (1 - Gbit));	/* Rounding to Odd 
							 */
	else if (rmode == 8)
	    man_inc = Sbit + Gbit;	/* Force one */
	else
	    man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding 
								 * to Even 
								 */
	/*
	 * Adder with overflow-flag 
	 */
	manz = 0x1FFFFULL & (manz + man_inc);
	/*
	 * Check the overflow-flag 
	 */
	if ((0x1ULL & (manz >> 16)) == 0x1ULL)
	    exp_inc++;
	manz &= 0xFFFFULL;
    }

    /*
     * Exp increase. Be sure that 00,01 and 10 are the candidate for
     * exp_inc 
     */
    expz = 0xFFULL & (expz + exp_inc);	/* Ignore overflow */

    if (nonzz == 0) {
	expz = 0;
	manz = 0;
    }
    // compose pgpgfloat format 
    z = (signz << 25) | (nonzz << 24) | (expz << 16) | manz;
    (*result) = z;
}

// ----------------------------------------------------------- : No. 4
// ----------------------------------------------------- SUB-MODULE FOR
// FLOAT_SQRT (BEGIN)
#ifndef PG_FLOAT_SQRT
#define PG_FLOAT_SQRT 1
static double
cheb_func_sqrt(double x)
{
    double          f;
    f = sqrt(x);
    return f;
}
#define PI 3.1415926535897932384
static void
calc_chebyshev_coefficient_sqrt(	// same as pg_float_recipro
				   int n,
				   double xk_min,
				   double xk_max, double coef[])
{
    int             k, j;

    double          fac, bpa, bma;
    double          f[10], c[10];
    double          cheb_func_sqrt(double);
    bma = 0.5 * (xk_max - xk_min);
    bpa = 0.5 * (xk_max + xk_min);
    for (k = 0; k < n; k++) {
	double          y = cos(PI * (k + 0.5) / n);
	f[k] = cheb_func_sqrt(y * bma + bpa);
    }
    fac = 2.0 / n;
    for (j = 0; j < n; j++) {
	double          sum = 0.0;
	for (k = 0; k < n; k++)
	    sum += f[k] * cos(PI * j * (k + 0.5) / n);
	c[j] = fac * sum;
    }

    if (n == 2) {
	coef[0] = (0.5 * c[0] - c[1]);
	coef[1] = c[1] / bma;
    } else if (n == 3) {
	coef[0] = (0.5 * c[0] - c[1] + c[2]);
	coef[1] = (c[1] - 4.0 * c[2]) / bma;
	coef[2] = 2.0 * c[2] / (bma * bma);
    } else if (n == 4) {
	coef[0] = (0.5 * c[0] - c[1] + c[2] - c[3]);
	coef[1] = (c[1] - 4.0 * c[2] + 9.0 * c[3]) / bma;
	coef[2] = (2.0 * c[2] - 12.0 * c[3]) / (bma * bma);
	coef[3] = (4.0 * c[3]) / (bma * bma * bma);
    }
}
#undef PI
void
pgsub_float_sqrt_table_2nd(int nman, int ncut, int next, LONG x, LONG * z)
{
    LONG            indata, adr, dx, f;
    LONG            rom[10];
    int             nord = 2;
    indata = ((0x1ULL << (nman + 2)) - 1) & x;	// 1.0 < x < 4.0,
						// x(msb..msb-1)= "01" or
						// "10" or "11" not "00" !
    adr = indata >> ncut;
    dx = ((0x1ULL << ncut) - 1) & indata;
    {
	int             n;
	double          xk_min, xk_max;
	double          coef[10];
	xk_min = (double) (adr << ncut);
	xk_max = (double) (((adr + 0x1ULL) << ncut) - 0x1ULL);
	xk_min = 0.0 + ((xk_min + 0.25) / (double) (0x1ULL << nman));
	xk_max = 0.0 + ((xk_max + 0.25) / (double) (0x1ULL << nman));
	n = nord + 1;
	calc_chebyshev_coefficient_sqrt(n, xk_min, xk_max, coef);
	coef[2] *= -1.0;
	rom[0] =
	    (LONG) (coef[0] * powl(2.0, (double) (nman + next)) + 0.875);
	rom[1] =
	    (LONG) (coef[1] * powl(2.0, (double) (nman + next)) + 0.125);
	rom[2] =
	    (LONG) (coef[2] * powl(2.0, (double) (nman + next)) - 0.125);
	rom[0] &= (0x1ULL << (nman + next + 1)) - 1;
	rom[1] &= (0x1ULL << (nman + next - 1)) - 1;
	rom[2] &= (0x1ULL << (nman + next - 3)) - 1;
    }

    {
	LONG            dx2, mula, mulb;
	dx2 = (dx * dx) >> nman;
	dx2 &= (0x1ULL << ncut) - 1;
	mula = (rom[1] * dx) >> nman;
	{			// (4) (12) (2)
	    // .0000BBBBBBBBBBBB00 : dx
	    // .0000BBBBBBBBBBBBEE : (rom[1]*dx)>>nman
	    int             nbit_mula = ncut + next;
	    mula &= (0x1ULL << nbit_mula) - 1;
	}
	mulb = rom[2] * dx2 >> nman;
	{			// (4*2) (12-4) (2)
	    // .00000000BBBBBBBB00 : dx2
	    // .00000000BBBBBBBBEE : (rom[2]*dx2)>>nman
	    int             nbit_mulb = ncut + next - (nman - ncut);
	    mulb &= (0x1ULL << nbit_mulb) - 1;
	}
	f = rom[0] + mula - mulb;	// (NMAN+NEXT) bit
    }

    f &= (0x1ULL << (nman + next + 2)) - 1;	// 1.0 < f <= 2.0 ,
						// f(msb..msb-1) = "10" or 
						// "01" 
    *z = f;			// TABLE OUTPUT : (nman+next+2)-bit
}

#ifndef PGSUB_FLOAT_UNPACK_S
#define PGSUB_FLOAT_UNPACK_S 1
static void
pgsub_float_unpack_s(		// single unpack
			int nbit_float, int nbit_man, LONG x,	// nbit_float 
								// bit
			LONG * signx,	// 1-bit
			LONG * nonzx,	// 1-bit
			LONG * expx,	// 2's complement : nbit_exp bit
			LONG * manx)	// economic expression : nbit_man
					// bit
{
    int             nbit_exp = nbit_float - nbit_man - 2;
    // extract sign bit
    *signx = 0x1ULL & (x >> (nbit_float - 1));
    // extract non-zero bit
    *nonzx = 0x1ULL & (x >> (nbit_float - 2));
    // extract exponent
    *expx = ((0x1ULL << nbit_exp) - 1) & (x >> nbit_man);
    // extract mantissa
    *manx = ((0x1ULL << nbit_man) - 1) & x;
}
#endif
#endif
// ----------------------------------------------------- SUB-MODULE FOR
// FLOAT_SQRT (END)
// PGR Floating-Point SquareRoot 
// by T.Hamada (2004/09/26) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// Format ---------------------------------------------------------
// | sign bit[25] | nonz bit[24] | exp bit[23..16] | man bit[15..0]
// ----------------------------------------------------------------
// (1)This operation can't handle exceptions like 
// (+/-)inf, NaN and denormalized numbers.  
// (2)Exponent is not biased.  
// (3)(+/-)Zero means: nonz bit == 0 
void
pg_float_sqrt_26_16(LONG opx, LONG * result)
{
    LONG            x, z;
    LONG            nonzz;
    LONG            signz;
    LONG            expx;
    LONG            manx;
    LONG            expz;
    LONG            manz0, manz;
    LONG            is_one;
    LONG            emsb, elsb;

    x = (LONG) opx;
    pgsub_float_unpack_s(26, 16, x, &signz, &nonzz, &expx, &manx);

    is_one = ((manx == 0x0ULL) ? 1 : 0);
    manx |= (0x1ULL << 16);

    elsb = 0x1ULL & expx;
    emsb = 0x1ULL & (expx >> 7);

    if (elsb == 0) {		// Even
	expz = ((0x1ULL << 8) - 1) & (expx >> 1);
	expz |= (emsb << 7);
    } else {			// Odd
	LONG            expodd;
	expodd = ((0x1ULL << 8) - 1) & (expx - 0x1ULL);
	expz = ((0x1ULL << 8) - 1) & (expodd >> 1);
	expz |= (emsb << 7);
	manx = (manx << 1) | 0x1ULL;
	is_one = 0;		// !! 1.0< manx <2.0 !!
    }

    {
	int             nbit_man = 16;
	int             nbit_ext = 2;
	int             nbit_cut = 14;
	LONG            is_two;
	LONG            mz;	// (nbit_man+nbit_ext+2)-bit ( 1.0 < mz <= 
				// 2.0 )
	pgsub_float_sqrt_table_2nd(nbit_man, nbit_cut, nbit_ext, manx,
				   &mz);
	is_two = mz >> (nbit_man + nbit_ext + 1);
	if (is_two == 1) {
	    mz = 0x0ULL;
	    expz++;
	}
	manz0 = mz >> nbit_ext;	// Normalize
	manz0 = ((0x1ULL << nbit_man) - 1) & manz0;	// Rounding
							// (nanchatte
							// force-1)
    }

    // --- SELECT MANTISSA ---
    if (is_one == 1) {
	manz = 0x0ULL;
    } else {
	manz = manz0;
    }

    // compose pgpgfloat
    z = (signz << 25) | (nonzz << 24) | (expz << 16) | manz;

    (*result) = z;
}

// ----------------------------------------------------------- : No. 5
// ----------------------------------------------------- SUB-MODULE FOR
// FLOAT_RECIPRO (BEGIN)
#ifndef PG_FLOAT_RECIPRO
#define PG_FLOAT_RECIPRO 1
static double
cheb_func(double x)
{
    double          f;
    f = 1.0 / x;
    return f;
}
#define PI 3.1415926535897932384
static void
calc_chebyshev_coefficient(int n,
			   double xk_min, double xk_max, double coef[])
{
    int             k, j;

    double          fac, bpa, bma;
    double          f[10], c[10];
    double          cheb_func(double);
    bma = 0.5 * (xk_max - xk_min);
    bpa = 0.5 * (xk_max + xk_min);
    for (k = 0; k < n; k++) {
	double          y = cos(PI * (k + 0.5) / n);
	f[k] = cheb_func(y * bma + bpa);
    }
    fac = 2.0 / n;
    for (j = 0; j < n; j++) {
	double          sum = 0.0;
	for (k = 0; k < n; k++)
	    sum += f[k] * cos(PI * j * (k + 0.5) / n);
	c[j] = fac * sum;
    }

    if (n == 2) {
	coef[0] = (0.5 * c[0] - c[1]);
	coef[1] = c[1] / bma;
    } else if (n == 3) {
	coef[0] = (0.5 * c[0] - c[1] + c[2]);
	coef[1] = (c[1] - 4.0 * c[2]) / bma;
	coef[2] = 2.0 * c[2] / (bma * bma);
    } else if (n == 4) {
	coef[0] = (0.5 * c[0] - c[1] + c[2] - c[3]);
	coef[1] = (c[1] - 4.0 * c[2] + 9.0 * c[3]) / bma;
	coef[2] = (2.0 * c[2] - 12.0 * c[3]) / (bma * bma);
	coef[3] = (4.0 * c[3]) / (bma * bma * bma);
    }
}
#undef PI
void
pgsub_float_recipro_table_2nd(int nman,
			      int ncut, int next, LONG x, LONG * z)
{
    LONG            indata, adr, dx, f;
    LONG            rom[10];
    int             nord = 2;
    indata = ((0x1ULL << nman) - 1) & x;
    adr = indata >> ncut;
    dx = ((0x1ULL << ncut) - 1) & indata;
    {
	int             i, n;
	double          xk_min, xk_max;
	double          coef[10];
	xk_min = (double) (adr << ncut);
	xk_max = (double) (((adr + 0x1ULL) << ncut) - 0x1ULL);
	xk_min = 1.0 + ((xk_min + 0.25) / (double) (0x1ULL << nman));
	xk_max = 1.0 + ((xk_max + 0.25) / (double) (0x1ULL << nman));
	n = nord + 1;
	calc_chebyshev_coefficient(n, xk_min, xk_max, coef);
	coef[1] *= -1.0;
	coef[3] *= -1.0;
	rom[0] =
	    (LONG) (coef[0] * powl(2.0, (double) (nman + next)) + 0.875);
	rom[1] =
	    (LONG) (coef[1] * powl(2.0, (double) (nman + next)) - 0.125);
	rom[2] =
	    (LONG) (coef[2] * powl(2.0, (double) (nman + next)) + 0.0);
	for (i = 0; i < n; i++) {
	    rom[i] &= (0x1ULL << (nman + next)) - 1;
	}
    }

    {
	LONG            dx2, mula, mulb;
	dx2 = (dx * dx) >> nman;
	dx2 &= (0x1ULL << ncut) - 1;
	mula = (rom[1] * dx) >> nman;
	{			// (4) (12) (2)
	    // .0000BBBBBBBBBBBB00 : dx
	    // .0000BBBBBBBBBBBBEE : (rom[1]*dx)>>nman
	    int             nbit_mula = ncut + next;
	    mula &= (0x1ULL << nbit_mula) - 1;
	}
	mulb = rom[2] * dx2 >> nman;
	{			// (4*2) (12-4) (2)
	    // .00000000BBBBBBBB00 : dx2
	    // .00000000BBBBBBBBEE : (rom[2]*dx2)>>nman
	    int             nbit_mulb = ncut + next - (nman - ncut);
	    mulb &= (0x1ULL << nbit_mulb) - 1;
	}
	f = rom[0] - mula + mulb;	// (NMAN+NEXT) bit
    }

    f &= (0x1ULL << (nman + next)) - 1;
    *z = f;			// TABLE OUTPUT : (nman+next)-bit
}

#ifndef PGSUB_FLOAT_UNPACK_S
#define PGSUB_FLOAT_UNPACK_S 1
static void
pgsub_float_unpack_s(		// single unpack
			int nbit_float, int nbit_man, LONG x,	// nbit_float 
								// bit
			LONG * signx,	// 1-bit
			LONG * nonzx,	// 1-bit
			LONG * expx,	// 2's complement : nbit_exp bit
			LONG * manx)	// economic expression : nbit_man
					// bit
{
    int             nbit_exp = nbit_float - nbit_man - 2;
    // extract sign bit
    *signx = 0x1ULL & (x >> (nbit_float - 1));
    // extract non-zero bit
    *nonzx = 0x1ULL & (x >> (nbit_float - 2));
    // extract exponent
    *expx = ((0x1ULL << nbit_exp) - 1) & (x >> nbit_man);
    // extract mantissa
    *manx = ((0x1ULL << nbit_man) - 1) & x;
}
#endif
#endif
// ----------------------------------------------------- SUB-MODULE FOR
// FLOAT_RECIPRO (END)
// PGR Floating-Point Reciprocator 
// by T.Hamada (2004/09/24) 
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// Format ---------------------------------------------------------
// | sign bit[25] | nonz bit[24] | exp bit[23..16] | man bit[15..0]
// ----------------------------------------------------------------
// (1)This operation can't handle exceptions like 
// (+/-)inf, NaN and denormalized numbers.  
// (2)Exponent is not biased.  
// (3)(+/-)Zero means: nonz bit == 0 
void
pg_float_recipro_26_16(LONG opx, LONG * result)
{
    LONG            x, z;
    LONG            nonzz;
    LONG            signz;
    LONG            expx;
    LONG            expinv;
    LONG            expm;
    LONG            manx;
    LONG            expz;
    LONG            manz0, manz;
    LONG            is_one;

    x = (LONG) opx;
    pgsub_float_unpack_s(26, 16, x, &signz, &nonzz, &expx, &manx);
    expinv = 0xFFULL & (0x0ULL - expx);
    is_one = ((manx == 0x0ULL) ? 1 : 0);
    expm = 0xFFULL & (expinv - 0x1ULL);

    {
	int             nbit_man = 16;
	int             nbit_ext = 2;
	int             nbit_cut = 12;
	LONG            mz;	// (nbit_man+nbit_ext)-bit ( 0.5 <= mz <
				// 1.0 )
	pgsub_float_recipro_table_2nd(nbit_man, nbit_cut, nbit_ext, manx,
				      &mz);
	manz0 = mz >> (nbit_ext - 1);	// Normalize
	manz0 = ((0x1ULL << nbit_man) - 1) & (manz0 | 0x1ULL);	// Roundingt 
								// (nanchatte 
								// force-1)
    }

    // --- SELECT EXPONENT ---
    if (is_one == 1) {
	expz = expinv;
    } else {
	expz = expm;
    }

    // --- SELECT MANTISSA ---
    if (is_one == 1) {
	manz = 0x0ULL;
    } else {
	manz = manz0;
    }

    // compose pgpgfloat
    z = (signz << 25) | (nonzz << 24) | (expz << 16) | manz;

    (*result) = z;
}

// ----------------------------------------------------------- : No. 6
// PGR Floating-Point ExpAdd
// exp add (31)
void
pg_float_expadd_31_26_16(LONG x, LONG * z)
{
    LONG            signz, nonzz, manz;
    LONG            expx, expz, eadd;
    signz = 0x1ULL & (x >> 25);
    nonzz = 0x1ULL & (x >> 24);
    expx = 0xFFULL & (x >> 16);
    manz = 0xFFFFULL & x;
    eadd = 0x1fULL;		// 31
    expz = 0xFFULL & (expx + eadd);
    *z = (signz << 25) | (nonzz << 24) | (expz << 16) | manz;
}

// ----------------------------------------------------------- : No. 7
// PGR Floating-Point FixAccumulator
// by T. Hamada (2004/10/30)
// nbit_float : 26-bit 
// nbit_man : 16-bit 
// round mode : 0 
// Format ---------------------------------------------------------
// | sign bit[25] | nonz bit[24] | exp bit[23..16] | man bit[15..0]
// ----------------------------------------------------------------
// (1)This operation can't handle exceptions like
// (+/-)inf, NaN and denormalized numbers.
// (2)Exponent is not biased.
// (3)(+/-)Zero means: nonz bit == 0
void
pg_float_fixaccum_26_16_57_64(LONG x, LONG * z)
{
    LONG            fx, sx;
    void            pg_conv_floattofix_26_16_57(LONG x, LONG * z);
    void            pg_fix_smaccum_f57_s64(LONG x, LONG * z);
    sx = (*z);

    pg_conv_floattofix_26_16_57(x, &fx);
    pg_fix_smaccum_f57_s64(fx, &sx);
    *z = sx;
}

// ----------------------------------------------------------- : No. 8
/*
 * PGR Floating-Point to Fixed-Point Format Converter 
 */
/*
 * by Tsuyoshi Hamada (2002/07) 
 */
/*
 * nbit_float : 26-bit 
 */
/*
 * nbit_man : 16-bit 
 */
/*
 * nbit_fix : 57-bit 
 */
void
pg_conv_floattofix_26_16_57(LONG x, LONG * z)
{
    LONG            signz, nonzx, expx, manx;
    LONG            erase, nshift;
    LONG            ovflow = 0;
    LONG            mansf;
    LONG            zfix;
    LONG            man_inc;
    LONG            Sbit, Gbit, Ulp;

    signz = 0x1ULL & (x >> 25);
    nonzx = 0x1ULL & (x >> 24);
    expx = 0xFFULL & (x >> 16);
    manx = (0x1ULL << 16) | (0xFFFFULL & x);

    erase = 0x1ULL & (expx >> 7);
    nshift = 0x7FULL & expx;

    // LEFT SHIFT
    if (nshift < 57) {
	if (nshift >= 16) {
	    mansf = manx << (nshift - 16);
	} else {
	    mansf = manx >> (16 - nshift);
	}
    } else {
	mansf = 0x0ULL;
	ovflow = 1;
    }

    // Guard
    if (nshift > 16) {
	Ulp = 0;
	Sbit = 0;
	Gbit = 0;
    } else if (nshift == 16) {
	Ulp = 0x1ULL & manx;
	Sbit = 0;
	Gbit = 0;
    } else if (nshift == (16 - 1)) {
	Ulp = 0x1ULL & (manx >> 1);
	Sbit = 0x1ULL & manx;
	Gbit = 0x0ULL;
    } else {			// if(nshift < (16-1)){
	int             nbit_guard = 16 - nshift - 1;	// bit-length for
							// guard (Sbit
							// hazusu)
	Ulp = 0x1ULL & (manx >> (nbit_guard + 1));
	Sbit = 0x1ULL & (manx >> (nbit_guard));
	if ((((0x1ULL << (nbit_guard)) - 1) & manx) == 0x0)
	    Gbit = 0x0ULL;
	else
	    Gbit = 0x1ULL;
    }

    /*
     * Generate Rounding bit (man_inc)
     */
    /*
     * input : signz ( 0 : 0 ) 
     */
    /*
     * input : Ulp ( 0 : 0 ) 
     */
    /*
     * input : Sbit ( 0 : 0 ) 
     */
    /*
     * input : Gbit ( 0 : 0 ) 
     */
    /*
     * output : man_inc ( 0 : 0 )
     */
    {
	int             rmode = 0;
	if (rmode == 0)
	    man_inc = 0;	/* Truncation */
	else if (rmode == 1)
	    man_inc = signz * (1 - (1 - Sbit) * (1 - Gbit));	/* Truncation 
								 * to Zero 
								 */
	else if (rmode == 2)
	    man_inc = Sbit;	/* Rounding to Plus Infinity */
	else if (rmode == 3)
	    man_inc = Sbit * Gbit;	/* Rounding to Minus Infinity */
	else if (rmode == 4)
	    man_inc = Sbit * (1 - signz * (1 - Gbit));	/* Rounding to
							 * Infinity */
	else if (rmode == 5)
	    man_inc = Sbit * (1 - (1 - signz) * (1 - Gbit));	/* Rounding 
								 * to Zero 
								 */
	else if (rmode == 6)
	    man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding 
								 * to Even 
								 */
	else if (rmode == 7)
	    man_inc = Sbit * (1 - Ulp * (1 - Gbit));	/* Rounding to Odd 
							 */
	else if (rmode == 8)
	    man_inc = Sbit + Gbit;	/* Force one */
	else
	    man_inc = Sbit * (1 - (1 - Ulp) * (1 - Gbit));	/* Rounding 
								 * to Even 
								 */
    }
    mansf += man_inc;

    if ((ovflow == 1) || (erase == 1) || (nonzx == 0)) {
	zfix = 0x0ULL;
    } else {
	zfix = mansf;
    }

    zfix &= (0x1ULL << 56) - 1;
    zfix |= signz << 56;

    *z = zfix;
    return;
}

// ----------------------------------------------------------- : No. 9
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
// ----------------------------------------------------------- : No. 10
// PGR Floating-Point ExpAdd
// exp add (1)
void
pg_float_expadd_1_26_16(LONG x, LONG * z)
{
    LONG            signz, nonzz, manz;
    LONG            expx, expz, eadd;
    signz = 0x1ULL & (x >> 25);
    nonzz = 0x1ULL & (x >> 24);
    expx = 0xFFULL & (x >> 16);
    manz = 0xFFFFULL & x;
    eadd = 0x1ULL;		// 1
    expz = 0xFFULL & (expx + eadd);
    *z = (signz << 25) | (nonzz << 24) | (expz << 16) | manz;
}
