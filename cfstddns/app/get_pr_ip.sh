#! /bin/bash
# 获取反代ip到 $WORKDIR/pr_ip.txt
proxychains4 -q wget $PR_IP_ADDR -O $WORKDIR/pr_ip.txt && echo "成功获取反代ip"
