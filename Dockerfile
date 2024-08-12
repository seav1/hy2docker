FROM alpine

WORKDIR .

COPY start.sh ./

RUN apk update &&\
    apk add --no-cache curl bash &&\
    chmod 755 start.sh
    
CMD ["./start.sh"]
