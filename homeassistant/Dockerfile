# https://hub.docker.com/r/homeassistant/home-assistant/tags
FROM homeassistant/home-assistant:2025.11@sha256:c11dd7c74039223c43079d700aa559d6dc61e8e0b38a08d651f91d1bc550cff5

# /config is a persistent named volume that shadows files COPYed into /config at
# build time. Stage the repo-managed config outside /config and overlay it on
# every boot via the entrypoint wrapper (see entrypoint.sh).
COPY configuration.yaml /usr/src/ha-config/configuration.yaml
COPY automations /usr/src/ha-config/automations
COPY nd-aktuell-search.sh /usr/local/bin/nd-aktuell-search
COPY entrypoint.sh /usr/local/bin/ha-entrypoint.sh
RUN apk add --no-cache curl \
	&& chmod +x /usr/local/bin/ha-entrypoint.sh /usr/local/bin/nd-aktuell-search

ENTRYPOINT ["/usr/local/bin/ha-entrypoint.sh"]

