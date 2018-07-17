#!/bin/bash

#Author: wood
#Date: Tue Jul 17 16:00:00 CST 2018
#限制shell里进程的并发数

. /etc/init.d/functions

#定义脚本运行的开始时间
start_time=`date +%s`
#创建有名管道
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1
#关联文件描述符和管道
exec 89<>/tmp/fd1
rm -rf /tmp/fd1

#往管道里放入10个令牌
for ((i=1;i<=10;i++))
do
        echo >&89
done

#循环1000次请求
for ((i=1;i<=1000;i++))
do
    read -u89
    {
        result=$(curl -I -o /dev/null -s -w %{http_code}"\n" "http://www.baidu.com")
        if [[ $result == 200 ]];then
            action "请求成功: $result !" /bin/true
        else
            action "请求失败: $result !" /bin/false
        fi
        sleep 1
        echo >&89
    }&
done
wait

stop_time=`date +%s`  #定义脚本运行的结束时间

echo "TIME:`expr $stop_time - $start_time`"
#关闭文件描述符的读
exec 89<&-
#关闭文件描述符的写
exec 89>&-