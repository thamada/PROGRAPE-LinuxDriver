/***************************************************
 * The lowest level library for PROGRAPE-4
 *
 * Copyright(c) by Tsuyoshi Hamada.
 * All rights reserved.
 *
 * PLEASE DO NOT BRANCH !!
 *
 * 20060916.rev1 : Development start
 ***************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/ioctl.h> // ioctl()
#include <sys/mman.h>  // mmap()
#include <sys/types.h> // open()
#include <sys/stat.h>  // open()
#include <sys/fcntl.h> // open()

#undef CERR
#define CERR(fmt, args...) fprintf(stderr, fmt, ## args)

#undef _CERR
#define _CERR(fmt, args...) 

#define MAX_NBOARD 8
unsigned int* bar0[MAX_NBOARD];
unsigned int* bar1[MAX_NBOARD];

//---------------------------------------
#include "progrape.h"

static char *devname[] = {
  "/dev/progrape0",
  "/dev/progrape1",
  "/dev/progrape2",
  "/dev/progrape3",
  "/dev/progrape4",
  "/dev/progrape5",
  "/dev/progrape6",
  "/dev/progrape7",
  "/dev/progrape8",
};

static int pg4_dev[] = {
  -1,-1,-1,-1,-1,-1,-1,-1,
};

unsigned int *dmar_buf[MAX_NBOARD];
unsigned int *dmaw_buf[MAX_NBOARD];

unsigned int* pg4_get_bar0ptr(int devid){ return bar0[devid]; }
unsigned int* pg4_get_bar1ptr(int devid){ return bar1[devid]; }

#define DMA_BSIZE (0x1<<10) // 4KB

static void * __mmap_bar     (int devid, int bar);
//    static int __pg4_DMA         (int devid, unsigned int size, unsigned int offset, unsigned int dir);
//    static int __pg4_DMA_noInterrupt(int devid, unsigned int size, unsigned int offset, unsigned int dir);
//    static int __pg4_DMA_with_retry(int devid, unsigned int size, unsigned int offset, unsigned int dir);
int           pg4_DMAget     (int devid, unsigned int size);
int           pg4_DMAput     (int devid, unsigned int size);
int           pg4_DMAput_offset (int devid, unsigned int size, unsigned offset);
int           pg4_DMAget_offset (int devid, unsigned int size, unsigned offset);
void          pg4_wait       (int devid, int n);
void          pg4_DMAcheck   (int devid);
int           pg4_DMAretry   (int devid);
unsigned long pg4_getbaseaddr(int devid, int j);
unsigned long pg4_getbaseaddr_size(int devid, int bar);
unsigned long pg4_read_pciconfig_dword(int devid, int adr);
void pg4_get_pfpga_info(int devid, char *info);
void pg4_set_pfpga_info(int devid, char *info);


static void * __mmap_dmabuf(int id, int is_wbuf)
{
  unsigned long size;
  void *mapped_ptr;

  switch (is_wbuf) {
  case 0:
    {
      if (ioctl(pg4_dev[id], IOC_SV_MMAPMODE, MMAP_BUF_DMAR)) {
	CERR("mmap dmar buf failed | %s:%d\n", __FILE__, __LINE__);
	exit (-1);
      }
      size = ioctl(pg4_dev[id], IOC_GV_DMA_SIZE);

    }
    break;
  case 1:
    {
      if (ioctl(pg4_dev[id], IOC_SV_MMAPMODE, MMAP_BUF_DMAW)) {
	CERR("mmap dmaw buf failed | %s:%d\n", __FILE__, __LINE__);
	exit (-1);
      }
      size = ioctl(pg4_dev[id], IOC_GV_DMA_SIZE);
    }
    break;
  default :
    CERR("mmap dmabuf %d invalid | %s:%d\n", is_wbuf, __FILE__, __LINE__);
    exit (-1);
  }

  mapped_ptr = mmap(NULL,
		    size,
		    (PROT_READ| PROT_WRITE),
		    MAP_SHARED,
		    pg4_dev[id],
		    0);
  _CERR("mmap_ptr called\n");

  return (mapped_ptr);
}


static void * __mmap_bar(int id, int bar)
{
  unsigned long size;
  unsigned long pagesize = getpagesize();
  void *mapped_ptr;

  switch (bar) {
  case 0:
    {
      if (ioctl(pg4_dev[id], IOC_SV_MMAPMODE, MMAP_REG_PIORW)) {
	CERR("mmap bar%d failed | %s:%d\n",bar,__FILE__,__LINE__);
	exit (-1);
      }
      size = ioctl(pg4_dev[id], IOC_GV_REG_SIZE);
    }
    break;
  case 1:
    {
      if (ioctl(pg4_dev[id], IOC_SV_MMAPMODE, MMAP_MEM_PIORW)) {
	CERR("mmap bar%d failed | %s:%d\n",bar,__FILE__,__LINE__);
	exit (-1);
      }
      size = ioctl(pg4_dev[id], IOC_GV_MEM_SIZE);
    }
    break;
  default :
    CERR("mmap bar%d invalid | %s:%d\n",bar,__FILE__,__LINE__);
    exit (-1);
  }

  mapped_ptr = mmap(NULL,
		    (size/pagesize+1)*pagesize,
		    (PROT_READ| PROT_WRITE),
		    MAP_SHARED,
		    pg4_dev[id],
		    0);

  return (mapped_ptr);
}


int pg4_open(int id)
{
  pg4_dev[id] = open(devname[id], O_RDWR);
  if(pg4_dev[id] == -1) {
    CERR("open failed %s | %s:%d\n",devname[id] ,__FILE__,__LINE__);
    return -1;
  }

  bar0[id] = (unsigned int *) __mmap_bar(id, 0); // mmap BAR0
  bar1[id] = (unsigned int *) __mmap_bar(id, 1); // mmap BAR1

  dmaw_buf[id] = (unsigned int *) __mmap_dmabuf(id, 1); // mmap DMAW buf
  dmar_buf[id] = (unsigned int *) __mmap_dmabuf(id, 0); // mmap DMAR buf

  if(dmaw_buf[id] == NULL){
    CERR("mmap dmaw_buf failed %s | %s:%d\n",devname[id] ,__FILE__,__LINE__);
    return (-1);
  }

  if(dmar_buf[id] == NULL){
    CERR("mmap dmar_buf failed %s | %s:%d\n",devname[id] ,__FILE__,__LINE__);
    return (-1);
  }

  _CERR("DMAW Buff at 0x%x\n",(unsigned int)dmaw_buf[id]);
  _CERR("DMAR Buff at 0x%x\n",(unsigned int)dmar_buf[id]);

  return 1;
}


void pg4_close(int id){
  close(pg4_dev[id]);
  pg4_dev[id] = -1;
}


void pg4_close_and_exit(int id){
  //  pg4_DMAcheck(id);
  pg4_close(id);
  exit(1);
}


inline unsigned int pg4_readbase0(int id, unsigned int index){ return *(bar0[id] + index); }
inline void         pg4_writebase0(int id, unsigned int index, unsigned int val){ *(bar0[id] + index) = val; }
inline unsigned int pg4_readbase1(int id, unsigned int index){ return *(bar1[id] + index); }
inline void         pg4_writebase1(int id, unsigned int index, unsigned int val){ *(bar1[id] + index) = val; }
inline unsigned int ReadBase0(int id, unsigned int addr){return pg4_readbase0(id, addr>>2);}
inline unsigned int ReadBase1(int id, unsigned int addr){return pg4_readbase1(id, addr>>2);}
inline void         WriteBase0(int id, unsigned int addr, unsigned int val){pg4_writebase0(id, addr>>2, val);}
inline void         WriteBase1(int id, unsigned int addr, unsigned int val){pg4_writebase1(id, addr>>2, val);}


unsigned int pg4_get_dma_size(int id) {
  return ( (unsigned int)ioctl(pg4_dev[id], IOC_GV_DMA_SIZE) );
}


unsigned int* pg4_get_dmawptr(int id) {
  return ( (unsigned int*)dmaw_buf[id] );
}


unsigned int* pg4_get_dmarptr(int id) {
  return ( (unsigned int*)dmar_buf[id] );
}


int pg4_DMAput(int id, unsigned int size)
{
  int ret = ioctl(pg4_dev[id], IOC_SV_DMAW, size);
  if(ret){
    CERR("DMAW failed %d| %s:%d\n",ret ,__FILE__, __LINE__);
    exit (-1);
  }
  return (0);
}


int pg4_DMAget(int id, unsigned int size)
{
  int ret = ioctl(pg4_dev[id], IOC_SV_DMAR, size);
  if(ret){
    CERR("DMAR failed %d| %s:%d\n",ret ,__FILE__, __LINE__);
    exit (-1);
  }
  return (0);
}


void pg4_DMAcheck(int devid)
{
  unsigned int flag, retry;
  fprintf(stderr,"\t INT_STAT       (0x%X) : %x\n", REG_INT_STAT,       ReadBase0(devid, REG_INT_STAT));
  fprintf(stderr,"\t INT_MASK       (0x%X) : %x\n", REG_INT_MASK,       ReadBase0(devid, REG_INT_MASK));
  fprintf(stderr,"\t DMA_PCI_ADRS   (0x%X) : %x\n", REG_DMA_PCI_ADRS,   ReadBase0(devid, REG_DMA_PCI_ADRS));
  fprintf(stderr,"\t DMA_LOCAL_ADRS (0x%X) : %x\n", REG_DMA_LOCAL_ADRS, ReadBase0(devid, REG_DMA_LOCAL_ADRS));
  fprintf(stderr,"\t DMA_COUNT      (0x%X) : %x\n", REG_DMA_COUNT,      ReadBase0(devid, REG_DMA_COUNT));
  fprintf(stderr,"\t DMA_CTRL       (0x%X) : %x\n", REG_DMA_CTRL,       ReadBase0(devid, REG_DMA_CTRL));
  fprintf(stderr,"\t DMA_INTERVAL   (0x%X) : %x\n", REG_DMA_INTERVAL,   ReadBase0(devid, REG_DMA_INTERVAL));
  fprintf(stderr,"\t DMA_STAT       (0x%X) : %x\n", REG_DMA_STAT,       ReadBase0(devid, REG_DMA_STAT));

  flag = ReadBase0(devid, REG_DMA_STAT);

  retry = ((0x1<<16)-1)&flag;
  fprintf(stderr,"\t DMA dissconnect count %i\n", (flag>>16));
  fprintf(stderr,"\t DMA retry count       %i\n", retry);
  fprintf(stderr,"\n");
  fflush(NULL);
}

int pg4_DMAretry(int devid)
{
  unsigned int flag, retry;
  flag = ReadBase0(devid, REG_DMA_STAT);
  retry = ((0x1<<16)-1)&flag;
  return retry;
}

int pg4_DMAput_offset(int devid, unsigned int size, unsigned offset)
{
  CERR("REMOVED, %s:%d\n", __FILE__, __LINE__);exit(-1);
  return -1;
}

int pg4_DMAget_offset(int devid, unsigned int size, unsigned offset)
{
  CERR("REMOVED, %s:%d\n", __FILE__, __LINE__);exit(-1);
  return -1;
}

void pg4_wait(int devid, int n)
{
  CERR("REMOVED, %s:%d\n", __FILE__, __LINE__);exit(-1);
}

unsigned long pg4_getbaseaddr(int id, int bar)
{
  unsigned long ret;
  if( (bar==0) || (bar==1)){
    int bar0_dword_adr = 0x4;
    ret = pg4_read_pciconfig_dword(id, bar0_dword_adr + bar);
  }else{
    CERR("bar %d invalid | %s:%d\n",bar ,__FILE__ ,__LINE__);
    exit(-1);
  }
  return ret;
}

unsigned long pg4_getbaseaddr_size(int id, int bar)
{
  unsigned long size;
  switch (bar) {
  case 0:
    size = ioctl(pg4_dev[id], IOC_GV_REG_SIZE);
    break;
  case 1:
    size = ioctl(pg4_dev[id], IOC_GV_MEM_SIZE);
    break;
  default :
    CERR("bar%d invalid | %s:%d\n",bar,__FILE__,__LINE__);
    exit (-1);
  }

  return (size); // [Bytes]
}

unsigned long pg4_read_pciconfig_dword(int id, int adr)
{
  // note : 'adr' uses dword address (not byte address).
  return (unsigned long) ioctl(pg4_dev[id], IOC_GV_PCICFG, adr);
}

void pg4_get_pfpga_info(int id, char* ret){
  char info[NB_FPGA_INFO];
  ioctl(pg4_dev[id], IOC_GP_FPGA_INFO, info);
  strcpy(ret, info);
}

void pg4_set_pfpga_info(int id, char* info){
  ioctl(pg4_dev[id], IOC_SP_FPGA_INFO, info);
}
