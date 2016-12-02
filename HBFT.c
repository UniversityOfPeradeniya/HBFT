/**************************************************************************************************************************************************
|       HBFT algorithm in C
|       Author : Dinali Rosemin Dabarera    
|       University of Peradeniya (EFac 2016)  All Rights Reserved
|*************************************************************************************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

/*
* Edge structure
*/
struct Edge {

    int from ;
    int to;
};


/*
* Check whether the level array has -1 values.
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
* BFT : Update level array.
*/
void BreadthFirstSearch(struct Edge * adjacencyList,int * level,  int * edges) {
    int k;
    struct Edge element;
    for(k=0; k<*edges; k++) {
        element = adjacencyList[k];
        if ((level[element.from]>=0)&&(level[element.to]==-1)) {
            level[element.to] = level[element.from]+1;
        }

    }


}


/*
* Main Finction : Code starts here.
*/
int main(int arg,char** args) {

   
    clock_t begin, end;
    double time_spent;
    begin = clock();




    int noOfRows;
    int   i;
    int v1,v2;
    int count = 1;

    int finalLevel;

   /*
    * Allocate Host memory
    */
    int * vertices=(int *) malloc(sizeof(int));
    int * edges=(int *) malloc(sizeof(int));
    int * startArrayCount = (int *) malloc(sizeof(int));

    /*
     * Read the Graph file : Edges
     */
    FILE* fileNew = fopen(args[1], "r");

    fscanf(fileNew, "%d",&finalLevel);
    fscanf(fileNew, "%d %d %d",&noOfRows, vertices, edges);



    int * level= (int *)malloc(sizeof(int)*(*vertices));

    struct Edge * edgeList =(struct Edge * )malloc(sizeof(struct Edge)*(*edges));



    for (i = 0; i < *vertices; ++i) {
        level[i] = -1;
    }

    int val;

    for (i = 0; i < *edges; ++i) {

        fscanf(fileNew, "%d %d %d",&v1, &v2, &val);
        // Adding edge v1 --> v2
        edgeList[i].from = v1;
        edgeList[i].to = v2;

    }


   /*
    * Read the input file : Input nodes
    */
    FILE * vectorFile= fopen(args[2],"r");
    fscanf(vectorFile,"%d",startArrayCount);



    int tempVal;

    for(i=0; i<*startArrayCount; i++) {

        fscanf(vectorFile,"%d",&tempVal);
        level[tempVal]=0;

    }

    /*
     * Update level array and check level array
     */
    while(isLevelFilled(level,vertices)) {
        BreadthFirstSearch(edgeList,level,edges);
        count ++;
    }



    /*
     * End clock
     */
    end = clock();
            
       /*
        * Print the vertices according to the level order
        */  
        printf("\nLevel and Parent Arrays -\n");
        for (i = 0; i <*vertices; ++i) {
            printf("Level of Vertex %d is %d\n",
                                      i, level[i]);
        }

        printf("vertices in level order when traversing :\n");

        int b;
         for(b=0;b<=count;b++){
           for (i = 0; i < *vertices; ++i) {
               if(level[i]==b){
                    printf("%d ,", i);
               }

           }
            printf("  |  ");
         }

 
    time_spent = (double)(end - begin) / CLOCKS_PER_SEC;

    printf("%d, %d, %lf \n",*vertices,*edges,time_spent);

   /*
    * Free Host memory
    */
    free(level);
    free(edgeList);
    free(vertices);
    free(edges);
    free(startArrayCount);

    return 0;

}
