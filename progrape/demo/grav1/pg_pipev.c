//Time-stamp: <2007-01-23 23:28:16 hamada>
//Copyright(c) 2006 by Tsuyoshi Hamada. All rights reserved.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "pg_util.h"
#include "pgrapi.h"

#define NPIPE_PER_CHIP  16
//#define NPIPE_PER_CHIP  1
#define NCHIP_PER_BOARD 4


static int   devid = 0;
static LONG _a[16384][3];
static double XSCALE=0.0;
static double MSCALE=0.0;
static double FSCALE=0.0;
void set_range(double xfac, double mfac)
{
  XSCALE = xfac;
  MSCALE = mfac;
  FSCALE = XSCALE*XSCALE/MSCALE;
}

// #define DEBUG

#define   MAX(x,y)     (((x) > (y)) ?  (x) : (y))
#define   MIN(x,y)     (((x) < (y)) ?  (x) : (y))
#define NJMAX 16384


static unsigned int      __first = 0;

static unsigned long long int fdata[NJMAX][FDIM];

void
force(double x[][3], double m[], double eps2, double a[][3], int n)
{
    double          log2(double);
    int             i, j;
    unsigned int    npipe, npipe_per_chip;
    unsigned int    nchip;
    unsigned int    ieps2;
#ifdef DEBUG
    double          _t[10], dum;
#endif
    double xx,mm,ff,fff;


    if ( __first == 0) {
      pgr_open(devid);
      pgr_reset(devid);
      pgr_set_npipe_per_chip(devid, NPIPE_PER_CHIP);
      pgr_set_jwidth(devid, 16);
      pgr_set_nchip(NCHIP_PER_BOARD);
      __first++;
    }

    npipe_per_chip = NPIPE_PER_CHIP;
    nchip = NCHIP_PER_BOARD;
    npipe = nchip * npipe_per_chip;

#ifdef DEBUG
    _t[0] = e_time();
    _t[1] = _t[2] = _t[3] = _t[4] = 0.0;
    dum = e_time();
#endif


    xx = XSCALE*pow(2.0, 31.0);
    mm = MSCALE* (pow(2.0, 95.38) / (1.0e-2));
    ff = 256.0/log(2.0);
    {
      unsigned int nk;
      unsigned jdata[JDIM*4];
      for (j = 0; j < n; j += 4) {
	int jj,nn;
	nn = MIN(4, n-j);
	for(jj = 0; jj < nn; jj++) {
	  jdata[4*jj  ] = ((unsigned int) (xx * x[j+jj][0] + 0.5)) & 0xFFFFFFFF;
	  jdata[4*jj+1] = ((unsigned int) (xx * x[j+jj][1] + 0.5)) & 0xFFFFFFFF;
	  jdata[4*jj+2] = ((unsigned int) (xx * x[j+jj][2] + 0.5)) & 0xFFFFFFFF;
	  jdata[4*jj+3] = (((int) (ff*log(mm*m[j]))) & 0x7FFF) | 0x8000;
	}
	pgr_setjpset_one(devid, j, jdata);
      }
    }


#ifdef DEBUG
    _t[1] = e_time() - dum;
#endif

    xx = XSCALE*pow(2.0, 31.0);
    ff = (XSCALE*XSCALE/MSCALE);
    fff = ((pow(2.0,93.0) / (pow(2.0, 95.38) / (1.0e-2)))) / pow(2.0, 0.0);
    ieps2 = (((int) (256.0* log(eps2 * XSCALE*XSCALE* pow(2.0, (double) 62))/log(2.0))) & 0x7FFF) | 0x8000;

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
	    for (iii = 0; iii < nnn; iii++){
		unsigned int idata[4];
		idata[0] = ((unsigned int) (x[i + ii + iii][0] * xx + 0.5)) & 0xFFFFFFFF;
		idata[1] = ((unsigned int) (x[i + ii + iii][1] * xx + 0.5)) & 0xFFFFFFFF;
		idata[2] = ((unsigned int) (x[i + ii + iii][2] * xx + 0.5)) & 0xFFFFFFFF;
		idata[3] = ieps2;
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
	//	pgr_getfoset3(devid, fdata);
	for (ii = 0; ii < nn; ii++) {
	    a[i + ii][0] = -ff * ((double) ((long long int) fdata[ii][0])) * fff;
	    a[i + ii][1] = -ff * ((double) ((long long int) fdata[ii][1])) * fff;
	    a[i + ii][2] = -ff * ((double) ((long long int) fdata[ii][2])) * fff;

	    _a[i+ii][0] = fdata[ii][0];
	    _a[i+ii][1] = fdata[ii][1];
	    _a[i+ii][2] = fdata[ii][2];
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


    /*
    for(i=0;i<n;i++){
      int k;
      printf("%03d: ",i);
      for(k=0;k<3;k++)  printf("%016llx\t",_a[i][k]);
      printf("\n");
    }
    exit(0);
    */
}

