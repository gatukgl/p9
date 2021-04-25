FROM elixir:1.12-alpine AS builder
WORKDIR /app
RUN apk add --no-cache build-base git
RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV prod

ADD mix.exs .
ADD mix.lock .
RUN mix deps.get

ADD . .
RUN mix release

FROM elixir:1.12-alpine
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/_build/prod/rel/p9/ /app/
CMD ["./bin/p9", "start"]

