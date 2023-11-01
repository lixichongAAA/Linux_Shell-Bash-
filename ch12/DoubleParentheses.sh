#!/bin/bash
# Testing a double parenthese command
#
var1=10
#
if (($var1 ** 2 > 90)); then
    ((var2 = $var1 ** 2))
    echo "The square of $var1 = $var2,"
    echo "which is greater than 90."
fi
