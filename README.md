# P9

### Development

First, you need a discord server token.

```sh
$ export DISCORD_TOKEN=123456
```

Then, run with `mix run`

```sh
$ mix run --no-halt
```

The `--no-halt` part is required to keep all supervisors running even when the app has
finished initializing.
