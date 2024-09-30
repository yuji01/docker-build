#!/bin/bash


ipv4Regex="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";

if [ "$IP_TO_CF" = "1" ]; then
  # 验证cf账号信息是否正确
  res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
  resSuccess=$(echo "$res" | jq -r ".success");
  if [[ $resSuccess != "true" ]]; then
    echo "登陆错误，检查cloudflare账号信息填写是否正确!"
    echo "登陆错误，检查cloudflare账号信息填写是否正确!" > $informlog
    source $cf_push;
    exit 1;
  fi
  echo "Cloudflare账号验证成功";
else
  echo "未配置Cloudflare账号"
fi

# 获取域名填写数量
num=${#hostname[*]};

# 判断优选ip数量是否大于域名数，小于则让优选数与域名数相同
if [ "$CFST_DN" -le $num ] ; then
  CFST_DN=$num;
fi
CFST_P=$CFST_DN;

# 判断工作模式
if [ "$IP_ADDR" = "ipv6" ] ; then
  if [ ! -f "/app/ipv6.txt" ]; then
    echo "当前工作模式为ipv6，但该目录下没有【ipv6.txt】，请配置【ipv6.txt】。下载地址：https://github.com/XIU2/CloudflareSpeedTest/releases";
    exit 2;
  else
    echo "当前工作模式为ipv6";
  fi
else
  echo "当前工作模式为ipv4";
fi

#判断是否配置测速地址 
if [[ "$CFST_URL" == http* ]] ; then
  CFST_URL_R="-url $CFST_URL -tp $CFST_TP ";
else
  CFST_URL_R="";
fi

# 检查 cfcolo 变量是否为空
if [[ -n "$cfcolo" ]]; then
  cfcolo="-cfcolo $cfcolo"
fi

# 检查 httping_code 变量是否为空
if [[ -n "$httping_code" ]]; then
  httping_code="-httping-code $httping_code"
fi

# 检查 CFST_STM 变量是否为空
if [[ -n "$CFST_STM" ]]; then
  CFST_STM="-httping $httping_code $cfcolo"
fi

# 是否使用反代ip
if [ "$IP_PR_IP" = "true" ] ; then
  source $WORKDIR/get_pr_ip.sh;
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL  -sl $CFST_SL -p $CFST_P -tlr $CFST_TLR $CFST_STM -f $WORKDIR/pr_ip.txt -o $WORKDIR/result.csv
  rm $WORKDIR/pr_ip.txt

elif [ "$IP_ADDR" = "ipv6" ] ; then
  #开始优选IPv6
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -tlr $CFST_TLR $CFST_STM -f $WORKDIR/ipv6.txt -o $WORKDIR/result.csv

else
  #开始优选IPv4
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -tlr $CFST_TLR $CFST_STM -f $WORKDIR/ip.txt -o $WORKDIR/result.csv
fi
echo "测速完毕";

# 开始循环
echo "正在更新域名，请稍后..."
x=0

while [[ ${x} -lt $num ]]; do
  CDNhostname=${hostname[$x]}
  
  # 获取优选后的ip地址
  ipAddr=$(sed -n "$((x + 2)),1p" $WORKDIR/result.csv | awk -F, '{print $1}');
  ipSpeed=$(sed -n "$((x + 2)),1p" $WORKDIR/result.csv | awk -F, '{print $6}');
  if [ $ipSpeed = "0.00" ]; then
    echo "第$((x + 1))个---$ipAddr测速为0，跳过更新DNS，检查配置是否能正常测速！";
  else

    if [ "$IP_TO_CF" = 1 ]; then
      echo "开始更新第$((x + 1))个---$ipAddr"

      # 开始DDNS
      if [[ $ipAddr =~ $ipv4Regex ]]; then
        recordType="A"
      else
        recordType="AAAA"
      fi

      listDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${recordType}&name=${CDNhostname}"
      createDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records"

      # 关闭小云朵
      proxy="false"
  
      res=$(curl -s -X GET "$listDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json")
      recordId=$(echo "$res" | jq -r ".result[0].id")
      recordIp=$(echo "$res" | jq -r ".result[0].content")
  
      if [[ $recordIp = "$ipAddr" ]]; then
        echo "更新失败，获取最快的IP与云端相同"
        resSuccess=false
      elif [[ $recordId = "null" ]]; then
        res=$(curl -s -X POST "$createDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$recordType\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}")
        resSuccess=$(echo "$res" | jq -r ".success")
      else
        updateDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${recordId}"
        res=$(curl -s -X PUT "$updateDnsApi"  -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$recordType\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}")
        resSuccess=$(echo "$res" | jq -r ".success")
      fi
  
      if [[ $resSuccess = "true" ]]; then
        echo "$CDNhostname更新成功"
      else
        echo "$CDNhostname更新失败"
      fi
    fi
  fi
  x=$((x + 1))
  sleep 3s
done > $informlog
