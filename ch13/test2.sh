#!/bin/bash
# another example of how not to use the for command

for test in I don\'t know if "this'll" work; do
    echo "word:$test"
done
# 在第一个有问题的地方使用反斜线进行了转义，第二个有问题的地方，将this'll放在了双引号内，
# 这两种方法都管用.