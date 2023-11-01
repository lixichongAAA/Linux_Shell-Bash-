#!/bin/bash
# Check if object exist and is a directory or a file
# 
object=$HOME
echo
echo "The object being chekced: $object"
echo
# 
if [ -e $object ]
then
    echo "The object, $object does exists,"
    # 
    if [ -f $object ]
    then
        echo "and $object is a file."
    # 
    else
        echo "and $object is a directory."
    fi
else
    echo "The object, $object does NOT exist."
fi
# -e 用于检查文件或者目录是否存在