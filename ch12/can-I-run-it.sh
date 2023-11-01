#!/bin/bash
# Check if you can run a file
# 
item_name=$HOME/scripts/can-I-write-to-it.sh
echo
# 
echo "Cheking if a file executable."
# 
if [ -x $item_name ]
then
    echo "You can file $item_name."
    echo "Running $item_name..."
    $item_name
    echo "done."
# 
else
    echo "You cannot run $item_name."
fi