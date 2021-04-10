#!/bin/sh
# walkstat.sh

CLEN=3 # number of literals in each clause
N=20 # number of variables
PROBLEMS=50 # number of problems to sample at each ratio

for CNRatio in {1..10}; do
    echo "\nWorking for C/N = $CNRatio"
    C=$((N*CNRatio))
    echo "problemNumber,numFlips" | tee $CNRatio.csv
    for ((i = 0; i < PROBLEMS; i++)) do
        # this is for MacOS, for Linux, use timeout instead of gtimeout
        result=$(./makewff -cnf $CLEN $N $C | gtimeout 10 ./walksat -numsol 1 | grep -B 2 "total elapsed seconds" | head -n 1)
        if [[ -z $result ]]; then # if grep does not succeed, walksat did not terminate successfully
            echo "$((i+1)),-1" | tee -a $CNRatio.csv # -1 numFlips, because was not successful
        else
            arr=($result) # result will store the results of that run of walksat
            echo "$((i+1)),${arr[5]}" | tee -a $CNRatio.csv # the 5th index is the index of the number of flips
        fi
    done
done
