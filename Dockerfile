FROM oven/bun:alpine

WORKDIR /app

RUN apk add --no-cache \
    python3 \
    py3-pip \
    pipx \
    bash \
    curl

# --break-system-packages needs to be used to install minio
RUN pip3 install --break-system-packages minio

COPY package.json bun.lock ./

RUN bun install --frozen-lockfile

# Does nothing, the container is used to run scripts
CMD ["tail", "-f", "/dev/null"]
