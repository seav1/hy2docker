FROM apline

WORKDIR /tmp

COPY start.sh ./

RUN apk update &&\
    apk add --no-cache bash &&\
    chmod 755 start.sh

CMD ["./start.sh"]
