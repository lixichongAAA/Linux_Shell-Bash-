#!/bin/bash
# Using a alternative file descriptor

exec 3> test13out

echo "This should display on monitor"
echo "and this should be stored in the file" >&3
echo "Then this should be back on the monitor."