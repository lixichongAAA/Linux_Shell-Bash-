#!/bin/bash
# using a global variable to pass a value

dbl() {
    value=$[ $value * 2 ]
}

read -p "Enter a value: " value
dbl
echo "The new value is $value"