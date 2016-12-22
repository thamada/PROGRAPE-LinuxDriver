/*
 * pfpga_conf.c
 *
 * Copyright (C) 2006-2007 Tsuyoshi Hamada
 *                                All rights reserved.
 * 
 * No warranty is attached; 
 * I cannot take responsibility for errors or fitness for use.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>     // usleep
#include "pg4.h"

static char pfpga_info[256];
#define CNF_CMD_ADR 0x80
#define CNF_DAT_ADR 0x84

static unsigned int *data;

void get_header(char* bitfile, char* header)
{
  int index=0, x;
  char buf[128];
  
  index += 2 + (((0xff&bitfile[index])<<8) | (0xff&bitfile[index+1]));
  index += 2 + (((0xff&bitfile[index])<<8)|(0xff&bitfile[index+1]));

  // --- NCD file name ---
  x = ((0xff&bitfile[index])<<8)|(0xff&bitfile[index+1]);
  //  memcpy(buf, &bitfile[index+2], x);
  //  sprintf(header, "%s, %s", header, buf);

  // --- device ---
  index += (x+3);
  x = ((0xff&bitfile[index])<<8)|(0xff&bitfile[index+1]);
  memcpy(buf, &bitfile[index+2], x);
  sprintf(header, "%s, %s", header, buf);

  // --- data ---
  index += (x+3);
  x = ((0xff&bitfile[index])<<8)|(0xff&bitfile[index+1]);
  memcpy(buf, &bitfile[index+2], x);
  sprintf(header, "%s, %s", header, buf);

  // --- time ---
  index += (x+3);
  x = ((0xff&bitfile[index])<<8)|(0xff&bitfile[index+1]);
  memcpy(buf, &bitfile[index+2], x);
  sprintf(header, "%s, %s", header, buf);

  // --- key ---
  index += (x+3);
  x = ((0xff&bitfile[index])<<8)|(0xff&bitfile[index+1]);
  //  memcpy(buf, &bitfile[index+2], x);
  //  sprintf(header, "%s, %s", header, buf);


}



int fread_config_data(char* fname, unsigned int *size)
{
  // -- Read Config File to 'config_bit_data'---
  FILE* fin;
  int ndata;
  int i;

  struct stat buf;
  int fsize;

  // read file status
  if (stat(fname, &buf) == -1) {
    fprintf(stderr, "fread_config_data: can't open bit file!!! %s\n", fname);
    exit(-1);
  }

  fsize = buf.st_size;
  if (data != NULL) {
    free(data);
  }
  data = (unsigned int*)malloc(fsize);
  if (data == NULL) {
    fprintf(stderr, "fread_config_data: memory allocation error!\n");
    exit(-1);
  }
  
  fin = fopen(fname, "r");
  if (fin == NULL) {
    fprintf(stderr, "fread_config_data: cannot open %s!\n", fname);
    exit(-1);
  }
  fread(data,fsize,1,fin);
  fclose(fin);
  fprintf(stderr, "fread_config_data: read %i bytes.\n", fsize);

  get_header((char*)data, pfpga_info);

  
  ndata = fsize/sizeof(unsigned int);

  // CHANGE ENDIAN (LittleEndian -> BigEndian)
  for(i = 0;i < ndata; i++){
    unsigned int byte[8];
    byte[0] = 0xFF&(data[i]>>24);
    byte[1] = 0xFF&(data[i]>>16);
    byte[2] = 0xFF&(data[i]>>8);
    byte[3] = 0xFF&(data[i]);
    data[i]=0x0;
    data[i]= (byte[3]<<24)|(byte[2]<<16)|(byte[1]<<8)|byte[0];
  }

  *size = (unsigned int)ndata;

  return fsize;
}

void config_onechip(int devid, unsigned int nfp, unsigned int ncfgdata)
{
  unsigned int i, d;
  unsigned int *p;

  if (data == NULL) return;
  if (nfp > 0x8) {
    fprintf(stderr, "nfp err\n");
    exit(-1);
  } 

  // ---------------------------------------- SETUP CONFIGURATION
  d = (unsigned int)(0xf0|nfp);
  WriteBase0(devid, CNF_CMD_ADR, d);
  d = (unsigned int)(  ((0xF^nfp)<<4)   |nfp);
  WriteBase0(devid, CNF_CMD_ADR, d);
  d = (unsigned int)(0xf0|nfp);
  WriteBase0(devid, CNF_CMD_ADR, d);
  usleep(15000);

  // ---------------------------------------- SEND CONFIGURATION DATA
  p = data;
  for(i = 0; i < ncfgdata; i++){
    WriteBase0(devid, CNF_DAT_ADR, *(p++));
    d = (unsigned int)(0x1f0|nfp);
    WriteBase0(devid, CNF_CMD_ADR,      d);
    WriteBase0(devid, CNF_CMD_ADR, 0xff&d);
  }

  // ---------------------------------------- STOP CFG_CCLK
  d = (unsigned int)(0xf0);
  WriteBase0(devid, CNF_CMD_ADR,d);
}

void config_pfpga_all(int devid, char* fname)
{
  unsigned int i, nfp, ncfgdata;

  data = NULL;
  fread_config_data(fname, &ncfgdata);

  for(i = 0; i < 4; i++) {
    nfp = 0xf&(0x1<<i);
    fprintf(stderr, "configuring chip%i ...\n", i);
    config_onechip(devid, nfp, ncfgdata);
  }

  free(data);
}

int main(int argc, char* argv[])
{
  int devid;

  if (argc < 2) {
    fprintf(stderr, "%s <bitfile> <devid>\n", argv[0]);
    exit(-1);
  }
  if (argv[2] == NULL) {
    devid = 0;
  } else {
    devid = atoi(argv[2]);
    if (devid > 2) {
      fprintf(stderr, "%s : invalid argument <devid>%s:%d\n", argv[0], __FILE__, __LINE__);
      exit(-1);
    }
  }
  fprintf(stderr, "%s configures all PFPGAs on progrape%i ...\n", argv[0], devid);

  pg4_open(devid);

  {
    pg4_get_pfpga_info(devid, pfpga_info);
    printf("----------------------\n");
    printf("Previous config info: \n");
    printf("%s\n",pfpga_info);
    printf("----------------------\n");
  }

  {
    sprintf(pfpga_info, "%s",argv[1]);
    config_pfpga_all(devid, argv[1]);
    pg4_set_pfpga_info(devid, pfpga_info);
  }

  {
    pg4_get_pfpga_info(devid, pfpga_info);
    printf("----------------------\n");
    printf("Current config info: \n");
    printf("%s\n",pfpga_info);
    printf("----------------------\n");
  }

  pg4_close(devid);

  return 0;
}
