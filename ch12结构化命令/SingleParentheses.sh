#!/bin/bash
# Testing a single parentheses condition.
# 
echo $BASH_SUBSHELL
if ( echo $BASH_SUBSHELL )
then
    echo "The Subshell command operated successfully."
else
    echo "The Subshell command NOT successful."
fi