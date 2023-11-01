#!/bin/bash
# Check if you own a file
if [ -O /etc/passwd ]; then
    echo "Yeah, you are owner of the /etc/passwd file."
else
    echo "Sorry, you are NOT /etc/passwd file's owner."
fi

# 以root用户运行会走if分支