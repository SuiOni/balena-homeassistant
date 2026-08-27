FROM alpine:3.22

RUN apk add --no-cache alsa-lib ffmpeg

ENV AUDIO_DEVICE=default \
    AUDIO_PORT=8088 \
    AUDIO_BITRATE=48k

EXPOSE 8088

CMD ["sh", "-c", "exec ffmpeg -hide_banner -loglevel warning -f alsa -i \"$AUDIO_DEVICE\" -ac 1 -ar 48000 -c:a libopus -b:a \"$AUDIO_BITRATE\" -f ogg -content_type audio/ogg -listen 1 \"http://0.0.0.0:${AUDIO_PORT}/usb-mic.ogg\""]