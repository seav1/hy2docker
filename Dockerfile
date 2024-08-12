FROM ubuntu

WORKDIR /app

COPY start.sh /app/

RUN apt-get update && \
    apt install -y curl unzip jq openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x start.sh
    
CMD ["./start.sh"]
