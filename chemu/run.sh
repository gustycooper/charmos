#!/bin/bash
source venv/bin/activate

sleep 1 && printf "Navigate to http://127.0.0.1:5000 to use the emulator!\nHit CTRL+C to stop the emulator server\n" & flask --app chemuw run > /dev/null 2>&1