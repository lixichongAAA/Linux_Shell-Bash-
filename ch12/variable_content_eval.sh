#!/bin/bash
# Testing string length
# -n 长度是否不为0、-z 长度是否为0
string1="soccer"
string2=''

if [ -n $string1 ]
then
    echo "The string '$string1' is NOT empty."
else
    echo "The string '$string1' IS empty."
fi

if [ -z $string2 ]
then
    echo "The string '$string2' IS empty."
else    
    echo "The string '$string2' is NOT empty"
fi

if [ -z $string3 ]
then 
    echo "The string '$string2' IS empty."
else    
    echo "The string '$string2' is NOT empty"
fi 