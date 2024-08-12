FROM ubuntu

WORKDIR /app

COPY start.sh /app/

apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt install -y curl unzip jq openssl qrencode unzip tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x start.sh
    
CMD ["./start.sh"]
