#!/usr/bin/env bash
# Uptime Kuma Clean Install (Ubuntu/Debian) - systemd only (no PM2, no Docker)
# v3.0 - for Coosef
# - Tam temizlik (eski systemd unit, PM2 süreçleri, tipik klasörler, olası docker container)
# - Node.js LTS (NodeSource) kurar
# - 'kuma' servis kullanıcısı ile /opt/uptime-kuma altına kurulum
# - systemd servisi oluşturur ve (istersen) otomatik başlatır
# - ufw aktifse portu açar
# - SQLite (kuma.db) varsayılan. Backup/restore yardımcıları mevcut.

set -euo pipefail

# ---------- Helpers ----------
log()  { echo -e "[\e[32mINFO\e[0m] $*"; }
warn() { echo -e "[\e[33mWARN\e[0m] $*"; }
err()  { echo -e "[\e[31mERR \e[0m]  $*" >&2; }

require_root() { if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then err "Root ile çalıştır (sudo)."; exit 1; fi; }
ensure_cmd()   { command -v "$1" >/dev/null 2>&1; }

prompt_def() {
  local p="$1" d="$2" outvar="$3"
  read -rp "$p [$d]: " _in || true
  _in="${_in:-$d}"; printf -v "$outvar" "%s" "$_in"
}

rm_if_exists() {
  local t="$1"
  if [[ -e "$t" || -L "$t" ]]; then
    rm -rf --one-file-system "$t" 2>/dev/null || rm -rf "$t" || true
    log "Silindi: $t"
  fi
}

stop_disable_service() {
  local svc="$1"
  if systemctl list-unit-files | grep -q "^${svc}\.service"; then
    systemctl stop "${svc}.service" 2>/dev/null || true
    systemctl disable "${svc}.service" 2>/dev/null || true
    log "Servis durduruldu/disable edildi: ${svc}.service"
  fi
}

open_port_ufw() {
  local port="$1"
  if ensure_cmd ufw && ufw status | grep -q "Status: active"; then
    if ! ufw status | grep -qE " ${port}/tcp"; then
      warn "ufw etkin. ${port}/tcp açılıyor..."
      ufw allow "${port}"/tcp || true
      ufw reload || true
    fi
  fi
}

create_service_user() {
  local user="$1" home="$2"
  if ! id "$user" >/dev/null 2>&1; then
    log "Servis kullanıcısı oluşturuluyor: $user"
    useradd --system --home-dir "$home" --create-home --shell /usr/sbin/nologin "$user"
  else
    log "Servis kullanıcısı mevcut: $user"
  fi
}

# ---------- Full Cleanup ----------
cleanup_all() {
  log "Eski Uptime Kuma kalıntıları temizleniyor..."

  # PM2 süreçleri (varsa)
  if ensure_cmd pm2; then
    pm2 delete uptime-kuma >/dev/null 2>&1 || true
    pm2 save >/dev/null 2>&1 || true
    rm_if_exists "/root/.pm2/logs/uptime-kuma-out.log"
    rm_if_exists "/root/.pm2/logs/uptime-kuma-error.log"
  fi

  # systemd unit
  stop_disable_service "uptime-kuma"
  rm_if_exists "/etc/systemd/system/uptime-kuma.service"
  systemctl daemon-reload || true

  # olası çalışan node süreçleri
  pkill -f "server/server.js" 2>/dev/null || true

  # tipik dizinler
  for d in "/opt/uptime-kuma" "/usr/local/uptime-kuma" "/var/lib/uptime-kuma" "/srv/uptime-kuma"; do
    rm_if_exists "$d"
  done

  # olası docker kalıntısı (hiç kurmamış olsan bile zarar vermez)
  if ensure_cmd docker && docker ps -a --format '{{.Names}}' | grep -q '^uptime-kuma$'; then
    docker rm -f uptime-kuma >/dev/null 2>&1 || true
    log "Docker container (uptime-kuma) silindi."
  fi

  log "Temizlik tamam."
}

# ---------- .env Yaz ----------
write_env_file() {
  local dir="$1" host="$2" port="$3" datadir="$4"
  cat > "${dir}/.env" <<EOF
# ==== Uptime Kuma Environment (.env) ====
UPTIME_KUMA_HOST=${host}
UPTIME_KUMA_PORT=${port}
DATA_DIR=${datadir}

# --- (İLERİDE) MariaDB örnek değişkenleri (şimdilik yorumda kalsın) ---
# UPTIME_KUMA_DB_TYPE=mariadb
# UPTIME_KUMA_DB_HOSTNAME=127.0.0.1
# UPTIME_KUMA_DB_PORT=3306
# UPTIME_KUMA_DB_NAME=uptimekuma
# UPTIME_KUMA_DB_USERNAME=uptimekuma
# UPTIME_KUMA_DB_PASSWORD=strongpassword
EOF
}

# ---------- Kurulum ----------
install_kuma_systemd() {
  prompt_def "Kurulum klasörü" "/opt/uptime-kuma" INSTALL_DIR
  prompt_def "Dinleme portu"   "3001"             KUMA_PORT
  prompt_def "Bind host (0.0.0.0 tüm arayüzler)" "0.0.0.0" KUMA_HOST
  local DATA_DIR="${INSTALL_DIR}/data"
  local SVC_USER="kuma"

  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y curl git build-essential ca-certificates

  if ! ensure_cmd node; then
    log "Node.js LTS kuruluyor (NodeSource)..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
  else
    log "Node.js mevcut: $(node -v)"
  fi

  create_service_user "$SVC_USER" "$INSTALL_DIR"

  # Repo kurulumu
  log "Repo klonlanıyor -> $INSTALL_DIR"
  rm -rf "${INSTALL_DIR:?}/"* 2>/dev/null || true
  git clone https://github.com/louislam/uptime-kuma.git "$INSTALL_DIR"

  # .env
  write_env_file "$INSTALL_DIR" "$KUMA_HOST" "$KUMA_PORT" "$DATA_DIR"

  # Bağımlılıklar (servis kullanıcısıyla derlemek için)
  log "Bağımlılıklar kuruluyor (npm run setup)... (biraz sürebilir)"
  chown -R "$SVC_USER":"$SVC_USER" "$INSTALL_DIR"
  sudo -u "$SVC_USER" -H bash -lc "cd '$INSTALL_DIR' && npm run setup"

  # systemd unit
  cat >/etc/systemd/system/uptime-kuma.service <<UNIT
[Unit]
Description=Uptime-Kuma - Free & Open Source Uptime Monitoring
After=network.target

[Service]
Type=simple
User=${SVC_USER}
Group=${SVC_USER}
WorkingDirectory=${INSTALL_DIR}
Environment=NODE_ENV=production
Environment=DATA_DIR=${DATA_DIR}
Environment=UPTIME_KUMA_HOST=${KUMA_HOST}
Environment=UPTIME_KUMA_PORT=${KUMA_PORT}
ExecStart=/usr/bin/node server/server.js
Restart=always
RestartSec=5
# Kaynak tüketimini sınırlamak istersen (örnekler):
# MemoryMax=1024M
# CPUAccounting=true

[Install]
WantedBy=multi-user.target
UNIT

  systemctl daemon-reload
  # Otomatik başlatma tercihini soralım
  read -rp "Servisi hemen başlatıp boot'a ekleyeyim mi? [Y/n]: " START || true
  START="${START:-Y}"
  if [[ "$START" =~ ^[Yy]$ ]]; then
    systemctl enable --now uptime-kuma.service
  fi

  open_port_ufw "$KUMA_PORT"

  local ipaddr; ipaddr="$(hostname -I | awk '{print $1}')"
  log "Kurulum tamam. Arayüz: http://${ipaddr}:${KUMA_PORT}"
  log "SQLite dosyası: ${DATA_DIR}/kuma.db"
  echo "Servis komutları:"
  echo "  systemctl status uptime-kuma"
  echo "  journalctl -u uptime-kuma -f"
  echo "  systemctl restart uptime-kuma"
}

# ---------- Backup/Restore ----------
backup_sqlite() {
  prompt_def "Kurulum klasörü" "/opt/uptime-kuma" D
  local db="${D}/data/kuma.db"
  if [[ ! -f "$db" ]]; then err "SQLite bulunamadı: $db"; exit 1; fi
  local ts; ts="$(date +%Y%m%d_%H%M%S)"
  local dst="${D}/backup_kuma_${ts}.db"
  systemctl stop uptime-kuma 2>/dev/null || true
  cp -a "$db" "$dst"
  systemctl start uptime-kuma 2>/dev/null || true
  log "Yedek alındı -> $dst"
}

restore_sqlite() {
  prompt_def "Kurulum klasörü" "/opt/uptime-kuma" D
  read -rp "Geri yüklenecek .db dosyasının yolu: " SRC
  local db="${D}/data/kuma.db"
  if [[ ! -f "$SRC" ]]; then err "Kaynak dosya yok: $SRC"; exit 1; fi
  systemctl stop uptime-kuma 2>/dev/null || true
  mkdir -p "$(dirname "$db")"
  cp -a "$SRC" "$db"
  chown -R kuma:kuma "$D"
  systemctl start uptime-kuma 2>/dev/null || true
  log "Geri yüklendi -> $db"
}

# ---------- Menu ----------
main_menu() {
  echo "=== Uptime Kuma - systemd only (no PM2, no Docker) ==="
  echo "1) TEMİZLE + KUR (önerilen)"
  echo "2) SADECE TEMİZLE"
  echo "3) SADECE KUR"
  echo "4) SQLite YEDEK AL"
  echo "5) SQLite GERİ YÜKLE"
  read -rp "Seçim [1/2/3/4/5]: " c || true
  case "${c:-1}" in
    1) cleanup_all; install_kuma_systemd ;;
    2) cleanup_all ;;
    3) install_kuma_systemd ;;
    4) backup_sqlite ;;
    5) restore_sqlite ;;
    *) err "Geçersiz seçim"; exit 1 ;;
  esac
  log "Bitti."
}

require_root
main_menu
