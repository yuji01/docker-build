#!/bin/bash
# 第一次运行时执行，设置crontab之类的

source /app/config/config.conf;
source /app/check.sh;
source /app/crontab.sh;
case $DNS_PROVIDER in
    1)
        source /app/cf_ddns_cloudflare.sh
        ;;
    2)
        source /app/cf_ddns_dnspod.sh
        ;;
    *)
        echo "未选择任何DNS服务商"
        ;;
esac
source /app/cf_push.sh;
#tail -f /dev/null;
exit 0;