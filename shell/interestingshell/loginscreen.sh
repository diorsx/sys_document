#!/bin/bash

# $1 color       0-7 设置字体颜色
# $2 bgcolor     0-7 设置字体背景颜色
# $3 bold        0-1 设置粗体
# $4 underline   0-1 设置下划线
function format_output(){
    color=$1               #字体颜色
    bgcolor=$2             #字体背景色
    bold=$3                #是否加粗
    underline=$4           #是否加下划线
    #normal=$(tput sgr0)   #重置
    c2=""

    case "$color" in
        0|1|2|3|4|5|6|7)
            setcolor=$(tput setaf $color;)
            ;;
        *)
            setcolor=""
            ;;
    esac

    case "$bgcolor" in
        0|1|2|3|4|5|6|7)
            setbgcolor=$(tput setab $bgcolor;) ;;
        *)
            setbgcolor="" ;;
    esac

    if [ "$bold" = "1" ]; then
        setbold=$(tput bold;)
    else
        setbold=""
    fi

    if [ "$underline" = "1" ]; then
        setunderline=$(tput smul;)
    else
        setunderline=""
    fi
    c2="$setcolor$setbgcolor$setbold$setunderline"
}

format_output 2 0 0 0
echo "$c2        "
echo "                   _ooOoo_"
echo "                  o8888888o"
echo "                  88\" . \"88"
echo "                  (| -_- |)"
echo "                  O\\  =  /O"
echo "               ____/\`---'\\__\"__"
echo "             .'  \\|     |//  \`."
echo "            /  \\\\|||  :  |||//  \\"
echo "           /  _||||| -:- |||||-  \\"
echo "           |   | \\\\\\  -  /// |   |"
echo "           | \\_|  ''\\---/''  |   |"
echo "           \  .-\\__  \`-\`  ___/-. /"
echo "         ___\`. .'  /--.--\  \`. . __"
echo "      .\"\" '<  \`.___\\_<|>_/___.'  >'\"\"."
echo "     | | :  \`- \\\`.;\`\\ _ /\`;.\`/ - \` : | |"
echo "     \\  \\ \`-.   \\_ __\\ /__ _/   .-\` /  /"
echo "======\`-.____\`-.___\\_____/___.-\`____.-'======"
echo "                   \`=---='"
echo " "
echo " "
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "           佛祖保佑       永不宕机"
echo "           心外无法       法外无心"
echo "$(tput sgr0)"

# *******************************************************************************
# 上述脚本放入系统某一位置，并设置到家目录下.bashrc, 内容如下：
#  if [ -f  ~/scripts/welcome.sh ] && [ ${-#*i} != $- ]; then
#     .  ~/scripts/welcome.sh
#  fi
#
# *******************************************************************************
