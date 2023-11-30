#!/bin/bash
# using string test evaluations
# 
testUser=rich
# 
if [ $testUser = lxc ]
then
    echo "The testUser variable contains: lxc"
else
    echo "ths testUser variable NOT contains: lxc"
fi