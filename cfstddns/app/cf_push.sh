#! /bin/bash
# 用于CloudflareSpeedTestDDNS执行情况推送。

# 推送消息内容
message_text=$(echo "$(sed "$ ! s/$/\\\n/ " /app/informlog | tr -d '\n')")

push_feishu(){
  # 飞书推送机器人
  FeiShuURL="https://open.feishu.cn/open-apis/bot/v2/hook/${feishuToken}"
  if [[ -z ${feishuToken} ]]; then
    echo "未配置飞书推送"
  else
    res=$(curl -X POST -H "Content-type: application/json" -d '{"msg_type":"'"text"'","content":{"text":"'"$message_text"'"}}' $FeiShuURL)

    [ $? == 124 ] && echo "feishu_api请求超时,请检查网络"
  fi
}

push_feishu;

cat $informlog

exit 0;