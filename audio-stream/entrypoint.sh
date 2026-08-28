#!/bin/sh

set -u

while :; do
  audio_device="${AUDIO_DEVICE:-auto}"

  if [ "$audio_device" = "auto" ]; then
    audio_device="$(arecord -l 2>/dev/null | sed -n 's/^card \([0-9][0-9]*\):.*device \([0-9][0-9]*\):.*/plughw:\1,\2/p' | head -n 1)"
  fi

  if [ -z "$audio_device" ]; then
    echo "No ALSA capture device found; checking again in 5 seconds."
    sleep 5
    continue
  fi

  echo "Streaming ALSA capture device: $audio_device"
  ffmpeg -hide_banner -loglevel warning -f alsa -i "$audio_device" \
    -ac 1 -ar 48000 -c:a libopus -b:a "$AUDIO_BITRATE" \
    -f ogg -content_type audio/ogg -listen 1 \
    "http://0.0.0.0:${AUDIO_PORT}/usb-mic.ogg"

  echo "Audio stream stopped; retrying in 5 seconds."
  sleep 5
done