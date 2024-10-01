#! /bin/bash
# 获取反代ip到 $WORKDIR/pr_ip.txt
# 项目：https://t.me/cf_push
# 下载地址：https://zip.baipiao.eu.org
port=$PRIP_PORT

# 初始化文件夹
if [ -d $WORKDIR/tmp ]; then
  rm -rf $WORKDIR/tmp/
fi

mkdir $WORKDIR/tmp

# 获取文件到 $WORKDIR/tmp/ip.zip
proxychains4 -q wget https://zip.baipiao.eu.org -O $WORKDIR/tmp/ip.zip

# 解压文件
unzip $WORKDIR/tmp/ip.zip -d $WORKDIR/tmp/allip
rm -rf $WORKDIR/tmp/ip.zip

# 合并文件
cat $WORKDIR/tmp/allip/*-$port.txt >  $WORKDIR/pr_ip.txt

if [ -f $WORKDIR/pr_ip.txt ]; then
  echo "成功获取 $port 端口反代ip"
else
  echo "获取 $port 端口反代ip失败"
  echo "获取 $port 端口反代ip失败" > $informlog
  source $cf_push;
  exit 1;
fi
#proxychains4 -q wget $PR_IP_ADDR -O $WORKDIR/pr_ip.txt && echo "成功获取反代ip"
