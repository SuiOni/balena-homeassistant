FROM alpine:3.22

RUN apk add --no-cache alsa-lib alsa-utils ffmpeg

ENV AUDIO_DEVICE=auto \
    AUDIO_PORT=8088 \
    AUDIO_BITRATE=48k

EXPOSE 8088

COPY entrypoint.sh /usr/local/bin/audio-stream

RUN chmod +x /usr/local/bin/audio-stream

CMD ["/usr/local/bin/audio-stream"]