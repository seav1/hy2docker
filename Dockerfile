FROM ubuntu

WORKDIR /app

COPY start.sh /app/

RUN apt-get update &&\
    chmod +x start.sh
    
CMD ["./start.sh"]
