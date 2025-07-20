FROM oven/bun:alpine as base

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

FROM base as build

COPY . .

# compile cli.ts to native executable
RUN bun run build

FROM base as production

COPY --from=build /app/cli ./

# Does nothing, the container is used to run scripts
CMD ["tail", "-f", "/dev/null"]
