#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "pg_util.h"

#include "pgrapi.h"


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
    unsigned int    jdata[32];

    if (__first == 0) {
	pgr_open(devid);
	pgr_reset(devid);
	pgr_set_npipe_per_chip(devid, NPIPE_PER_CHIP);
	pgr_set_jwidth(devid, JDIM);
	pgr_set_nchip(NCHIP_PER_BOARD);
	__first = 1;
    }

    npipe_per_chip = NPIPE_PER_CHIP;
    nchip = NCHIP_PER_BOARD;
    npipe = nchip * npipe_per_chip;

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

	for (i = 0; i < 4; i++)
	    jdata[i] = 0x0;


	// i = 0 : 32-bit fix
	jdata[0] |= (xj[0] >> 0) << 0;
	// i = 1 : 32-bit fix
	jdata[1] |= (xj[1] >> 0) << 0;
	// i = 2 : 32-bit fix
	jdata[2] |= (xj[2] >> 0) << 0;
	// i = 3 : 17-bit log
	jdata[3] |= (xj[3] >> 0) << 0;


	pgr_setjpset_one(devid, j, jdata);
    }

    for (i = 0; i < n; i += npipe) {
	int             nn, ii, ichip;
	nn = MIN(npipe, n - i);


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

	pgr_start_calc(devid, n);

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

    }
}
