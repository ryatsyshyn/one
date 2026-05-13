#!/bin/bash

# Shared helpers for the BlueCat IPAM driver action scripts.

BLUECAT_CONFIG="${BLUECAT_CONFIG:-/etc/one/bluecat_ipam.conf}"
BLUECAT_LOG="${BLUECAT_LOG:-/tmp/bluecat-ipam.log}"

bluecat_log() {
    printf '%s\n' "$*" >> "$BLUECAT_LOG"
}

bluecat_log_block() {
    {
        printf '===== %s %s =====\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$1"
        shift
        printf '%s\n' "$@"
        printf '\n'
    } >> "$BLUECAT_LOG"
}

bluecat_log_decoded_action() {
    {
        printf '%s\n' '--- decoded XML ---'
        printf '%s' "$DRV_ACTION" | base64 -d 2>/dev/null || printf '%s\n' '<failed to decode driver action>'
        printf '\n'
    } >> "$BLUECAT_LOG"
}

bluecat_fail() {
    bluecat_log "ERROR: $1"
    echo "-1"
    exit 1
}

bluecat_load_config() {
    if [ ! -r "$BLUECAT_CONFIG" ]; then
        bluecat_fail "Missing or unreadable BlueCat config: $BLUECAT_CONFIG"
    fi

    # shellcheck source=/etc/one/bluecat_ipam.conf
    . "$BLUECAT_CONFIG" || bluecat_fail "Failed to source BlueCat config: $BLUECAT_CONFIG"

    BLUECAT_MOCK="${BLUECAT_MOCK:-no}"
}

bluecat_require_command() {
    command -v "$1" >/dev/null 2>&1 || bluecat_fail "Missing required command for BlueCat integration: $1"
}

bluecat_require_api_credentials() {
    [ -n "$BLUECAT_URL" ] || bluecat_fail "Missing BLUECAT_URL in $BLUECAT_CONFIG"
    [ -n "$BLUECAT_USER" ] || bluecat_fail "Missing BLUECAT_USER in $BLUECAT_CONFIG"
    [ -n "$BLUECAT_PASS" ] || bluecat_fail "Missing BLUECAT_PASS in $BLUECAT_CONFIG"
}

bluecat_require_curl_api_config() {
    bluecat_require_api_credentials
    bluecat_require_command curl
}

bluecat_require_real_api_config() {
    bluecat_require_curl_api_config
    bluecat_require_command jq
}
