#!/bin/bash
# using numeric test evaluations

value1=10
value2=11
# 
if [ $value1 -gt 5 ]
then 
    echo "The test value $value1 is greater than 5."
fi

if [ $value1 -eq $value2 ]
then 
    echo "The value are equal."
else
    echo "The value are different."
fi
