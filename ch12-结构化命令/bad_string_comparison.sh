#!/bin/bash
# Misusing string comparisons
# 
string1=soccer
string2=zfootball
# 
if [ $string1 > $string2 ] # 这是错误的，> 会被shell解释成输出重定向.
then
    echo "$string1 is greater than $string2."
else
    echo "$string1 is less than $string2."
fi
