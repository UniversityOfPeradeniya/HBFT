



echo HBFT.c >> result.txt
gcc -o t HBFT.c 
./t  test/gm.txt test/im.data >> rsults.txt



echo HBFT.cu >> result.txt
nvcc HBFT.cu helpers.cu -arch=sm_35 -g -G
./a.out  test/gm.txt test/im.data >> rsults.txt


echo HBFTD.cu >> result.txt
nvcc HBFTD.cu helpers.cu -arch=sm_35 -Xptxas -dlcm=ca -rdc=true
./a.out  test/gm.txt test/im.data >> rsults.txt
