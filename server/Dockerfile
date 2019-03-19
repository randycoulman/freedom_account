FROM elixir:1.8.1
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

RUN apt-get update \
  && apt-get install --yes postgresql-client \
  && mix local.hex --force \
  && mix archive.install --force hex phx_new 1.4.2 \
  && mix local.rebar --force

WORKDIR /app

EXPOSE 4000

CMD ["./scripts/run.sh"]
