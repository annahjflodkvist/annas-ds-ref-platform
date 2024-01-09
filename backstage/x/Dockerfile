FROM node:20-alpine3.18 AS base
USER node
WORKDIR /app
COPY --chown=node:node .yarn ./.yarn 
COPY --chown=node:node .yarnrc.yml ./
# FROM base AS prepped
# # Set Python interpreter for `node-gyp` to use
# ENV PYTHON /usr/bin/python3

# # Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
#     --mount=type=cache,target=/var/lib/apt,sharing=locked \
#     apt-get update && \
#     apt-get install -y --no-install-recommends python3 g++ build-essential && \
#     yarn config set python /usr/bin/python3


###
# Stage 1 - Create yarn install skeleton layer
###
FROM base AS packages
USER node
WORKDIR /app
COPY --chown=node:node package.json yarn.lock ./
COPY --chown=node:node packages packages

# Comment this out if you don't have any internal plugins
# COPY plugins plugins

RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+

###
# Stage 2 - Install dependencies and build packages
###
FROM base AS build
USER node
WORKDIR /app
COPY --from=packages --chown=node:node /app .

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all 

# Build TypeScript files

RUN yarn --cwd packages/backend tsc
RUN rm -rf "$(yarn cache clean)"
COPY --chown=node:node . .

RUN yarn tsc
RUN yarn --cwd packages/backend build


RUN mkdir packages/backend/dist/skeleton packages/backend/dist/bundle \
    && tar xzf packages/backend/dist/skeleton.tar.gz -C packages/backend/dist/skeleton \
    && tar xzf packages/backend/dist/bundle.tar.gz -C packages/backend/dist/bundle

###
# Stage 3 - Build the actual backend image and install production dependencies
###
FROM base AS production
USER node
WORKDIR /app
# Copy the install dependencies from the build stage and context
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton/ ./

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --frozen-lockfile --production && rm -rf "$(yarn cache clean)"

# Copy the built packages from the build stage
COPY --from=build --chown=node:node /app/packages/backend/dist/bundle/ ./

# Copy any other files that we need at runtime
COPY --chown=node:node app-config.yaml ./

# This switches many Node.js dependencies to production mode.
ARG node_env=production
ENV NODE_ENV $node_env

CMD ["node", "packages/backend", "--config", "app-config.yaml"]