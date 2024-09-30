#! /bin/bash

WORKDIR=/app
CloudflareST="$WORKDIR/CloudflareST"
informlog="$WORKDIR/informlog"
cf_push="$WORKDIR/cf_push.sh"

# 初始化推送
if [ -e ${informlog} ]; then
  rm ${informlog}
fi

# 检测是否配置DDNS或更新HOSTS任意一个
if [[ -z ${dnspod_token} ]]; then
  IP_TO_DNSPOD=0
else
  IP_TO_DNSPOD=1
fi

if [[ -z ${api_key} ]]; then
  IP_TO_CF=0
else
  IP_TO_CF=1
fi

if [ "$IP_TO_HOSTS" = "true" ]; then
  IP_TO_HOSTS=1
else
  IP_TO_HOSTS=0
fi

# 复制配置文件ip到/app
cp $WORKDIR/config/ip.txt $WORKDIR/ip.txt
cp $WORKDIR/config/ipv6.txt $WORKDIR/ipv6.txt


if [ $IP_TO_DNSPOD -eq 1 ] || [ $IP_TO_CF -eq 1 ] || [ $IP_TO_HOSTS -eq 1 ]
then
  echo "配置获取成功！"
else
  echo "HOSTS和cf_ddns均未配置！！！"
  echo "HOSTS和cf_ddns均未配置！！！" > $informlog
  source $cf_push;
  exit 1;
fi
