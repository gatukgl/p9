FROM alpine:edge AS builder
WORKDIR /app
RUN apk add --no-cache build-base git elixir
RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV prod

ADD mix.exs .
ADD mix.lock .
RUN mix do deps.get, deps.compile

ADD . .
RUN mix release

FROM alpine:edge
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata elixir

COPY --from=builder /app/_build/prod/rel/p9/ /app/
CMD ["./bin/p9", "start"]

