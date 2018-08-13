#!/bin/bash
#Author: wood
#Date: Mon Aug 13 19:00:00 CST 2018
#用做启动java进程的脚本

# Source function library.
. /etc/rc.d/init.d/functions

usage(){

   echo "----------------USAGE:------------------" 
   echo "$0  start    start app&watcher"
   echo "$0  end      end app&watcher"
   echo "$0  run      run only app"
   echo "$0  stop     stop only app"
   echo "$0  restart  restart app&watcher"
   echo "-----------------------------------------"
}

cmd=$1

module=test-fs
appmodule=${module}-app
watchermodule=${module}-watcher

DEPLOY_DIR=`pwd`
APP_SPRING_CONTEXT=classpath:/spring/spring-composite.xml

WATCHER_JAVA_OPTS="-Xms128m  -Xmx256m -XX:PermSize=128M -XX:MaxPermSize=256m"

APP_JAVA_OPTS="-server -Xms3072m  -Xmx3072m  -verbose:gc  -XX:+PrintGCDetails  -XX:PermSize=128M -XX:MaxPermSize=256m"
APP_JAVA_CP="-cp ../config"

#判断参数个数
if [ $# -ne 1 ]; then
	usage
	exit 1
fi

#获取进程的PID
watcher_procid=`ps -fe | grep $watchermodule".jar" | grep -v grep | awk '{print $2}'`
app_procid=`ps -fe | grep $appmodule".jar" | grep -v grep | awk '{print $2}'`

#判断watcher module状态
status_watcher () {
	if [ -z "$watcher_procid" ]; then
		action  "java ${watchermodule}.jar  process not exists;" /bin/false
		return 1
	else
		action  "java ${watchermodule}.jar pid is ${watcher_procid}" /bin/true
		return 0
	fi	
}

#判断app module状态
status_app () {
	if [ -z "$app_procid" ]; then
		action  "java ${appmodule}.jar  process not exists;" /bin/false
		return 1
	else
		action  "java ${appmodule}.jar pid is ${app_procid}" /bin/true
		return 0
	fi	
}

#start watcher
start_watcher () {
	echo "start $watchermodule  ........"
	echo "1" > reset.flag
	nohup java $WATCHER_JAVA_OPTS $JAVA_CP -jar ../$watchermodule".jar" >>watcher.log 2>&1 &
	if [ $? -eq 0 ]; then
		action "Start watchermodule Success" /bin/true
	else
		action "Start watchermodule Failure"  /bin/false
	fi
}

#start app
start_app () {
	echo "run $appmodule  ........"
	nohup java $APP_JAVA_OPTS $APP_JAVA_CP -Ddubbo.spring.config=$APP_SPRING_CONTEXT -Ddubbo.container=spring -Duser.home=$DEPLOY_DIR -Dfile.encoding=UTF-8 -jar ../$appmodule".jar" >>/dev/null 2>&1 & 
	if [ $? -eq 0 ]; then
		action "Start appmodule Success" /bin/true
	else
		action "Start appmodule Failure"  /bin/false
	fi
}

#stop watcher 
stop_watcher () {
	echo -n "stop  $watchermodule  ........"
	kill -9 $watcher_procid
	if [ $? -eq 0 ]; then
		action "Stop watchermodule Success" /bin/true
	else
		action "Stop watchermodule Failure"  /bin/false
	fi
}

#stop app 
stop_app () {
	echo -n "stop  $appmodule  ........"
	kill -9 $app_procid
	if [ $? -eq 0 ]; then
		action "Stop appmodule Success" /bin/true
	else
		action "Stop appmodule Failure"  /bin/false
	fi
}

case "$1" in
    "start" )
        status_watcher || start_watcher
		status_app || start_app
        ;;
	"run" )
        status_app || start_app
        ;;
    "stop" )
        status_app && stop_app
        ;;
    "end" )
		status_watcher && stop_watcher
		status_app && stop_app
        ;;
    "check" )
		status_watcher
		status_app
        ;;
    "restart" )
        echo "restart	app&watcher  ........"
		status_watcher && stop_watcher
		status_app && stop_app
		
		echo "waiting 3 seconds"
		sleep 3s 
		
        status_watcher || start_watcher
		status_app || start_app		
        ;;
    * )
        echo $"Usage: $0 {start|stop|run|restart|end}"
        exit 2
esac