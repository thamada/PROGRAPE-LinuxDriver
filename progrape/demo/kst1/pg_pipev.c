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

void pgr_getfoset3(int devid, unsigned long long int fodata[][FDIM]);

#define NPIPE_PER_CHIP  16

#define NCHIP_PER_BOARD 4

#define NFLO 26
#define NMAN 16
#define RMODE 6

static int      devid = 0;
static int      __first = 0;

static unsigned long long int fdata[NJMAX][FDIM];

void
force_vhd(double data_j[][2], double data_i[][2], double count_i[][4],
	  unsigned long long int fo[][4],
	  int ni,   int nj)
{
    double          log2(double);
    int             i, j;
    unsigned int    npipe, npipe_per_chip;
    unsigned int    nchip;
    unsigned int    jdata[32];

    if (__first == 0) {
	b3open(devid);
	pgr_reset(devid);
	pgr_set_npipe_per_chip(devid, NPIPE_PER_CHIP);
	pgr_set_jwidth(devid, 4);	// change manually 4 if grape
	pgr_set_nchip(NCHIP_PER_BOARD);
	__first = 1;
    }

    npipe_per_chip = NPIPE_PER_CHIP;
    nchip = NCHIP_PER_BOARD;
    npipe = nchip * npipe_per_chip;

    for (j = 0; j < nj; j++) {
	unsigned int    xj[2];
	xj[0] = (unsigned int) (double2pgrfloat(data_j[j][0], 26, 16, 6));
	xj[1] = (unsigned int) (double2pgrfloat(data_j[j][1], 26, 16, 6));

	for (i = 0; i < 2; i++)
	    jdata[i] = 0x0;


	// i = 0 : 26-bit float
	jdata[0] |= (xj[0] >> 0) << 0;
	// i = 1 : 26-bit float
	jdata[0] |= (xj[1] >> 0) << 26;
	jdata[1] |= (xj[1] >> 6) << 0;


	pgr_setjpset_one(devid, j, jdata);
    }

    for (i = 0; i < ni; i += npipe) {
	int             nn, ii, ichip;
	nn = MIN(npipe, ni - i);


	for (ii = 0; ii < nn; ii += npipe_per_chip) {
	    int             nnn, iii;
	    ichip = ii / npipe_per_chip;

	    nnn = MIN(npipe_per_chip, nn - ii);
	    for (iii = 0; iii < nnn; iii++) {
		unsigned int    idata[2];
		idata[0] =
		    (unsigned
		     int) (double2pgrfloat(data_i[i + ii + iii][0], 26, 16,
					   6));
		idata[1] =
		    (unsigned
		     int) (double2pgrfloat(data_i[i + ii + iii][1], 26, 16,
					   6));
		pgr_setipset_one(devid, ichip, iii, idata, 2);
	    }
	}

	pgr_start_calc(devid, nj);

	pgr_getfoset(devid, fdata);
	for (ii = 0; ii < nn; ii++) {
	    count_i[i + ii][0] =
		((double) ((long long int) fdata[ii][0] << 0)) * (1.0) /
		pow(2.0, 0.0);
	    count_i[i + ii][1] =
		((double) ((long long int) fdata[ii][1] << 0)) * (1.0) /
		pow(2.0, 0.0);
	    count_i[i + ii][2] =
		((double) ((long long int) fdata[ii][2] << 0)) * (1.0) /
		pow(2.0, 0.0);
	    count_i[i + ii][3] =
		((double) ((long long int) fdata[ii][3] << 0)) * (1.0) /
		pow(2.0, 0.0);

	    fo[i+ii][0] = fdata[ii][0];
	    fo[i+ii][1] = fdata[ii][1];
	    fo[i+ii][2] = fdata[ii][2];
	    fo[i+ii][3] = fdata[ii][3];


	}

    }
}
