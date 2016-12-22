//Time-stamp: "2007-01-24 01:31:34 hamada"
//
// API for the PGR system for PROGRAPE-4
//
// by T.Hamada
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "pg4.h"
#include "pg4reg.h"
#include "pgrapi.h"

unsigned int *bar1[8];

static unsigned int *ptr[] = {
  NULL, NULL, NULL, NULL
};

static int npipe_per_chip[] = {1,1,1,1};
static int jwidth[] = {JDIM, JDIM, JDIM, JDIM};

static int NCHIP = 4;                               // NCHIP variable
void pgr_set_nchip(int n){   NCHIP = n; }           // NCHIP variable

void pgr_reset(int devid)
{
  // allocate DMA buffer
  if (ptr[devid] == NULL) {
    ptr[devid] = pg4_get_dmarptr(devid);

    if (ptr[devid] == NULL) {
      fprintf(stderr, "mmap error!!!!!\n fatal error, now exiting....\n");
      exit(-1);
    }
  }

  WriteBase0(devid, PIPE_RST, 0xf);   // send RST<="1111" ( 4 chips )
  WriteBase0(devid, PIPE_RST, 0x0);   // send RST<="0000" ( 4 chips )
}

int pgr_get_writecomb_err(int devid)
{
  int rtn;
  rtn = pg4_readbase0(devid, 0);
  rtn >>= 6;
  return (rtn);
}

void pgr_setjpset_one(int devid, int j, unsigned int jdata[JDIM])
{
  unsigned int offset = (ADR_JPSET<<1) + ((j*JDIM*sizeof(unsigned int))>>2);
  memcpy(bar1[devid]+offset, jdata, jwidth[devid]*sizeof(unsigned int));
}

void pgr_setjpset(int devid, unsigned int jdata[][JDIM], int nj)
{
  unsigned int offset = (ADR_JPSET<<1);     // BroadCast
  // nj <= 8192 !!
  memcpy(bar1[devid]+offset, jdata, JDIM*sizeof(unsigned int)*nj);
}

void pgr_setipset(int devid, unsigned int *idata, int ni)
{
  unsigned int offset = (ADR_IPSET<<1);
  memcpy(bar1[devid]+offset, idata, sizeof(unsigned int)*ni);
}

void pgr_setipset_ichip(int devid, unsigned int ichip, unsigned int *idata, int number_of_pipelines)
{
  int i;
  int num = number_of_pipelines << XI_AWIDTH;
  //  unsigned int offset = (ADR_IPSET<<1) |(ichip<<11);
  //  memcpy(bar1[devid]+offset, idata, sizeof(unsigned int)*num);

  for(i = 0; i < num; i++) {
    pg4_writebase1(devid, (ADR_IPSET<<1) |(ichip<<11)| i, idata[i]);
  }
}

/*
void pgr_setipset_ichip(int devid, unsigned int ichip, unsigned int *idata, int number_of_pipelines)
{
  int i;
  int num = number_of_pipelines << XI_AWIDTH;
  for(i = 0; i < num; i++) {
    pg4_writebase1(devid, (ADR_IPSET<<1) |(ichip<<11)| i, idata[i]);
  }
}
*/

void pgr_setipset_one(int devid, unsigned int ichip, int ipipe, unsigned int *idata, int idim)
{
  unsigned int offset = (ADR_IPSET<<1) |(ichip<<11) | (ipipe<<XI_AWIDTH);
  memcpy(bar1[devid]+offset, idata, sizeof(unsigned int)*idim);
}

void pgr_start_calc(int devid, unsigned int n)
{
  unsigned int offset = ADR_SETN<<1;
  int i;
  volatile int j;
  // SETN
  pg4_writebase1(devid, offset, n);
  pg4_writebase1(devid, offset+1, 0xffffffff);
  j = pg4_readbase1(devid, offset+1); // flash cache
  
  // RUN
  pg4_writebase1(devid, offset+6, 0xffffffff);
  pg4_writebase1(devid, offset+7, 0xffffffff);
  j = pg4_readbase1(devid, offset+1); // flash cache


  // -------------------------- change 2005/01/04 by T.H
  //                            wait until runret return
  //                                 and prepare all foset(for 4chips) to ifpga RAM.
  //  i=0;
  while( (0x1 & pg4_readbase0(devid,0)) == 1){
    //    i++;
    //    fprintf(stderr,"%d ",i);
    //    if(i>3) for(i=0;i<16;i++)  pg4_writebase1(devid, offset+i, n);
  }
  //  fprintf(stderr,"%d\n",i);
}

void pgr_calc_start(int devid, unsigned int n)
{
  unsigned int offset = ADR_SETN<<1;
  int i;
  // -------------------------- SETN(i==0) & RUN(i==2)
  for(i = 0; i < 16; i++){
    pg4_writebase1(devid, offset+i, n);
  }
}

void pgr_calc_finish(int devid)
{
  while( (0x1 & pg4_readbase0(devid,0)) == 1){
    //    i++;
    //    fprintf(stderr,"%d ",i);
    //    if(i>3) for(i=0;i<16;i++)  pg4_writebase1(devid, offset+i, n);
  }
}

void pgr_getfoset(int devid, unsigned long long int fodata[][FDIM])
{
  int ret;
  int npc = npipe_per_chip[devid];
  unsigned int size = NCHIP * npc * FDIM * sizeof(unsigned long long int);

  AGAIN:
  ret = pg4_DMAget(devid, size);
  if (pg4_DMAretry(devid) > 0) {
    //    fprintf(stderr, "possible DMA failure\n");
    //    pg4_DMAcheck(devid);
    goto AGAIN;
  }
  memcpy(fodata, &ptr[devid][0], size);

  //  memcpy(fodata, bar1[devid]+(ADR_FOSET<<1), size);
}

void pgr_getfoset2(int devid, unsigned long long int fodata[][FDIM], unsigned int size, unsigned int offset)
{
  int ret;

  AGAIN2:
  ret = pg4_DMAget_offset(devid, size, offset);
  if (pg4_DMAretry(devid) > 0) {
    //    fprintf(stderr, "possible DMA failure\n");
    //    pg4_DMAcheck(devid);
    goto AGAIN2;
  }
  memcpy(fodata, &ptr[devid][0], size);
}

//PIO version
void pgr_getfoset3(int devid, unsigned long long int fodata[][FDIM])
{
  int npc = npipe_per_chip[devid];
  unsigned int size = NCHIP * npc * FDIM * sizeof(unsigned long long int);
  memcpy(fodata, bar1[devid]+(ADR_FOSET<<1), size);
}

void pgr_set_jwidth(int devid, int n)
{
 if(n < 1) {
    fprintf(stderr,"pgr api error, JWIDTH be > 0.\n");
    exit(-1);
  }
  jwidth[devid] = n;
}

void pgr_set_npipe_per_chip(int devid, int n){
  if(n>256){
    fprintf(stderr,"pgr api error, NPIPE/chip must be < 257.\n");
    fprintf(stderr,"[NPIPE/chip %d ?]\n",n);
    exit(-1);
  }else if(n<1){
    fprintf(stderr,"pgr api error, NPIPE/chip must be > 0.\n");
    fprintf(stderr,"[NPIPE/chip %d ?]\n",n);
    exit(-1);
  }
  npipe_per_chip[devid] = n; // this is used in pgr_getfoset().
  WriteBase0(devid, NPIPE_IFPGA, n);
}

int pgr_open(int id)
{
  int rtn;
  rtn = pg4_open(id);
  bar1[id] = pg4_get_bar1ptr(id);

  return rtn;
}

void pgr_close(int devid)
{
  pg4_close(devid);
}


