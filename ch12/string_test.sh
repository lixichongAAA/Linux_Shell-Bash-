#!/bin/bash
# using string test evaluations
# 
testUser=lxc
# 
if [ $testUser = lxc ]
then
    echo "The testUser variable contains: lxc"
else
    echo "ths testUser variable contains: $testUser"
fi