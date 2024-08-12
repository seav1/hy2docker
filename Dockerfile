FROM alpine

WORKDIR .

COPY start.sh ./

RUN apk update &&\
    apk add --no-cache -y openssl curl bash &&\
    chmod 755 start.sh
    
CMD ["./start.sh"]
