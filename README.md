# herdr-continue

Automatically continue your agent sessions after a reboot.

When herdr's server restarts, it restores your agent sessions, but they come back idle, waiting for input. This plugin tells every idle agent to continue its work.

## Requirements

- `jq` in `PATH`

## Install

```sh
herdr plugin install codergeek121/herdr-continue
```
