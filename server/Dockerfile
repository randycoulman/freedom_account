FROM elixir:1.8.1
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

WORKDIR /app

RUN \
  apt-get update && \
  apt-get install --yes inotify-tools && \
  mix local.hex --force && \
  mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config ./

ARG MIX_ENV=${MIX_ENV:-dev}

RUN mix do deps.get, deps.compile

COPY . .

RUN mix compile

EXPOSE 4000

CMD ["iex -S mix"]
