FROM alpine

RUN apk add --no-cache bash git

COPY git-sync.sh .

CMD [ "./git-sync.sh" ]
