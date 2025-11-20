
# Build stage
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG BUILD_IMAGE=balenalib/raspberrypi4-64-debian-python:3.11-latest
ARG RUN_IMAGE=balenalib/raspberrypi4-64-debian-python:3.11-latest-run

FROM ${RUN_IMAGE} AS run

ENV UDEV=on
ENV VENV=/tinkerforge2mqtt/.venv-app/bin
ENV OTHERENV=/root/.local/bin
ENV PATH="$VENV:$OTHERENV:$PATH"


RUN apt-get update && \
	apt-get install -y --no-install-recommends curl gnupg lsb-release ca-certificates git wireless-tools python3-venv git uhubctl && \
	curl -fsSL https://download.tinkerforge.com/apt/debian/tinkerforge.gpg -o /usr/share/keyrings/tinkerforge-archive.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/tinkerforge-archive.gpg] https://download.tinkerforge.com/apt/debian $(lsb_release -cs) main" > /etc/apt/sources.list.d/tinkerforge.list && \
	apt-get update && apt-get install -y --no-install-recommends brickd tinkerforge-shell &&\
	rm -rf /var/lib/apt/lists/*

# # Download the latest installer
# ADD https://astral.sh/uv/0.9.8/install.sh /uv-installer.sh

# # Run the installer then remove it
# RUN sh /uv-installer.sh && rm /uv-installer.sh

# Install build dependencies only
RUN git clone --branch main https://github.com/SuiOni/tinkerforge2mqtt.git /tinkerforge2mqtt && \
    cd /tinkerforge2mqtt && \
    git checkout 980fd83
WORKDIR /tinkerforge2mqtt
# Bootstrap project virtual environment via provided CLI (creates .venv-app)
RUN ./cli.py --help || true

RUN .venv-app/bin/python3 -m pip install -U pip
RUN .venv-app/bin/python3 -m pip install -U uv
RUN .venv-app/bin/uv sync --frozen --no-dev
RUN .venv-app/bin/pip3 install --no-deps -e .
RUN .venv-app/bin/pip3 install -U paho-mqtt==2.1
# RUN pip install -U paho-mqtt==2.1

COPY tinkerforge2mqtt.toml /root/.config/tinkerforge2mqtt/
COPY brickd.conf /etc/brickd.conf
COPY entrypoint.sh /entrypoint.sh


LABEL org.opencontainers.image.source="https://github.com/SuiOni/balena-homeassistant" \
	org.opencontainers.image.description="Tinkerforge to MQTT bridge with brickd" \
	org.opencontainers.image.licenses="GPL-3.0-or-later" \
	io.balena.architecture="${TARGETARCH:-unknown}" \
	io.balena.device-type="raspberrypi4-64" \
	io.balena.app-name="tinkerforge2mqtt" \
	org.opencontainers.image.base.name="${BASE_IMAGE}" \
	org.opencontainers.image.revision="${BUILDPLATFORM}-${TARGETPLATFORM}"

EXPOSE 4223

# Ensure dialout group exists and add root to it so the container can access serial devices
# (If you run as a different user, replace "root" with that username)
RUN getent group dialout || groupadd dialout \
 && usermod -aG dialout root

# ensure script is executable and has a proper shebang
RUN chmod +x /entrypoint.sh
# Dpnt need brickd install, conf and usb priviledge, anymore since using tinerforge wifi version.
# let the base image entrypoint call your script
CMD ["/entrypoint.sh"]