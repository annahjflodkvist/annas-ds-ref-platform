FROM node:20-slim
RUN apt-get update 
RUN apt-get install -y python3 make g++ git
WORKDIR /app
COPY .yarn ./.yarn 
COPY package.json yarn.lock .yarnrc.yml ./
COPY packages packages
RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+
RUN yarn workspaces focus --all
COPY . .
# RUN yarn tsc
# RUN yarn --cwd packages/backend build

ENTRYPOINT [ "nodemon", "--exec", "yarn dev" ]