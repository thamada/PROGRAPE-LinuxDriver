// Time-stamp: " "
#include <stdio.h> 
#include <string.h>
#include <stdlib.h>

void read_data(char* fname, int* nbody, double posi[][2])
{
  int idx,n;
  char line[2560];
  FILE *fp;
  fp = fopen(fname,"r");
  idx=0;

  { // get N (number of particles)
    char* p;
    fgets(line,100,fp);
    p = (char* )strtok(line,"\n");
    sscanf(p,"%d",&n);
    *nbody = n;
  }

  // get all data
  for(idx=0;idx<n;idx++){
    char* p;
    char col[10][400];
    int i=0;
    if(fgets(line,300,fp)==NULL){printf("Error at loading logfiles\n");exit(0);}
    p = (char* )strtok(line,"\t");
    strcpy(col[i],p);
    i++;
    while((p = (char* )strtok(NULL, "\t"))!=NULL){
      strcpy(col[i],p);
      i++;
    }
    //--- for debug ---
    //    for(i=0;i<7;i++) printf("[%s]",col[i]);
    //    printf("\n");

    posi[idx][0]=atof(col[0]);
    posi[idx][1]=atof(col[1]);
  }
  fclose(fp);
}
