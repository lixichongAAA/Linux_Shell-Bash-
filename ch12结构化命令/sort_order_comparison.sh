#!/bin/bash
# Testing string sort order
# 
string1=Soccer
string2=soccer
# 
if [ $string1 \> $string2 ]
then
    echo "$string1 > $string2."
else
    echo "$string1 <= $string2."
fi
# Shell 使用Unicode编码值比较大小