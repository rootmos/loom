FROM python:3.8.0-alpine3.10

RUN apk add --update make gcc musl-dev

WORKDIR /tests
ADD Makefile requirements.txt *.py ./
RUN make deps
ENTRYPOINT ["make"]
