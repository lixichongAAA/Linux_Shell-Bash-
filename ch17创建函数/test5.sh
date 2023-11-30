#!/bin/bash
# Using the return command in a funtion

dbl() {
    read -p "Enter a value: " value
    echo "doubling the value"
    return $[ $value * 2 ]
}

dbl
echo "The new value is $?"