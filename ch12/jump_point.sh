#!/bin/bash
# Look before you leap
# 
jump_directory=/home/lxc
# 
if [ -d $jump_directory ]
then
    echo "The directory '$jump_directort' exists."
    cd $jump_directort
    ls
else
    echo "The $jump_directory directory does NOT exist."
fi