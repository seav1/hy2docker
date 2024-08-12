FROM alpine

WORKDIR /app

COPY start.sh /app/

RUN apk update &&\
    apk add --no-cache openssl curl bash &&\
    chmod +x start.sh
    
CMD ["./start.sh"]
