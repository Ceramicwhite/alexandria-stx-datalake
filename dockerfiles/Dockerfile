FROM hasura/graphql-engine:latest AS builder

WORKDIR /build
COPY . .

RUN apt update && apt install git

FROM hasura/graphql-engine:latest

USER 1000
WORKDIR /build
COPY --from=builder /build .

CMD [ "yarn", "start:prod" ]