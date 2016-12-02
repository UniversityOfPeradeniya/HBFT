/**************************************************************************************************************************************************
|       HBFT algorithm using Dynamic Programming in CUDA with Async memcopy
|       Author : Dinali Rosemin Dabarera
|       University of Peradeniya (EFac 2016) All Rights Reserved
|*************************************************************************************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "helpers.cuh"

/*
* Edge structure
*/
struct Edge {

    int from ;
    int to;
};


/*
* GPU Kernel to check whether the level array is filled or not
*/
__global__ void isLevelFilled(int * level, int * vertices, int * lev) {

    int j = (blockDim.x * blockIdx.x ) + threadIdx.x;

    if(level[j]==-1 && *lev==0) {
        *lev=1;

    }

}

/*
* GPU Kernel to update the level array of each vertex
*/
__global__ void BreadthFirstSearch( struct Edge * adjacencyList, int * vertices, int * level, int * lev, int * edges ) {

    int tid = (blockDim.x * blockIdx.x ) + threadIdx.x;
    *lev = 0;
    if(tid<*edges) {

        struct Edge element = adjacencyList[tid];
        if (level[element.from]>=0 and level[element.to]==-1) {
            level[element.to] = level[element.from]+1;
        }

    }


}

/*
* Main GPU Kernel which call other kernels : Dynamic programming. 
*/
__global__ void parentKenel(struct Edge * adjacencyList, int * vertices, int * level, int * lev, int * edges) {
   
 *lev=1;

    while(*lev==1) {
	/*
         * Update level array
         */
        BreadthFirstSearch<<<ceil(*edges/256.0),256>>> (adjacencyList,vertices,level,lev,edges);
        cudaDeviceSynchronize();
       /*
        * Check level array
        */
        isLevelFilled<<<ceil(*vertices/256.0),256>>>(level,vertices,lev);
        cudaDeviceSynchronize();
    }



}

int max_array(int a[], int num_elements) {
    int i, max=-1;
    for (i=0; i<num_elements; i++) {
        if (a[i]>max) {
            max=a[i];
        }
    }
    return(max);
}



/*
* Main Program starts here. 
*/


int main(int arg,char** args) {

    
   //cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
    cudaDeviceSetCacheConfig(cudaFuncCachePreferShared);

    
    int device =0;
    
    /*
     * Select the GPU card: For Dynamic programing: GPU over 3.5 architecture
     */
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, device);
    cudaSetDevice(device);
    fprintf(stderr,"Device name: %s\n", prop.name);

    
    /*
     * Start Clock
     */
    cudaEvent_t start,stop;
    float elapsedtime;
    cudaEventCreate(&start);
    cudaEventRecord(start,0);





    int noOfRows;
    int   i;
    int v1,v2;
    int finalLevel;

    /*
     * Host variables
     */
    int * Hvertices=(int *) malloc(sizeof(int));
    int * Hedges=(int *) malloc(sizeof(int));
    int * Hlev =(int *)malloc(sizeof(int));
    int * HstartArrayCount = (int *) malloc(sizeof(int));
	

    /*
     * Read data from Graph file
     */
    FILE* fileNew = fopen(args[1], "r");

    fscanf(fileNew, "%d",&finalLevel);
    fscanf(fileNew, "%d %d %d",&noOfRows, Hvertices, Hedges);
  

    int * Hlevel= (int *)malloc(sizeof(int)*(*Hvertices));
    struct Edge * HedgeList =(struct Edge * )malloc(sizeof(struct Edge)*(*Hedges));


    *Hlev = 0;

    for (i = 0; i < *Hvertices; ++i) {

        Hlevel[i] = -1;
    }

    int val;

    for (i = 0; i < *Hedges; ++i) {

        fscanf(fileNew, "%d %d %d",&v1, &v2, &val);

        // Adding edge v1 --> v2
        HedgeList[i].from = v1;
        HedgeList[i].to = v2;

    }

 
    /*
     * Read data from Input vertex file
     */

    FILE * vectorFile= fopen(args[2],"r");
    fscanf(vectorFile,"%d",HstartArrayCount);


    int tempVal;
    for(i=0; i<*HstartArrayCount; i++) {

        fscanf(vectorFile,"%d",&tempVal);

        Hlevel[tempVal]=0;

    }

    /*
     * Device variables
     */

    int * Dvertices;
    int * Dedges;
    int * Dlev ;
    int * DstartArrayCount ;
    int * Dlevel;
    struct Edge * DedgeList ;

    /*
     * Allocate memory on Device
     */
    checkCuda(cudaMalloc((void **)&Dvertices,sizeof(int)));
    checkCuda(cudaMalloc((void **)&Dedges,sizeof(int)));
    checkCuda(cudaMalloc((void **)&Dlev,sizeof(int)));
    checkCuda(cudaMalloc((void **)&DstartArrayCount,sizeof(int)));
    checkCuda(cudaMalloc((void **)&Dlevel,sizeof(int)*(*Hvertices)));
    checkCuda(cudaMalloc((void **)&DedgeList,sizeof(struct Edge)* (*Hedges)));

    /*
     * Copy data from Host to Device
     */
    checkCuda(cudaMemcpyAsync(Dvertices,Hvertices,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(Dedges,Hedges,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(Dlev,Hlev,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(DstartArrayCount,HstartArrayCount,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(Dlevel,Hlevel,sizeof(int)*(*Hvertices),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(DedgeList,HedgeList,sizeof(struct Edge)*(*Hedges),cudaMemcpyHostToDevice));


   /*
    * Main kernel call
    */
    parentKenel<<<1,1>>>(DedgeList,Dvertices,Dlevel,Dlev,Dedges);
    cudaDeviceSynchronize();
    checkCudaError();
    checkCuda(cudaMemcpy(Hlevel,Dlevel,sizeof(int)*(*Hvertices),cudaMemcpyDeviceToHost));


    /*
     * Free memory on the Device
     */
    cudaFree(Dvertices);
    cudaFree(Dedges);
    cudaFree(Dlev);
    cudaFree(DstartArrayCount );
    cudaFree(Dlevel);
    cudaFree(DedgeList);

    /*
     * Stop the Clock
     */
    cudaEventCreate(&stop);
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedtime,start,stop);

    printf("%d, %d, %.8f \n",*Hvertices, *Hedges,elapsedtime/(float)1000);

    /*
     * Print vertices according to the level order
     */
      	 printf("\nLevel and Parent Arrays -\n");
               for (i = 0; i < *Hvertices; ++i) {
                    printf("Level of Vertex %d is %d\n",
                                              i, Hlevel[i]);
                }

                printf("vertices in level order when traversing :\n");

                int b;
                 for(b=0;b<=max_array(Hlevel,*Hvertices);b++){
                   for (i = 0; i < *Hvertices; ++i) {
                       if(Hlevel[i]==b){
                            printf("%d ,", i);
                       }

                   }
                    printf("  |  ");
                 }
 
    /*
     * Free Host memory
     */
    free(Hvertices);
    free(Hedges);
    free(Hlev);
    free(HstartArrayCount );
    free(Hlevel);
    free(HedgeList);


    return 0;
}
