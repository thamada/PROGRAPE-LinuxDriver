//Time-stamp: "2006-11-18 23:45:07 hamada"

#define FDIM 8       // depend on NBIT_L_UADR     (@ ifpga.vhd)
#define JDIM 8       // depend on dpram adr width (@ pgpg_mem.vhd)
#define XI_AWIDTH 4  // depend on l_adri width    (@ pgpg_mem.vhd)

int pgr_open(int);
void pgr_close(int);

void pgr_reset(int devid);
int  pgr_get_writecomb_err(int devid);

void pgr_setjpset(int devid, unsigned int jdata[][JDIM], int nj);
void pgr_setjpset_one(int devid, int j, unsigned int jdata[JDIM]);

void pgr_setipset(int devid, unsigned int *idata, int num);
void pgr_setipset_ichip(int devid, unsigned int ichip, unsigned int *idata, int number_of_pipelines);
void pgr_setipset_one(int devid, unsigned int ichip, int ipipe, unsigned int *idata, int idim);

void pgr_start_calc(int devid, unsigned int n);
void pgr_calc_start(int devid, unsigned int n);
void pgr_calc_finish(int devid);

void pgr_getfoset(int devid, unsigned long long int fodata[][FDIM]);

void pgr_set_npipe_per_chip(int devid, int n);
void pgr_set_jwidth(int devid, int n);
void pgr_set_nchip(int nchip);
