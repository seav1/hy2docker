FROM debian:bookworm-slim

WORKDIR /app

COPY start.sh ./

RUN apt-get update && apt-get install -y wget curl unzip systemctl &&\
    chmod +x start.sh

CMD ["./start.sh"]

EXPOSE 3000
