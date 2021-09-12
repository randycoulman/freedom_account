FROM node:10.15.3-alpine AS client_build
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

WORKDIR /app

COPY client/package.json client/package-lock.json ./

RUN npm install

COPY client .

ENV \
  NODE_ENV=production \
  SKIP_PREFLIGHT_CHECK=true

RUN npm run build

FROM elixir:1.8.1-alpine AS server_build
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

WORKDIR /app

RUN \
  mix local.hex --force && \
  mix local.rebar --force

ENV MIX_ENV=prod

COPY server/mix.exs server/mix.lock ./
COPY server/config ./config

RUN mix do deps.get --only prod, deps.compile

COPY server .

COPY --from=client_build /app/build ./priv/static

RUN mix do compile, release --no-tar

FROM erlang:21-alpine
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

RUN apk add --update bash openssl

ENV MIX_ENV=prod

WORKDIR /app

COPY --from=server_build /app/_build/prod/rel/freedom_account ./

ENV REPLACE_OS_VARS=true

ENTRYPOINT ["/app/bin/freedom_account"]
