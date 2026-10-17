#!/usr/bin/env bash
# Run on your OWN Oracle Always Free VM, from the repo root; never print secrets.
set -euo pipefail
umask 077
: "${LUCIFER_ENV_FILE:=/etc/lucifer-x/staging.env}"
if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root, e.g.: sudo bash infrastructure/oracle/prepare-secrets.sh" >&2
  exit 1
fi
if [ -e "$LUCIFER_ENV_FILE" ]; then
  echo "Secrets already exist: $LUCIFER_ENV_FILE — refusing to overwrite or rotate."
  exit 0
fi
install -d -m 700 "$(dirname "$LUCIFER_ENV_FILE")"
tmp="$(mktemp "$(dirname "$LUCIFER_ENV_FILE")/.secrets.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
{
  printf 'POSTGRES_USER=lucifer_app_oci\n'
  printf 'POSTGRES_PASSWORD=%s\n' "$(openssl rand -hex 32)"
  printf 'ML_INTERNAL_TOKEN=%s\n' "$(openssl rand -hex 32)"
  printf 'APP_KEY=base64:%s\n' "$(openssl rand -base64 32 | tr -d '\n')"
} >"$tmp"
chmod 600 "$tmp"
mv "$tmp" "$LUCIFER_ENV_FILE"
echo "Created private staging secrets at $LUCIFER_ENV_FILE with mode 0600."
echo "Do not copy them to Git, GitHub Actions, chat, email, or browser."
