#!/bin/bash

logfile="/home/lxc/scripts/ch03-bash shell基础命令/test.log"

# 计算结束时间，当前时间加上5分钟
end_time=$(( $(date +%s) + 300 ))

# 循环打印当前时间并写入日志，直到结束时间
while [ $(date +%s) -le $end_time ]
do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo $timestamp | tee -a "$logfile"
    sleep 5
done
