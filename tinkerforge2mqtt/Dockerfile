
# Build stage
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG BASE_IMAGE=python:3.11-slim-bullseye

FROM ${BASE_IMAGE} AS build
# Install build dependencies only
RUN apt-get update && \
	apt-get install -y git python3-venv && \
	rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/SuiOni/tinkerforge2mqtt.git /tinkerforge2mqtt
WORKDIR /tinkerforge2mqtt
# Bootstrap project virtual environment via provided CLI (creates .venv-app)
RUN ./cli.py --help || true

FROM ${BASE_IMAGE} AS run
# Install brickd from Tinkerforge repository
RUN apt-get update && \
	apt-get install -y --no-install-recommends curl gnupg lsb-release ca-certificates git && \
	curl -fsSL https://download.tinkerforge.com/apt/debian/tinkerforge.gpg -o /usr/share/keyrings/tinkerforge-archive.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/tinkerforge-archive.gpg] https://download.tinkerforge.com/apt/debian $(lsb_release -cs) main" > /etc/apt/sources.list.d/tinkerforge.list && \
	apt-get update && apt-get install -y --no-install-recommends brickd && \
	rm -rf /var/lib/apt/lists/*

COPY --from=build /tinkerforge2mqtt /tinkerforge2mqtt
COPY tinkerforge2mqtt/entrypoint.sh /entrypoint.sh
COPY tinkerforge2mqtt/tinkerforge2mqtt.toml /root/.config/tinkerforge2mqtt/

RUN chmod +x /entrypoint.sh

LABEL org.opencontainers.image.source="https://github.com/SuiOni/balena-homeassistant" \
	org.opencontainers.image.description="Tinkerforge to MQTT bridge with brickd" \
	org.opencontainers.image.licenses="GPL-3.0-or-later" \
	io.balena.architecture="${TARGETARCH:-unknown}" \
	io.balena.device-type="raspberrypi4-64" \
	io.balena.app-name="tinkerforge2mqtt" \
	org.opencontainers.image.base.name="${BASE_IMAGE}" \
	org.opencontainers.image.revision="${BUILDPLATFORM}-${TARGETPLATFORM}"

EXPOSE 4223

ENTRYPOINT ["/entrypoint.sh"]