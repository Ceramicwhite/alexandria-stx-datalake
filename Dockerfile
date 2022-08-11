FROM node:16-alpine AS builder

WORKDIR /build
COPY . .

RUN apk add --no-cache --virtual .build-deps alpine-sdk python3 git openjdk8-jre
RUN yarn && yarn build
RUN apk del .build-deps

FROM node:16-alpine

USER 1000
WORKDIR /build
COPY --from=builder /build .


CMD [ "yarn", "start:prod" ]