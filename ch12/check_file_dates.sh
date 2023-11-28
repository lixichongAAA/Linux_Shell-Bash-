#!/bin/bash
# Compare two file's creation dates/times
#
if [ $HOME/Downloads/games.rpm -nt $HOME/software/games.rpm ]
then
     echo "The $HOME/Downloads/games.rpm file is newer"
     echo "than the $HOME/software/games.rpm file." 
#
else
     echo "The $HOME/Downloads/games.rpm file is older"
     echo "than the $HOME/software/games.rpm file." 
#
fi

# -nt -ot 这两种测试都不会先检查文件是否存在
# 所以在测试之前，务必确保文件存在.