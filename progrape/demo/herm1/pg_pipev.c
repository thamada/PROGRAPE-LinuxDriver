#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "pg_util.h"
#include "pgrapi.h"

#define   MAX(x,y)     (((x) > (y)) ?  (x) : (y))
#define   MIN(x,y)     (((x) < (y)) ?  (x) : (y))

#define NJMAX 4096

#define NPIPE_PER_CHIP  1
#define NCHIP_PER_BOARD 4

#define NFLO 26
#define NMAN 16
#define RMODE 6

static int      devid = 0;
static int      __first = 0;

static unsigned long long int fdata[NJMAX][FDIM];

void
force(double x[][3], double v[][3], double m[], double p[], double a[][3],
      double jk[][3], int n)
{
    double          log2(double);
    int             i, j;
    unsigned int    npipe, npipe_per_chip;
    unsigned int    nchip;
    unsigned int    jdata[JDIM];

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
	unsigned int    xj[7];
	xj[0] = (unsigned int) (double2pgrfloat(x[j][0], 26, 16, 6));
	xj[1] = (unsigned int) (double2pgrfloat(x[j][1], 26, 16, 6));
	xj[2] = (unsigned int) (double2pgrfloat(x[j][2], 26, 16, 6));
	xj[3] = (unsigned int) (double2pgrfloat(v[j][0], 26, 16, 6));
	xj[4] = (unsigned int) (double2pgrfloat(v[j][1], 26, 16, 6));
	xj[5] = (unsigned int) (double2pgrfloat(v[j][2], 26, 16, 6));
	xj[6] = (unsigned int) (double2pgrfloat(m[j], 26, 16, 6));

	for (i = 0; i < 7; i++)
	    jdata[i] = 0x0;


	// i = 0 : 26-bit float
	jdata[0] |= (xj[0] >> 0) << 0;
	// i = 1 : 26-bit float
	jdata[0] |= (xj[1] >> 0) << 26;
	jdata[1] |= (xj[1] >> 6) << 0;
	// i = 2 : 26-bit float
	jdata[1] |= (xj[2] >> 0) << 20;
	jdata[2] |= (xj[2] >> 12) << 0;
	// i = 3 : 26-bit float
	jdata[2] |= (xj[3] >> 0) << 14;
	jdata[3] |= (xj[3] >> 18) << 0;
	// i = 4 : 26-bit float
	jdata[3] |= (xj[4] >> 0) << 8;
	jdata[4] |= (xj[4] >> 24) << 0;
	// i = 5 : 26-bit float
	jdata[4] |= (xj[5] >> 0) << 2;
	// i = 6 : 26-bit float
	jdata[4] |= (xj[6] >> 0) << 28;
	jdata[5] |= (xj[6] >> 4) << 0;


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
		unsigned int    idata[6];
		idata[0] =
		    (unsigned
		     int) (double2pgrfloat(x[i + ii + iii][0], 26, 16, 6));
		idata[1] =
		    (unsigned
		     int) (double2pgrfloat(x[i + ii + iii][1], 26, 16, 6));
		idata[2] =
		    (unsigned
		     int) (double2pgrfloat(x[i + ii + iii][2], 26, 16, 6));
		idata[3] =
		    (unsigned
		     int) (double2pgrfloat(v[i + ii + iii][0], 26, 16, 6));
		idata[4] =
		    (unsigned
		     int) (double2pgrfloat(v[i + ii + iii][1], 26, 16, 6));
		idata[5] =
		    (unsigned
		     int) (double2pgrfloat(v[i + ii + iii][2], 26, 16, 6));
		pgr_setipset_one(devid, ichip, iii, idata, 6);
	    }
	}

	pgr_start_calc(devid, n);

	//	pgr_getfoset(devid, fdata);
	pgr_getfoset3(devid, fdata);
	for (ii = 0; ii < nn; ii++) {
	    p[i + ii] =
		((double) ((long long int) fdata[ii][0] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    a[i + ii][0] =
		((double) ((long long int) fdata[ii][1] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    a[i + ii][1] =
		((double) ((long long int) fdata[ii][2] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    a[i + ii][2] =
		((double) ((long long int) fdata[ii][3] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    jk[i + ii][0] =
		((double) ((long long int) fdata[ii][4] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    jk[i + ii][1] =
		((double) ((long long int) fdata[ii][5] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);
	    jk[i + ii][2] =
		((double) ((long long int) fdata[ii][6] << 0)) *
		((1.0 / pow(2.0, (double) 31))) / pow(2.0, 0.0);

	    if(0){
	      int k;
	      printf("------------------- %d\n",ii);
	      for(k=0;k<7;k++){
		printf("%016llx\n",fdata[ii][k]);
	      }
	      exit(0);
	    }

	}

    }
}
