#!/bin/bash
# continuing an outer loop

for ((a = 1; a <= 8; a++)); do
    echo "Outer loop: $a"
    for ((b = 1; b <= 3; b++)); do
        if [ $a -gt 3 ] && [ $a -lt 6 ]; then
            continue 2
        fi
        var3=$(($a * $b))
        echo "  The result of $a * $b is $var3."
    done
done
echo "Done."
