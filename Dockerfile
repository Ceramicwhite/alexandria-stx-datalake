FROM node:16-alpine

WORKDIR /dist
COPY . .

RUN apk add --no-cache --virtual .build-deps alpine-sdk python3 git openjdk8-jre
RUN yarn && yarn build
RUN apk del .build-deps


CMD [ "yarn", "start:prod" ]