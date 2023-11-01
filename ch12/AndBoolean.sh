#!/bin/bash
# Testing Andboolean compund condition
# 
if [ -d $HOME ] && [ -w $HOME/newfile ]
then
    echo "The file $HOME/newfile exists and you can write to it"
# 
else
    echo "You cannot write to the file."
# 
fi