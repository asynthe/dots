#!/usr/bin/env bash

# Directs audio input (e.g. mic) to audio output (e.g. speakers),
# then sleeps forever. Stops audio redirection when it is killed.
# So, for example, plug your phone into the PC's mic, run 'listen',
# and listen to phone audio through your computer's speakers.

# Requires PipeWire

set -e

# Load a loopback module in PipeWire
pw-loopback --capture-props="node.latency=10/1000" &
LOOPBACK_PID=$!

function cleanup {
  kill $LOOPBACK_PID
}

trap cleanup EXIT
sleep infinity
