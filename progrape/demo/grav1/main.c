/*
  Time-stamp: <2007-01-24 01:34:38 hamada>
  Copyright(c) 2003-2006 by Tsuyoshi Hamada. All rights reserved.
  Nbody program for PGR
  Last Modified at 2005/01/02
*/
#include <stdio.h>
#include <stdlib.h> // exit()
#include <string.h> // strcpy()
#include "nbodysim.h"
#include "flops.h"

// init.plummer.2048 --------------------
#define EPS2 0.0001
#define TIMESTEP 0.005

//#define TMAX 0x7fffffff
//#define TMAX 6000
#define TMAX 1500



//---------------------------------------.

double get_max_dim3(int n,double x[][3]);
double get_max_dim1(int n,double x[]);
void set_range(double xfac, double mfac);

int main(int argc,char** argv)
{
  struct flops_member flops;
  double posi[NMAX][DIM];
  double mass[NMAX];
  double eps2 = EPS2;
  double accel[NMAX][DIM];
  double veloc[NMAX][DIM];
  int n;
  double dt = TIMESTEP;
  int time;
  int timemax=TMAX;
  double Eini=0.0;
  double Eesu=0.0;
  double Enew=0.0;
  double Eold=0.0;
  double xfac,mfac;


  int i,j,d;


  /* initialize particles  */
  {
    char datafile[256];
    strcpy(datafile,argv[1]);
    init_particles(datafile,&n,mass,posi,veloc);
  }

  mfac = 100.0/get_max_dim1(n,mass);
  xfac = 0.5/get_max_dim3(n,posi);
  set_range(xfac, mfac);


  force(posi,mass,eps2,accel,n);


  flops_initialize(&flops, n, 50);
#ifdef HOST
  flops_initialize(&flops, n, 2);
#endif

  for(time=0;time<timemax;time++){
    debug_position_snap(posi, (flops.Gflops) ,n,time);
    //    debug_position_snap(posi, (777.777) ,n,time);
    flops_ftime_init(&flops); //-------------------------------------- LAP START
    leapflog_half(dt,veloc,accel,n);
    leapflog(dt,posi,veloc,n);

    xfac = 0.5/get_max_dim3(n,posi);
    set_range(xfac, mfac);
    force(posi,mass,eps2,accel,n);
    

    leapflog_half(dt,veloc,accel,n);
    flops_ftime_save(&flops); //-------------------------------------- LAP END.
    flops_check(&flops);
  }

  return 0;
}










double get_max_dim3(int n,double x[][3])
{
  double xmax;
  int i;
  xmax = -1e32;

  for(i=0;i<n;i++){
    int d;
    for(d=0;d<DIM;d++){
      double xx = fabs(x[i][d]);
      if(xx > xmax) xmax = xx;
    }
  }
  return (xmax);
}

double get_max_dim1(int n,double x[])
{
  double xmax;
  int i;
  xmax = -1e32;

  for(i=0;i<n;i++){
    int d;
    double xx = fabs(x[i]);
    if(xx > xmax) xmax = xx;
  }
  return (xmax);
}





