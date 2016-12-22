/***************************************************
 * The lowest level library for PROGRAPE-4
 *
 * Copyright(c) by Tsuyoshi Hamada.
 * All rights reserved.
 *
 * PLEASE DO NOT BRANCH !!
 *
 * 20060916.rev1 : Development start
 *
 ***************************************************/

inline unsigned int    ReadBase0 (int devid, unsigned int addr);
inline unsigned int    ReadBase1 (int devid, unsigned int addr);
inline void            WriteBase0 (int devid, unsigned int addr, unsigned int val);
inline void            WriteBase1 (int devid, unsigned int addr, unsigned int val);

void                   pg4_close (int id);

int                    pg4_DMAput (int devid, unsigned int size);
int                    pg4_DMAget (int devid, unsigned int size);
void                   pg4_DMAcheck (int devid);
int                    pg4_DMAretry (int devid);

unsigned long          pg4_getbaseaddr (int devid, int j);
unsigned long          pg4_getbaseaddr_size (int devid, int bar);
unsigned int*          pg4_get_bar0ptr(int devid);
unsigned int*          pg4_get_bar1ptr(int devid);
unsigned int*          pg4_get_dmawptr (int devid);
unsigned int*          pg4_get_dmarptr (int devid);
unsigned int           pg4_get_dma_size (int devid);
void                   pg4_get_pfpga_info (int devid, char *info);

int                    pg4_open (int id);

inline unsigned int    pg4_readbase0 (int devid, unsigned int index);
inline unsigned int    pg4_readbase1 (int devid, unsigned int index);
unsigned long          pg4_read_pciconfig_dword (int devid, int adr);

void                   pg4_set_pfpga_info (int devid, char *info);

inline void            pg4_writebase0 (int devid, unsigned int index, unsigned int val);
inline void            pg4_writebase1 (int devid, unsigned int index, unsigned int val);



// --- following are removed. ---
int                    pg4_DMAput_offset (int devid, unsigned int size, unsigned offset);
int                    pg4_DMAget_offset (int devid, unsigned int size, unsigned offset);
void                   pg4_wait (int devid, int n);


