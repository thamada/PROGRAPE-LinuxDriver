#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "pg_util.h"

#include "pgrapi.h"

// #define DEBUG

#define   MAX(x,y)     (((x) > (y)) ?  (x) : (y))
#define   MIN(x,y)     (((x) < (y)) ?  (x) : (y))

#define NJMAX 16384

#define NPIPE_PER_CHIP  1
#define NCHIP_PER_BOARD 4

#define NFLO 26
#define NMAN 16
#define RMODE 6

static int      devid = 0;
static int      __first = 0;

static unsigned long long int fdata[NJMAX][FDIM];

void
force(double x[][3], double m[], double eps2, double a[][3], int n)
{
    double          log2(double);
    int             i, j;
    unsigned int    npipe, npipe_per_chip;
    unsigned int    nchip;
    unsigned int    jdata[JDIM];
    if (__first == 0) {
	b3open(devid);
	pgr_reset(devid);
	pgr_set_npipe_per_chip(devid, NPIPE_PER_CHIP);
	pgr_set_jwidth(devid, 16);	// change manually 4 if grape
	pgr_set_nchip(NCHIP_PER_BOARD);
	__first = 1;
    }

    npipe_per_chip = NPIPE_PER_CHIP;
    nchip = NCHIP_PER_BOARD;
    npipe = nchip * npipe_per_chip;

    for (j = 0; j < n; j++) {
	unsigned int    xj[4];
	xj[0] = (unsigned int) (double2pgpgfloat_r(x[j][0], 26, 16, 6));
	xj[1] = (unsigned int) (double2pgpgfloat_r(x[j][1], 26, 16, 6));
	xj[2] = (unsigned int) (double2pgpgfloat_r(x[j][2], 26, 16, 6));
	xj[3] = (unsigned int) (double2pgpgfloat_r(m[j], 26, 16, 6));
	for (i = 0; i < JDIM; i++)   jdata[i] = 0x0;
	jdata[0] |= (0x3ffffff & xj[0]) << 0;	// mask(26)
	jdata[0] |= (0x3f & xj[1]) << 26;	// mask(6)
	jdata[1] |= (0xfffff & (xj[1] >> 6));	// mask(20)
	jdata[1] |= (0xfff & xj[2]) << 20;	// mask(12)
	jdata[2] |= (0x3fff & (xj[2] >> 12));	// mask(14)
	jdata[2] |= (0x3ffff & xj[3]) << 14;	// mask(18)
	jdata[3] |= (0xff & (xj[3] >> 18));	// mask(8)
	pgr_setjpset_one(devid, j, jdata);
    }

    for (i = 0; i < n; i += npipe) {
	int             nn, ii, ichip;
	nn = MIN(npipe, n - i);

#ifdef DEBUG
	dum = e_time();
#endif

	for (ii = 0; ii < nn; ii += npipe_per_chip) {
	    int             nnn, iii;
	    ichip = ii / npipe_per_chip;

	    nnn = MIN(npipe_per_chip, nn - ii);
	    for (iii = 0; iii < nnn; iii++) {
		unsigned int    idata[4];
		idata[0] =
		    (unsigned
		     int) (double2pgpgfloat_r(x[i + ii + iii][0], 26, 16,
					      6));
		idata[1] =
		    (unsigned
		     int) (double2pgpgfloat_r(x[i + ii + iii][1], 26, 16,
					      6));
		idata[2] =
		    (unsigned
		     int) (double2pgpgfloat_r(x[i + ii + iii][2], 26, 16,
					      6));
		idata[3] =
		    (unsigned int) (double2pgpgfloat_r(eps2, 26, 16, 6));
		pgr_setipset_one(devid, ichip, iii, idata, 4);
	    }
	}
#ifdef DEBUG
	_t[2] += e_time() - dum;
	dum = e_time();
#endif

	pgr_start_calc(devid, n);
#ifdef DEBUG
	_t[3] += e_time() - dum;
	dum = e_time();
#endif

	pgr_getfoset(devid, fdata);
	for (ii = 0; ii < nn; ii++) {
	    a[i + ii][0] =
		((double) ((long long int) fdata[ii][0] << 0)) *
		((-1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    a[i + ii][1] =
		((double) ((long long int) fdata[ii][1] << 0)) *
		((-1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    a[i + ii][2] =
		((double) ((long long int) fdata[ii][2] << 0)) *
		((-1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	}
#ifdef DEBUG
	_t[4] += e_time() - dum;
#endif

    }
#ifdef DEBUG
    _t[0] = e_time() - _t[0];
    fprintf(stderr, "total %g sec (jp %g, ip %g, c %g, fo %g %%)\n", _t[0],
	    100.0 * _t[1] / _t[0], 100.0 * _t[2] / _t[0],
	    100.0 * _t[3] / _t[0], 100.0 * _t[4] / _t[0]);
#endif
}
