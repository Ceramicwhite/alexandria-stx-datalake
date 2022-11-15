FROM    --platform=${TARGETPLATFORM} node:14.20.1-alpine AS deps

WORKDIR /app

COPY    package.json ./

RUN     yarn

#####################################################################
FROM    --platform=${TARGETPLATFORM} node:14.20.1-alpine AS builder

WORKDIR /app

COPY    . .

COPY    --from=deps /app/node_modules ./node_modules

COPY   .env.example ./.env

RUN    yarn build

#####################################################################
FROM    --platform=${TARGETPLATFORM} node:14.20.1-alpine AS runner

ENV     NODE_ENV=production

WORKDIR /app

COPY    --from=builder --chown=1000:1000 /app/dist ./
COPY    --from=deps --chown=1000:1000 /app/node_modules ./node_modules

COPY    README.md LICENSE .env.example package.json Dockerfile ./

ENV     DB_USER=postgres \
        DB_PASSWORD=postgres \
        DB_HOST=postgres \
        DB_PORT=5432 \
        DB_NAME=postgres \
        DATABASE_URL=postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE \
        STACKS_NODE_API_URL=https://stacks-node-api.mainnet.stacks.co \
        STACKS_WSS_URL=wss://stacks-node-api.mainnet.stacks.co \
        PORT=3000

EXPOSE  $PORT

USER    1000

CMD ["node", "main.js"]

