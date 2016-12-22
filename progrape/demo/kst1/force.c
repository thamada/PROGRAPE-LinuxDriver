#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#define NMAX 16384

void force(double data_j[][2], double data_i[][2], double count_i[][4], int ni, int nj)
{
  int i,j;

  for(i=0;i<ni;i++){
    double orig_x,orig_y;
    orig_x = data_i[i][0];
    orig_y = data_i[i][1];

    count_i[i][0]=0;
    count_i[i][1]=0;
    count_i[i][2]=0;
    count_i[i][3]=0;

    for(j=0;j<nj;j++){
      double vec_x, vec_y;
      int flag_x,flag_y;
      int bit=0;
      vec_x = data_j[j][0];
      vec_y = data_j[j][1];

      if(vec_x > orig_x){
	flag_x = 1;
      }else{
	flag_x = 0;
      }

      if(vec_y > orig_y){
	flag_y = 1;
      }else{
	flag_y = 0;
      }

      bit = ((0x1&flag_x) <<1)| (0x1&flag_y) ;

      if(bit == 0){           // 0,0   ---> 第3象限
	count_i[i][3] += 1.0;

      }else if(bit == 1){     // 0,1   ---> 第2象限
	count_i[i][2] += 1.0;

      }else if(bit == 2){     // 1,0   ---> 第4象限
	count_i[i][1] += 1.0;

      }else if(bit == 3){     // 1,1   ---> 第1象限
	count_i[i][0] += 1.0;

      }else{
	fprintf(stderr,"Error at %s, %d\n",__FILE__, __LINE__);
	exit(-1);
      }
      //      printf("%d\t%x\t%e\n",j,bit,count_i[i][0]);

    }
  }

}  
