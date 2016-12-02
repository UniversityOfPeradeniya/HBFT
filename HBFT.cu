/**************************************************************************************************************************************************
|       HBFT algorithm without Dynamic Programming in CUDA 
|       Author : Dinali Rosemin Dabarera
|       University of Peradeniya (EFac 2016) All Rights Reserved
|*************************************************************************************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "helpers.cuh"

/*
* Edge structure.
*/
struct Edge {

    int from ;
    int to;
};


/*
* CPU function to check level array.
*/
int isLevelFilled(int * level, int * vertices) {
    int i;
    for(i=0; i<*vertices; i++) {
        if(level[i]==-1) {
            return 1;

        }

    }

    return 0;


}

/*
* GPU Kernel to update the level array of each vertex.
*/
__global__ void BreadthFirstSearch( struct Edge * adjacencyList, int * vertices, int * level, int * edges ) {

    int tid = (blockDim.x * blockIdx.x ) + threadIdx.x;
    if(tid<*edges) {

        struct Edge element = adjacencyList[tid];
        if (level[element.from]>=0 and level[element.to]==-1) {
            level[element.to] = level[element.from]+1;
        }

    }


}


/*
* Main Program starts here. 
*/
int main(int arg,char** args) {




    cudaEvent_t start,stop;
    float elapsedtime;
    cudaEventCreate(&start);
    cudaEventRecord(start,0);

     /*
     * Select the GPU card: For Dynamic programing: GPU over 3.5 architecture
     */
    int device =0;
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, device);
    cudaSetDevice(device);
    fprintf(stderr,"Device name: %s\n", prop.name);


    int   i;
    int v1,v2;
    int count=1;
    int finalLevel;

    /*
     * Host variables
     */
    int * Hvertices=(int *) malloc(sizeof(int));
    int * Hedges=(int *) malloc(sizeof(int));
    int * HstartArrayCount = (int *) malloc(sizeof(int));



    /*
     * Read data from Graph file
     */
    FILE* fileNew = fopen(args[1], "r");

    fscanf(fileNew, "%d ",&finalLevel);
    fscanf(fileNew, "%d %d %d",Hvertices, Hvertices, Hedges);




    int * Hlevel= (int *)malloc(sizeof(int)*(*Hvertices));
    struct Edge * HedgeList =(struct Edge * )malloc(sizeof(struct Edge)*(*Hedges));


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
    int * DstartArrayCount ;
    int * Dlevel;
    struct Edge * DedgeList ;



    /*
     * Allocate memory on Device
     */
    checkCuda(cudaMalloc((void **)&Dvertices,sizeof(int)));
    checkCuda(cudaMalloc((void **)&Dedges,sizeof(int)));
    checkCuda(cudaMalloc((void **)&DstartArrayCount,sizeof(int)));
    checkCuda(cudaMalloc((void **)&Dlevel,sizeof(int)*(*Hvertices)));
    checkCuda(cudaMalloc((void **)&DedgeList,sizeof(struct Edge)* (*Hedges)));


    /*
     * Copy data from Host to Device
     */
    checkCuda(cudaMemcpyAsync(Dvertices,Hvertices,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(Dedges,Hedges,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(DstartArrayCount,HstartArrayCount,sizeof(int),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(Dlevel,Hlevel,sizeof(int)*(*Hvertices),cudaMemcpyHostToDevice));
    checkCuda(cudaMemcpyAsync(DedgeList,HedgeList,sizeof(struct Edge)*(*Hedges),cudaMemcpyHostToDevice));

   /*
    * Itterative Kernel call
    */
    while(isLevelFilled(Hlevel,Hvertices)) {

        BreadthFirstSearch<<<ceil(*Hedges/256.0),256>>>(DedgeList,Dvertices,Dlevel,Dedges);
        cudaDeviceSynchronize();
        checkCudaError();

        count ++;

        checkCuda(cudaMemcpy(Hlevel,Dlevel,sizeof(int)*(*Hvertices),cudaMemcpyDeviceToHost));
    }

   /*
    * Copy Memory back from Device to Host
    */
    checkCuda(cudaMemcpy(Hlevel,Dlevel,sizeof(int)*(*Hvertices),cudaMemcpyDeviceToHost));



    /*
     * Free memory on the Device
     */
    cudaFree(Dvertices);
    cudaFree(Dedges);
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
                 for(b=0;b<=count;b++){
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
    free(HstartArrayCount );
    free(Hlevel);
    free(HedgeList);

    return 0;
}
