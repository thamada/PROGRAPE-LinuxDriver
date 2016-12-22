#include <math.h>
#define DIM 3              /* éüå≥êî */
#define NMAX 65536         /* ç≈ëÂó±éqêî */

void force(double x[][DIM], double m[], double eps2, double a[][DIM], int n);

double energy(double m[], double x[][DIM], double v[][DIM], double eps2, int n);

void leapflog(double dt,double x[][DIM],double v[][DIM],int n);
void leapflog_half(double dt,double x[][DIM],double v[][DIM],int n);

void debug_func_force(double x[][DIM],double m[], double eps2,double a[][DIM],int n);

void debug_position(double x[][DIM], double dt, int n);
void debug_position_snap(double x[][DIM], double Gflops, int n, int nstep);

void writelog(double m[], double x[][DIM], double v[][DIM], double eps2, int n);

void init_particles(char* fname,
		    int* npar,
		    double mass[],
		    double posi[][DIM],
		    double veloc[][DIM]);
