#!/bin/sh
# The /config directory is a persistent named volume, which shadows anything
# COPYed into /config at build time (a volume is only seeded from the image on
# first creation). To keep the repo as the source of truth for
# configuration.yaml, overlay the baked copy onto the volume on every boot,
# then hand off to the Home Assistant s6 init.
set -e

if [ -f /usr/src/ha-config/configuration.yaml ]; then
  cp /usr/src/ha-config/configuration.yaml /config/configuration.yaml
fi

if [ ! -e /config/automations.yaml ] && [ -f /usr/src/ha-config/automations.yaml ]; then
  cp /usr/src/ha-config/automations.yaml /config/automations.yaml
fi

exec /init "$@"
