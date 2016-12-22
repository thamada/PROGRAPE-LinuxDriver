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

#define NPIPE_PER_CHIP  5
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
#ifdef DEBUG
    double          _t[10], dum;
#endif

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

#ifdef DEBUG
    _t[0] = e_time();
    _t[1] = _t[2] = _t[3] = _t[4] = 0.0;
    dum = e_time();
#endif
    for (j = 0; j < n; j++) {
	unsigned int    xj[4];
	xj[0] =
	    ((unsigned int) (x[j][0] * (pow(2.0, (double) 32) / (2.0)) +
			     0.5)) & 0xFFFFFFFF;
	xj[1] =
	    ((unsigned int) (x[j][1] * (pow(2.0, (double) 32) / (2.0)) +
			     0.5)) & 0xFFFFFFFF;
	xj[2] =
	    ((unsigned int) (x[j][2] * (pow(2.0, (double) 32) / (2.0)) +
			     0.5)) & 0xFFFFFFFF;
	if (m[j] == 0.0) {
	    xj[3] = 0;
	} else if (m[j] > 0.0) {
	    xj[3] =
		(((int)
		  (pow(2.0, 8.0) *
		   log(m[j] * (pow(2.0, 95.38) / (1.0e-2))) /
		   log(2.0))) & 0x7FFF) | 0x8000;
	} else {
	    xj[3] =
		(((int)
		  (pow(2.0, 8.0) *
		   log(-m[j] * (pow(2.0, 95.38) / (1.0e-2))) /
		   log(2.0))) & 0x7FFF) | 0x18000;
	}

	for (i = 0; i < JDIM; i++)
	    jdata[i] = 0x0;

	// setup jdata
	jdata[0] = 0xffffffff & xj[0];
	jdata[1] = 0xffffffff & xj[1];
	jdata[2] = 0xffffffff & xj[2];
	jdata[3] = 0x1ffff & xj[3];


	pgr_setjpset_one(devid, j, jdata);
    }
#ifdef DEBUG
    _t[1] = e_time() - dum;
#endif

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
		    ((unsigned int) (x[i + ii + iii][0] *
				     (pow(2.0, (double) 32) / (2.0)) +
				     0.5)) & 0xFFFFFFFF;
		idata[1] =
		    ((unsigned int) (x[i + ii + iii][1] *
				     (pow(2.0, (double) 32) / (2.0)) +
				     0.5)) & 0xFFFFFFFF;
		idata[2] =
		    ((unsigned int) (x[i + ii + iii][2] *
				     (pow(2.0, (double) 32) / (2.0)) +
				     0.5)) & 0xFFFFFFFF;
		if (eps2 == 0.0) {
		    idata[3] = 0;
		} else if (eps2 > 0.0) {
		    idata[3] =
			(((int)
			  (pow(2.0, 8.0) *
			   log(eps2 *
			       ((pow(2.0, (double) 32) / (2.0)) *
				(pow(2.0, (double) 32) / (2.0)))) /
			   log(2.0))) & 0x7FFF) | 0x8000;
		} else {
		    idata[3] =
			(((int)
			  (pow(2.0, 8.0) *
			   log(-eps2 *
			       ((pow(2.0, (double) 32) / (2.0)) *
				(pow(2.0, (double) 32) / (2.0)))) /
			   log(2.0))) & 0x7FFF) | 0x18000;
		}
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
		((-(pow(2.0, (double) 32) / (2.0)) *
		  (pow(2.0, (double) 32) / (2.0)) * pow(2.0,
							-1.0 *
							(double) -31) /
		  (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
	    a[i + ii][1] =
		((double) ((long long int) fdata[ii][1] << 0)) *
		((-(pow(2.0, (double) 32) / (2.0)) *
		  (pow(2.0, (double) 32) / (2.0)) * pow(2.0,
							-1.0 *
							(double) -31) /
		  (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
	    a[i + ii][2] =
		((double) ((long long int) fdata[ii][2] << 0)) *
		((-(pow(2.0, (double) 32) / (2.0)) *
		  (pow(2.0, (double) 32) / (2.0)) * pow(2.0,
							-1.0 *
							(double) -31) /
		  (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
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
