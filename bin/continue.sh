#!/bin/sh
# Runs once on the herdr startup hook, after the server has restored the
# previous session and the API socket is ready. Every agent herdr reports
# at that moment is one that just got restarted, so we nudge each of them
# with "continue".
set -eu

HERDR="${HERDR_BIN_PATH:-herdr}"

if ! command -v jq >/dev/null 2>&1; then
    echo "herdr-continue: jq is required but was not found in PATH" >&2
    exit 1
fi

"$HERDR" agent list | jq -r '
    .result.agents[]
    | select(.agent_status == "idle" or .agent_status == "done")
    | .pane_id
' | while IFS= read -r target; do
    [ -n "$target" ] || continue
    "$HERDR" agent prompt "$target" "continue"
done
