FROM node:16-alpine

WORKDIR /dist
COPY . .

RUN apk add --no-cache --virtual .build-deps alpine-sdk python3 git openjdk8-jre
RUN yarn && yarn build
RUN apk del .build-deps

#ENV DATABASE_URL postgres://DB_USER:DB_PASSWORD@DB_HOST:DB_PORT/DB_DATABASE
#ENV STACKS_NODE_API_URL https://stacks-node-api.mainnet.stacks.co/
#ENV STREAM_HISTORICAL_DATA true
#ENV NODE_ENV production

EXPOSE 3000

CMD [ "yarn", "start:prod" ]