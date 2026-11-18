#!/bin/bash
# Railway wrapper for Kodus's RabbitMQ image. It writes a few settings that
# must follow the container, not the host, then runs the image's own start
# script (which also creates the kodus-ai and kodus-ast vhosts).
set -euo pipefail

if [ -z "${RABBITMQ_DEFAULT_USER:-}" ] || [ -z "${RABBITMQ_DEFAULT_PASS:-}" ]; then
  echo "railway-start: RABBITMQ_DEFAULT_USER and RABBITMQ_DEFAULT_PASS must be set" >&2
  exit 1
fi

conf=/etc/rabbitmq/conf.d/90-railway.conf
{
  echo "# Written by railway-start.sh on every start. Do not edit."
  # The upstream default (free disk >= 1.2 x RAM) would block all publishing
  # on a small volume, because the container sees the host's RAM.
  echo "disk_free_limit.absolute = 200MB"
} > "$conf"

# Size the memory alarm to the container's memory limit, not the host's RAM.
limit=""
if [ -r /sys/fs/cgroup/memory.max ]; then
  limit=$(cat /sys/fs/cgroup/memory.max)
elif [ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
  limit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
fi
host_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
if [[ "$limit" =~ ^[0-9]+$ ]] && [ "$limit" -lt $((host_kb * 1024)) ]; then
  echo "total_memory_available_override_value = ${limit}" >> "$conf"
fi

exec docker-entrypoint.sh "$@"
