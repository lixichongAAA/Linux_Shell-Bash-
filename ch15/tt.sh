#!/bin/bash
# storing STDOUT, then coming back to it

exec 3>&1
exec 1>test14out

echo "This should store in the output file."
echo "alone with this line."
echo "This should be printed on the screen" >&3

exec 1>&3

echo "Now thing should be back normal."
echo "And me too!" >& 3