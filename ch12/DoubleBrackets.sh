#!/bin/bash
# Using double brackets for pattern matching
# 
if [[ $BASH_VERSION == 5.* ]]
then
    echo "You are using bash shell 5 series."
fi