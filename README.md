# HBFT
###A new Bredth First Traversal variation for large graphs 

## Introduction

HBT is the algorithm that was found as a result of Final Year Undergraduate Research Project done by me under the supervision of Dr.Roshan Ragel.
We tested different ways of BFS methods on GPU for large circuit graphs such as SMVP-BFT(Sparse matrix Vector Product Implementation  of Breadth-First Traversal(BFT)) and Linked list implementation of BFT (LL-BFT). SMVP-BFT is commonly seen in previous Related Works and LL-BFT failed due to memory limitations of NVIDIA GPU during memory malloc. This basically consists of two data structures. An array of **Edge** data structures to store Edges of the graph and a array of Integers to store the levels of each vertices.

## HBFT.c
This is a single threaded C implemenation of HBFT. Checking and updating the level array happens itteratively.


## HBFT.cu
This is written in CUDA and Dynamic programing is not used here. Async Mem copy is used in order to save time.

## HBFTD.cu

This is written with the use of Dynamic parallism in CUDA. Async Mem copy is used in order to save time.


## Advantages
The CPU implementation of H-BFT is about 75x faster than the CPU implementation of the state of the art. we have accelerated both the state of the art SMVP based BFT implementation and our new H-BFT implementation. The best
speedups we achieved via these accelerations are 180x and 25x
for the SMVP-BFT and H-BFT respectively.

## Tests


gcc -o t HBFT.c 
./t  tests/gm.txt tests/im.data >> rsults.txt


nvcc HBFT.cu helpers.cu -arch=sm_35 -g -G
./a.out  tests/gm.txt tests/im.data >> rsults.txt


nvcc HBFTD.cu helpers.cu -arch=sm_35 -Xptxas -dlcm=ca -rdc=true
./a.out  tests/gm.txt tests/im.data >> rsults.txt

## Contributors
####Dinali R. Dabarera, Himesh Karunarathna, Erandika Harshani and Roshan G. Ragel
Department of Computer Engineering
Faculty of Engineering
University of Peradeniya, Sri Lanka
Email:gdrdabarera@gmail.com, himeshsameera@gmail.com, harshanierandikanr@gmail.com, ragelrg@gmail.com


