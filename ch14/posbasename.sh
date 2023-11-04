#!/bin/bash
# Using basename with the $0 command-line parameter.
# 
name=$( basename $0 )
# 
echo The script name is $name
exit