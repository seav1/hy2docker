FROM debian

WORKDIR tmp

COPY start.sh ./

RUN apt-get update &&\
    apt-get install -y wget unzip iproute2 &&\
    chmod 755 start.sh

CMD ["./start.sh"]
