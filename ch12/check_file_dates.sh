#!/bin/bash
# Compare two file's creation dates/times
#
if [ $HOME/Downloads/games.rpm -nt $HOME/software/games.rpm ]; then
    echo "The $HOME/Downloads/games.rpm is newer"
    echo "than $HOME/software/game.rpm."
#
else
    echo "The $HOME/Downloads/games.rpm is older"
    echo "than $HOME/sorfware/game.rpm."
#
fi

# -nt -ot 这两种测试都不会先检查文件是否存在
# 所以在测试之前，务必确保文件存在.