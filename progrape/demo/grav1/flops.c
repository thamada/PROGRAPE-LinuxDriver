#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "flops.h"
//#include "pg_util.h" // double e_time(void)

extern double e_time(void);

void flops_initialize(struct flops_member* fm, int n, int nskip)
{
  (*fm).nbody = n;
  (*fm).nskip = nskip;
  (*fm).times = 0;
  (*fm).nstep = 0;
  (*fm).force_time = 0.0;
  (*fm).start_time = e_time();
}

void flops_check(struct flops_member* fm)
{
  int n = (*fm).nbody;
  int nskip = (*fm).nskip;
  int nstep = (*fm).nstep;
  int times = (*fm).times;
  double t_start = (*fm).start_time;
  double tmisc,tall;
  double nope,Gflops;
  double t_end;
  nstep++;

  if((times % nskip) != (nskip-1)){
    times++;
  } else {
    double tforce = (*fm).force_time;
    t_end = e_time();
    tall = t_end - t_start;
    tmisc = tall - tforce;
    nope  = (38.0*n*n + 8.0*n  )*(double)times; // Gravity
    //       GRAVITY,  LEAPFLOG
    (*fm).Gflops = Gflops = nope * 1.0e-9 / tall;
    fprintf(stderr,"[%d steps]\t",nstep);
    fprintf(stderr,"LapTime %2.2f sec\t",tall);
    fprintf(stderr,"\t \t == %g Gflops ==\n",Gflops);

    fprintf(stderr,"\t + Force (calc + communi. ) (%g sec) \t %02.3f %%\n", tforce,  100.0*tforce/tall);
    fprintf(stderr,"\t + Misc  (time integ, etc.) (%g sec) \t %02.3f %%\n", tmisc,   100.0*tmisc/tall);

    times = 0;
    t_start = e_time();
  }
  (*fm).times = times;
  (*fm).nstep = nstep;
  (*fm).start_time = t_start;
}



void flops_ftime_init(struct flops_member *fm){
  (*fm).force_time = e_time();
}

void flops_ftime_save(struct flops_member *fm){
  double dum = (*fm).force_time;
  (*fm).force_time = e_time() - dum;
}


