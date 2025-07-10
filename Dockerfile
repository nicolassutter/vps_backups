FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache \
    python3 \
    py3-pip \
    pipx \
    bash \
    curl

# --break-system-packages needs to be used to install minio
RUN pip3 install --break-system-packages minio

# Does nothing, the container is used to run scripts
CMD ["tail", "-f", "/dev/null"]
