#! /bin/sh

# 生成自签10年证书
openssl req -x509 -newkey rsa:4096 -sha256 -days 36500 -nodes -keyout /app/certs/derp.baidu.com.key -out /app/certs/derp.baidu.com.crt -subj "/CN=derp.baidu.com" -addext "subjectAltName=DNS:derp.baidu.com"

echo "证书已生成"

# 启动
/app/derper -a :$DERP_PORT -certdir /app/certs -certmode manual -derp -hostname derp.baidu.com -http-port -1 -stun $DERP_STUN -stun-port $DERP_STUN_PORT -verify-clients $DERP_VERIFY_CLIENTS
