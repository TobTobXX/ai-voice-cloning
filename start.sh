#!/bin/bash
while [ true ]; do
    python3 ./src/main.py --listen-host "$HOST" --listen-port "$PORT"
    echo "Press Ctrl-C to quit or application will restart... (5s)"
    sleep 5
done
