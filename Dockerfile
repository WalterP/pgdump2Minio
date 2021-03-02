FROM postgres:13-alpine
LABEL mainteiner="vpontus"


RUN apk add --no-cache python3 curl

RUN curl "https://dl.min.io/client/mc/release/linux-amd64/mc" -o "mc" \
    && mv mc /usr/local/bin/mc && chmod +x /usr/local/bin/mc

WORKDIR /app
ADD backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

CMD ["/app/backup.sh"]
