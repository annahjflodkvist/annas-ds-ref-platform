FROM oven/bun:1.0.21-alpine
RUN apk add --update python3 make g++ git 
WORKDIR /app
COPY package.json bun.lockb ./
COPY packages packages
RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+
RUN bun install --frozen-lockfile
COPY . .
CMD ["bun", "packages/backend", "--config", "app-config.yaml"]