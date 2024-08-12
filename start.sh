#!/bin/bash
export PASSWORD=${PASSWORD:-'feefeb96-bfcf-4a9b-aac0-6aac771c1b98'}  # 随机生成password，无需更改
export SERVER_PORT="${SERVER_PORT:-${PORT:-2212}}"      # hy2 端口，改为开放的udp端口
export NEZHA_SERVER=${NEZHA_SERVER:-'nz.seav.eu.org'}       # 哪吒客户端域名
export NEZHA_PORT=${NEZHA_PORT:-'443'}             # 哪吒客户端端口为{443,8443,2096,2087,2083,2053}其中之一时开启tls
export NEZHA_KEY=${NEZHA_KEY:-'6eLJr8urdaN5vexkoF'}                 # 哪吒客户端密钥

# Download Dependency Files
DOWNLOAD_DIR="." && mkdir -p "$DOWNLOAD_DIR"
FILE_INFO=("https://download.hysteria.network/app/latest/hysteria-linux-amd64 web" "https://github.com/seav1/dl/releases/download/upx/nz npm")

for entry in "${FILE_INFO[@]}"; do
    URL=$(echo "$entry" | cut -d ' ' -f 1)
    NEW_FILENAME=$(echo "$entry" | cut -d ' ' -f 2)
    FILENAME="$DOWNLOAD_DIR/$NEW_FILENAME"
    if [ -e "$FILENAME" ]; then
        echo -e "\e[1;32m$FILENAME already exists, Skipping download\e[0m"
    else
        curl -L -sS -o "$FILENAME" "$URL"
        echo -e "\e[1;32mDownloading $FILENAME\e[0m"
    fi
    chmod +x $FILENAME
done
wait

# Generate cert
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout server.key -out server.crt -subj "/CN=bing.com" -days 36500

# Generate configuration file
cat << EOF > config.yaml
listen: :$SERVER_PORT

tls:
  cert: server.crt
  key: server.key

auth:
  type: password
  password: "$PASSWORD"

fastOpen: true

masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true

transport:
  udp:
    hopInterval: 30s
EOF

# running files
run() {
  if [ -e npm ]; then
    tlsPorts=("443" "8443" "2096" "2087" "2083" "2053")
    if [[ "${tlsPorts[*]}" =~ "${NEZHA_PORT}" ]]; then
      NEZHA_TLS="--tls"
    else
      NEZHA_TLS=""
    fi
    if [ -n "$NEZHA_SERVER" ] && [ -n "$NEZHA_PORT" ] && [ -n "$NEZHA_KEY" ]; then
      nohup ./npm -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} >/dev/null 2>&1 &
      sleep 1
      echo -e "\e[1;32mnpm is running\e[0m"
    else
        echo -e "\e[1;35mNEZHA variable is empty, skipping running\e[0m"
    fi
  fi

  if [ -e web ]; then
    nohup ./web server config.yaml >/dev/null 2>&1 &
    sleep 1
    echo -e "\e[1;32mweb is running\e[0m"
  fi
}
run

# get ip
ipv4=$(curl -s ipv4.ip.sb)
if [ -n "$ipv4" ]; then
    HOST_IP="$ipv4"
else
    ipv6=$(curl -s --max-time 1 ipv6.ip.sb)
    if [ -n "$ipv6" ]; then
        HOST_IP="$ipv6"
    else
        echo -e "\e[1;35m无法获取IPv4或IPv6地址\033[0m"
        exit 1
    fi
fi
echo -e "\e[1;32m本机IP: $HOST_IP\033[0m"

# get ipinfo
ISP=$(curl -s https://speed.cloudflare.com/meta | awk -F\" '{print $26"-"$18}' | sed -e 's/ /_/g')

# get hy2 node
echo -e "\e[1;32mHysteria2安装成功\033[0m"
echo ""
echo -e "\e[1;33mV2rayN或Nekobox\033[0m"
echo -e "\e[1;32mhysteria2://$PASSWORD@$HOST_IP:$SERVER_PORT/?sni=www.bing.com&alpn=h3&insecure=1#$ISP\033[0m"
echo ""
echo -e "\e[1;33mSurge\033[0m"
echo -e "\e[1;32m$ISP = hysteria2, $HOST_IP, $SERVER_PORT, password = $PASSWORD, skip-cert-verify=true, sni=www.bing.com\033[0m"
echo ""
echo -e "\e[1;33mClash\033[0m"
cat << EOF
- name: $ISP
  type: hysteria2
  server: $HOST_IP
  port: $SERVER_PORT
  password: $PASSWORD
  alpn:
    - h3
  sni: www.bing.com
  skip-cert-verify: true
  fast-open: true
EOF

# delete files
rm -rf npm web config.yaml

tail -f /dev/null
