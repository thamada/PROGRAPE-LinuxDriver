/*
  Copyright(c) 2003-2004 by Tsuyoshi Hamada
  Nbody program for programmable GRAPE
  Last Modified at 2004/04/13
*/
#include <stdio.h>
#include <stdlib.h> // exit()
#include <string.h> // strcpy()
#include "nbodysim.h"


#define PI (3.1415926535897932)
//#define TRIALS_PER_R (6000)
//#define TRIALS_PER_R (300)


//#define N_PLOTS (1920)
//#define N_PLOTS (640)


#define TRIALS_PER_R (300)
#define N_PLOTS (640)


#define XSIZE (1.0)
#define RMAX (XSIZE*2.0)
//#define EPS2 (pow((RMAX*9e-7),2.0))
#define EPS2 (pow((RMAX*1e-6),2.0))


#define MASS (1.0)

//#define R_START (6.6)  //-- for G3
#define R_START (9.9)  //-- for G5

void get_xi(double x[])
{
  x[0] = XSIZE*rand()/(RAND_MAX+1.0);
  x[1] = XSIZE*rand()/(RAND_MAX+1.0);
  x[2] = XSIZE*rand()/(RAND_MAX+1.0);
  if(rand()/(RAND_MAX+1.0)<0.5) x[0] *= -1.0;
  if(rand()/(RAND_MAX+1.0)<0.5) x[1] *= -1.0;
  if(rand()/(RAND_MAX+1.0)<0.5) x[2] *= -1.0;
}

int check_position(double xi[],double xj[],double r)
{
  static unsigned int count=0;
  int d;
  if(r>= RMAX){
    fprintf(stderr,"r(%f)>%f, finished\n",r,RMAX);
    exit(0);
  }
  if(count > 0x4000){
    fprintf(stderr,"r %f\tlog(r/RMAX) %f\n",r,log(r/RMAX)/log(10.0));
    exit(0);
  }
  count++;
  for(d=0;d<3;d++){
    if((xi[d]>=XSIZE)||(xi[d]<=-XSIZE)){
      //      fprintf(stderr,"xi bad \t %f\t%f\t%f\n",xi[0],xi[1],xi[2]);
      return 0;
    }
    if((xj[d]>=XSIZE)||(xj[d]<=-XSIZE)){
      //      fprintf(stderr,"xj bad \t %f\t%f\t%f\n",xj[0],xj[1],xj[2]);
      return 0;
    }
  }
  count=0;
  return 1;
}

void get_xj(double xi[],double r,double theta,double phi,double xj[])
{
  xj[0] = xi[0] + r*cos(phi)*cos(theta);
  xj[1] = xi[1] + r*cos(phi)*sin(theta);
  xj[2] = xi[2] + r*sin(phi);
}

int main(int argc,char** argv)
{
  double x[NMAX][DIM];
  double m[NMAX];
  double radmax=TRIALS_PER_R;
  double r=R_START;
  double eps2 = EPS2;
  int i,k,n=2;

  srand(0x1192296);
  m[0]=MASS;  m[1]=MASS;

  for(k=0;k<N_PLOTS;k++){
    double Sr=0.0;
    double a_host[2][DIM];
    double a_b3[2][DIM];

    r = pow(10,R_START*(k-N_PLOTS)/N_PLOTS)*RMAX;
    for(i=0;i<radmax;i++){
      int j,d, is_in_range;
      double theta,phi;
      is_in_range=0;

      while(is_in_range==0){
	get_xi(x[0]);
	phi   = 2.0*PI*(double)(rand()/(RAND_MAX+1.0));
	theta = 2.0*PI*(double)(rand()/(RAND_MAX+1.0));
	get_xj(x[0],r,theta,phi,x[1]);
	is_in_range = check_position(x[0],x[1],r);
      }

      force_on_host(x,m,eps2,a_host,n);
      force(x,m,eps2,a_b3,n);
      /*************************
      if(0){
	void scale_1f(int n, double x[],    double s, double z[]);
	void scale_3f(int n, double x[][3], double s, double z[][3]);
	double _m[NMAX];
	double _a[NMAX][3];
	double _e;
	double s;
	s = 1.0;
	s = pow(2.0,-18.0);
	scale_1f(n, m, s,             _m);
	force(x,_m,_e,_a, n);
	scale_3f(n, _a, 1.0/s, a_b3);
      }
      *****************************/
      {
	double df2,f2;
	df2 = f2 = 0.0;
	for(d=0;d<DIM;d++) df2 += (a_b3[0][d]-a_host[0][d])*(a_b3[0][d]-a_host[0][d]);
	for(d=0;d<DIM;d++) f2 += a_host[0][d]*a_host[0][d];
	Sr += df2/f2;
      }
    }
    //    exit(0);

    Sr /= (double)(radmax);
    Sr = pow(Sr,0.5);
    printf("%e\t",log(r/XSIZE)/log(10.0));
    printf("%e\t",Sr);
    printf("%e\t",r);


    /****
      printf("%e\t",a_host[0][1]);
      printf("%e |\t",  a_b3[0][1]);
      printf("%e\t",a_host[0][2]);
      printf("%e |\t",  a_b3[0][2]);
      printf("%e\t",a_host[0][3]);
      printf("%e\n",  a_b3[0][3]);
    ***/
    printf("%e\t",a_host[0][0]);
    printf("%e\t",  a_b3[0][0]);
    puts("");    


  }
  return 0;
}



/////////////////////////////////////////
void scale_1f(int n, double x[], double scale, double z[])
{
  int i;
  for(i=0;i<n;i++) z[i] = x[i]*scale;
}

void scale_3f(int n, double x[][3], double scale, double z[][3])
{
  int i;
  for(i=0;i<n;i++){
    z[i][0] = x[i][0]*scale;
    z[i][1] = x[i][1]*scale;
    z[i][2] = x[i][2]*scale;
  }
}
