// Time-stamp: "2007-01-24 20:26:48 hamada"

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <asm/page.h>
#include <errno.h>
#include <memory.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <time.h>

void pg4_close_and_exit(int devid);

#include "pg4.h"

/* Function macros not implemented in C language */
#define   MAX(x,y)     (((x) > (y)) ?  (x) : (y))
#define   MIN(x,y)     (((x) < (y)) ?  (x) : (y))

//#define NMAX (0x1<<10) // 4KB
#define NMAX (0x1<<14)   // 64KB

unsigned int buf[NMAX], buf2[NMAX];
int devid;
unsigned int* ptr;
unsigned int* bar0;
unsigned int* bar1;
unsigned int* dmaw_buf;
unsigned int* dmar_buf;

double Rpeak, Wpeak;

double e_time(void)
{
  static struct timeval now;
  static struct timezone tz;

  gettimeofday(&now, &tz);
  return (double)(now.tv_sec  + now.tv_usec/1000000.0);
}

void PIO(void)
{
  int i, n, j, count, size;
  double lap, dum;

  n = NMAX;
  for(i = 0; i < n; i++) {
    buf[i] = rand();
  }
  size = n*sizeof(int);

  // PIO write
  count = 0x1000;
  dum = e_time();
  for(j = 0; j < count; j++) {

    //    for(i = 0; i < n; i++)  pg4_writebase1(devid, i, buf[i]);
    memcpy(bar1, buf, n*sizeof(unsigned int));

  }
  lap = e_time() - dum;
  printf("PIO Write %f MB/sec (%f)\n", (double)size*count/lap/1.0e6, lap);
  Wpeak = MAX(Wpeak, (double)size*count/lap/1.0e6);


  // PIO read
  count = 0x100;
  dum = e_time();
  for(j = 0; j < count; j++) {
    for(i = 0; i < n; i++) {
      buf[i] = pg4_readbase1(devid, i);
    }
  }
  lap = e_time() - dum;
  printf("PIO Read %f MB/sec (%f)\n", size*count/lap/1.0e6, lap);
}


void DMA(void)
{
  int i, n, j, count, size, ret;
  double lap, dum;

  n = NMAX;
  for(i = 0; i < n; i++) {
    buf[i] = rand();
  }
  size = n*sizeof(int);

  // write speed
  count = 0x800;
  dum = e_time();
  for(j = 0; j < count; j++) {
    ret = pg4_DMAput(devid, size);
  }
  lap = e_time() - dum;
  printf("BusMaster Write %f MB/sec (%f)\n", size*count/lap/1.0e6, lap);
  //  pg4_DMAcheck(devid);


  // read speed
  count = 0x3000;
  dum = e_time();
  for(j = 0; j < count; j++) {
    ret = pg4_DMAget(devid, size);
    if (ret < 0) {
      printf("count %i\n", j);
      pg4_DMAcheck(devid);
    }
  }
  lap = e_time() - dum;
  printf("BusMaster Read %f MB/sec (%f)\n", (double)size*count/lap/1.0e6, lap);
  //  pg4_DMAcheck(devid);

  Rpeak = MAX(Rpeak, (double)size*count/lap/1.0e6);

}

void PIO_W_speed(int count)
{
  int i, n, j, size;
  double lap, dum;

  n = NMAX;
  for(i = 0; i < n; i++) {
    buf[i] = rand();
  }
  size = n*sizeof(int);

  // PIO write
  dum = e_time();
  for(j = 0; j < count; j++) {
    //    for(i = 0; i < n; i++)  pg4_writebase1(devid, i, buf[i]);
    memcpy(bar1, buf, n*sizeof(unsigned int));
  }
  lap = e_time() - dum;
  printf("PIO Write %f MB/sec (%f)\n", (double)size*count/lap/1.0e6, lap);
  Wpeak = MAX(Wpeak, (double)size*count/lap/1.0e6);
}

void PIO_R_speed(int count)
{
  int i, n, j, size;
  double lap, dum;

  n = NMAX;
  for(i = 0; i < n; i++) {
    buf[i] = rand();
  }
  size = n*sizeof(int);

  // PIO read
  dum = e_time();
  for(j = 0; j < count; j++) {
    for(i = 0; i < n; i++) {
      buf[i] = pg4_readbase1(devid, i);
    }
  }
  lap = e_time() - dum;
  printf("PIO Read %f MB/sec (%f)\n", size*count/lap/1.0e6, lap);
}

void DMA_W_speed(int count)
{
  int i, n, j, size, ret;
  double lap, dum;

  n = NMAX;
  for(i = 0; i < n; i++) {
    //    buf[i] = rand();
    buf[i] = i;
  }
  size = n*sizeof(int);

  // write speed
  dum = e_time();
  for(j = 0; j < count; j++) {
    ret = pg4_DMAput(devid, size);
  }
  lap = e_time() - dum;
  printf("BusMaster Write %f MB/sec (%f)\n", size*count/lap/1.0e6, lap);
  //  pg4_DMAcheck(devid);

}

void DMA_R_speed(int count)
{
  int i, n, j, size, ret;
  double lap, dum;

  n = NMAX;
  for(i = 0; i < n; i++) {
    buf[i] = rand();
  }
  size = n*sizeof(int);

  // read speed
  dum = e_time();
  for(j = 0; j < count; j++) {
    ret = pg4_DMAget(devid, size);
    if (ret < 0) {
      printf("count %i\n", j);
      pg4_DMAcheck(devid);
    }
  }
  lap = e_time() - dum;
  printf("BusMaster Read %f MB/sec (%f)\n", (double)size*count/lap/1.0e6, lap);
  //  pg4_DMAcheck(devid);

  Rpeak = MAX(Rpeak, (double)size*count/lap/1.0e6);

}


void DMA_R_check(void)
{
  int i, j, n, ret, size, is_err=0;
  n = NMAX;
  size = n*sizeof(int);

  // read test
  for(j = 0; j < 200; j++) {
    for(i = 0; i < n; i++) {
      //      buf[i] = rand();
      buf[i] = i;
      pg4_writebase1(devid, i, buf[i]);
    }

    ret = pg4_DMAget(devid, size);

    if (ret < 0) {
      fprintf(stderr, "DMA failed!!!!!\n");
    }


    is_err = 0;
    for(i = 0; i < n; i++) {
      if (dmar_buf[i] != buf[i]) {
	//	if(is_err <20) printf("DMAR error(%d) buf[%i] %x %x %x\n", 
	printf("DMAR error(%d) buf[%i] %x %x %x\n", 
			      is_err, i, buf[i], dmar_buf[i], buf[i] - dmar_buf[i]);
	is_err++;
      }
    }

    if(is_err == 0){
      //      printf("R");
    } else {
      puts("----------- FAILED DMA_R");
      pg4_close_and_exit(devid);
    }
  }
  printf("R");
  fflush(NULL);
}


void DMA_W_check(void)
{
  int i, j, n, ret, size, is_err=0;
  n = NMAX;

  size = n*sizeof(int);

  // write test
  for(j = 0; j < 50; j++) {
    for(i = 0; i < n; i++) {
      unsigned int x = rand();
      //      unsigned int x = 0x222<<16 | i;
      x = i;
      dmaw_buf[i] = x;
      buf[i]      = x;
      //      pg4_writebase1(devid, i, 0x777);
    }

    ret = pg4_DMAput(devid, size);

    if (ret < 0) {
      fprintf(stderr, "DMA failed!!!!!\n");
    }

    is_err=0;
    for(i = 0; i < n; i++) {
      unsigned int x = pg4_readbase1(devid, i);
      if (buf[i] != x) {
	if(is_err < 100)	printf("DMAW error %i %x %x %x\n", i, buf[i], x, buf[i]-x);
	is_err++;
      }
    }

    if(is_err == 0){
      //      printf("W");
    }else{
      puts("----------- FAILED");
      exit(-1);
    }

  }
  printf("W");
  fflush(NULL);
}


void ErrorCheck_PIOW(void)
{
  int i, j, k, n, size;
  int is_err=0;
  n = NMAX;
  size = n*sizeof(int);

  for(k = 0; k < 20000; k++) {
    // write test
    for(j = 0; j < 100; j++) {
      for(i = 0; i < n; i++) {
	buf[i] = rand();
      }


      //      for(i = 0; i < n; i++) {
      //	pg4_writebase1(devid, i, buf[i]);
      //      }
      memcpy(bar1, buf, n*sizeof(unsigned int));


      for(i = 0; i < n; i++) {
	unsigned int x = pg4_readbase1(devid, i);
	if (buf[i] != x) {
	  printf("error %i %x %x %x\n", i, buf[i], x, buf[i]-x);
	  is_err++;
	}
      }
      if(is_err != 0) {printf("is_err %d\n",is_err);exit(-1);}
    }
    printf(".");
    fflush(NULL);
  }

  printf("\n");
  fflush(NULL);
}




int main(int argc,char *argv[])
{
  int i;
  int dma_size;
  Rpeak = Wpeak = 0.0;
  srand(time(NULL));

  devid = 0;

  pg4_open(devid);

  bar0 = pg4_get_bar0ptr(devid);
  bar1 = pg4_get_bar1ptr(devid);

  dmaw_buf = pg4_get_dmawptr(devid);
  dmar_buf = pg4_get_dmarptr(devid);
  dma_size = pg4_get_dma_size(devid);

  printf("DMA SIZE=0x%x\n",dma_size);
  printf("BAR0 (%ld Bytes)    : %lx\n"
	 ,pg4_getbaseaddr_size(devid,0)
	 ,pg4_getbaseaddr(devid,0));
  printf("BAR1 (%ld Bytes)    : %lx\n"
	 ,pg4_getbaseaddr_size(devid,1)
	 ,pg4_getbaseaddr(devid,1));


  //  DMA_W_speed();
  //  DMA_R_speed();

  if(0){
    int i, n;
    n = (dma_size >> 2);
    for(i = 0; i < n; i++) buf[i] = i;
    memcpy(bar1, buf, n*sizeof(unsigned int));

    pg4_DMAput(devid, dma_size);

    for(i = 0; i < (dma_size>>2); i++) {
      int res  = dmar_buf[i];
      int diff = i  - res;
      if(diff != 0)
	printf("dmar_buf[%i] %i %i\n",i ,res, diff);
    }
  }



  PIO_W_speed(1000);
  PIO_R_speed(40);
  
  DMA_W_speed(40);
  DMA_R_speed(1000);

  while(0) {
    DMA_W_check();
    DMA_R_check();
  }


  ErrorCheck_PIOW();
  return 0;
}


