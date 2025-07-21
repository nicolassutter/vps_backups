FROM alpine:latest AS base

WORKDIR /app

RUN apk add --no-cache \
    bash \
    curl

FROM oven/bun:alpine AS build

WORKDIR /app

COPY package.json bun.lock ./

RUN bun install --frozen-lockfile

COPY . .

# compile cli.ts to native executable
RUN bun run build

FROM base as production

WORKDIR /app

COPY --from=build /app/cli /app/

# Does nothing, the container is used to run scripts
CMD ["tail", "-f", "/dev/null"]
