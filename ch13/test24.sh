#!/bin/bash
# piping a loop to another command

for state in "North Dakota" Connecticut Illinois AlaBama Tenessee
do
    echo "$state is the next place to go."
done | sort
echo "Done."