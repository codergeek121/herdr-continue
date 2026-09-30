#!/bin/sh
# Runs once on the herdr startup hook, after the server has restored the
# previous session and the API socket is ready. Every agent herdr reports
# at that moment is one that just got restarted, so we nudge each of them
# with "continue".
set -u

HERDR="${HERDR_BIN_PATH:-herdr}"

if ! command -v jq >/dev/null 2>&1; then
    echo "herdr-continue: jq is required but was not found in PATH" >&2
    exit 1
fi

# Right after boot, an agent can be listed as idle before herdr has finished
# binding it for prompt routing, so a fresh target can briefly 404. Retry
# each target a few times instead of giving up on the whole batch.
"$HERDR" agent list | jq -r '
    .result.agents[]
    | select(.agent_status == "idle" or .agent_status == "done")
    | .pane_id
' | while IFS= read -r target; do
    [ -n "$target" ] || continue
    attempt=1
    while ! "$HERDR" agent prompt "$target" "continue" >/dev/null 2>&1; do
        attempt=$((attempt + 1))
        if [ "$attempt" -gt 5 ]; then
            echo "herdr-continue: giving up on $target" >&2
            break
        fi
        sleep 1
    done
done
