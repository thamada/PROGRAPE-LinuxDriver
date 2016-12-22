#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#define NMAX 17000

void force(double data_j[][2], double data_i[][2], double count_i[][4], int ni, int nj);

int main(int argc,char** argv)
{
  int i,ni,nj;
  double xj[NMAX][2];
  double xi[NMAX][2];
  double fi[NMAX][4];
  double scale = 1024.0;
  unsigned cnt=0;

  nj = 10000;
  ni = 2;

  srand(0x123457);

  for(i=0;i<ni;i++){
    xi[i][0] = scale*(rand()/(RAND_MAX+1.0) - 0.5);
    xi[i][1] = scale*(rand()/(RAND_MAX+1.0) - 0.5);
    //    printf("xi[%d]: %f, %f\n",i, xi[i][0], xi[i][1]);
    printf("%f\t %f\n",xi[i][0], xi[i][1]);
    fprintf(stderr,"xi[0] : %f\t %f\n",xi[i][0], xi[i][1]);
  }

  for(i=0;i<nj;i++){
    xj[i][0] = scale*(rand()/(RAND_MAX+1.0) - 0.5);
    xj[i][1] = scale*(rand()/(RAND_MAX+1.0) - 0.5);

    //    printf("xj[%d]: %f, %f\n",i, xj[i][0], xj[i][1]);
    printf("%f\t %f\n",xj[i][0], xj[i][1]);
  }

  force(xj, xi, fi, ni, nj);

  for(i=0;i<ni;i++){
    int d;

    fprintf(stderr,"fi[%d]:\t",i);
    fprintf(stderr,"%.0f\t",fi[i][0]);
    fprintf(stderr,"%.0f\t",fi[i][2]);
    fprintf(stderr,"%.0f\t",fi[i][3]);
    fprintf(stderr,"%.0f\t",fi[i][1]);
    fprintf(stderr,"\n");
  }

  return 0;
}


