#include <stdio.h>
#include "nbodysim.h"

void debug(double x[][DIM],double a[][DIM], int n, int nstep)
{
  int i;
  static int flag=0;
  static FILE* fp;

  if(flag==0){
    fp = fopen("aaa.log","w");
    flag = 1;
  }else{
    rewind(fp);
  }

  for(i=0;i<n;i++){
    fprintf(fp,"%d\t",nstep);
    fprintf(fp,"%1.8e\t%1.8e\t%1.8e\t",x[i][0],x[i][1],x[i][2]);
    fprintf(fp,"%1.8e\t%1.8e\t%1.8e\n",a[i][0],a[i][1],a[i][2]);
  }

  fflush(fp);
}

