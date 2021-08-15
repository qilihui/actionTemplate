#!/bin/bash --login
projectName=$1
url=$2
dir="$1Depoly"
time=$3
port=$4
ping="curl localhost:$port/ping"
pull="timeout $3 git clone $url"
echo "部署文件夹: $dir"
echo "项目名: $projectName"
echo "URL: $url"
echo "超时时间: $time"
echo "开始执行"
# env
if [ ! -d ./$dir ]; then
    mkdir -p ~/$dir
fi
cd ~/$dir
if [ -d ./$projectName ]; then
    rm -rf $projectName
fi
for i in {1..5}; do
    $pull
    if [ $? -eq 0 ]; then
        echo "拉取代码成功"
        break
    else
        echo "拉取代码失败，重试 $i"
    fi
done

if [ $? -ne 0 ]; then
    echo "拉取失败exit -1"
    exit -1
fi
cd $projectName
echo "执行run.sh"
chmod u+x run.sh
./run.sh

echo "开始执行心跳检测"
$ping
for i in {1..20}; do
    if [ $? -eq 0 ]; then
        echo "心跳检测成功"
        break
    else
        echo "ping fail $i"
        sleep 15
    fi
    $ping
done
if [ $? -ne 0 ]; then
    echo "运行失败，请检查"
fi
echo "depoly and run is success"
exit 0
