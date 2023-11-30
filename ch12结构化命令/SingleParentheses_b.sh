#!/bin/bash
# Testing a single parenthese condition.
# 
# echo $BASH_SUBSHELL
# 
if ( cat /etc/PASSWD )
then    
    echo "The subshell command operated successfully."
else
    echo "The subshell command operated NOT successful."
fi  