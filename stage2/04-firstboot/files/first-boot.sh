#!/bin/bash
set -euo pipefail

LOGFILE=/var/log/first-boot.log

# --- The ONE console message ---
echo "First boot setup started. Progress is being written to $LOGFILE"
echo "Follow it with:  tail -f $LOGFILE"


# --- Persistent hint for every SSH login ---
echo "First-boot setup log: $LOGFILE  (tail -f to watch)" > /etc/motd

# --- From here on, send everything to the log file only ---
exec >> "$LOGFILE" 2>&1

# --- Progress helper (log file only now) ---
TOTAL=5
log() { printf '%s [%s/%s] %s\n' "$(date '+%F %T')" "$1" "$TOTAL" "$2"; }
info() { printf '%s     %s\n' "$(date '+%F %T')" "$1"; }

CURRENT_STAGE="init"
trap 'printf "%s [X/%d] FAILED during: %s\n" "$(date "+%F %T")" "$TOTAL" "$CURRENT_STAGE"' ERR

# ---------------------------------------------------------------
CURRENT_STAGE="Configuring swap"
log 1 "$CURRENT_STAGE"

systemctl stop apt-daily.service apt-daily-upgrade.service 2>/dev/null || true
systemctl stop unattended-upgrades 2>/dev/null || true

info "Waiting for apt to be available..."
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
      fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
      fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
    info "apt is locked, waiting..."
    sleep 5
done
info "apt is free"

if ! swapon --show | grep -q "/swapfile"; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
fi

# ---------------------------------------------------------------
CURRENT_STAGE="Installing azenta-core"
log 2 "$CURRENT_STAGE"
dpkg -i /opt/azenta-debs/azenta-core*.deb
systemctl daemon-reload          # make sure systemd sees the unit the deb just installed

# ---------------------------------------------------------------
CURRENT_STAGE="Waiting for cube-connect install service"
log 3 "$CURRENT_STAGE"
SERVICE_NAME="azenta-core-cube-connect-install.service"

if systemctl cat "$SERVICE_NAME" >/dev/null 2>&1; then
    info "Starting $SERVICE_NAME and waiting for it to finish..."
    # --wait blocks until the unit actually completes
    systemctl start --wait "$SERVICE_NAME" || true

    # Verify it finished cleanly before moving on
    STATE=$(systemctl show -p Result --value "$SERVICE_NAME" 2>/dev/null)
    info "$SERVICE_NAME finished (Result=$STATE)"
else
    info "$SERVICE_NAME not found — skipping"
fi

# ---------------------------------------------------------------
CURRENT_STAGE="Installing azenta-server"
log 4 "$CURRENT_STAGE"
dpkg -i /opt/azenta-debs/azenta-server*.deb
# ---------------------------------------------------------------

CURRENT_STAGE="Cleanup + reboot"
log 5 "$CURRENT_STAGE"
rm -f /etc/first-boot.sh
systemctl disable first-boot.service || true

log "OK" "First boot setup complete"
reboot
