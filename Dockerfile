FROM node:16-alpine AS builder

WORKDIR /build
COPY . .

RUN yarn && yarn build

FROM node:16-alpine

USER 1000
WORKDIR /build
COPY --from=builder /build .


CMD [ "yarn", "start:prod" ]