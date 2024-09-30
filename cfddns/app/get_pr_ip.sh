#! /bin/bash
# 获取反代ip
wget $PR_IP_ADDR -O $WORKDIR/pr_ip.txt && echo "成功获取反代ip"