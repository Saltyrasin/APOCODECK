#!/bin/bash
# ============================================================
#  CYBERDECK SETUP SCRIPT — Pi 5 Bookworm 64-bit
#  Modules: Offensive Cyber | Offline Maps | Kiwix Hotspot
#           Comms/SDR | Survival Utilities | Hardening
# ============================================================
# Run as root: sudo bash cyberdeck_setup.sh
# You will be prompted to choose which modules to install.
# ============================================================

set -e

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold versions
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Dim versions
DIM_RED='\033[2;31m'
DIM_GREEN='\033[2;32m'

# Background colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_BLACK='\033[40m'

LOGFILE="/var/log/cyberdeck_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

banner() {
    echo -e "${CYAN}"
    echo " ╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo " ║  [SYS:BOOT] [NET:OFFLINE] [ARM64] [PI-5-8GB] [BOOKWORM] [STATUS:ARMED]        ║"
    echo " ╠═══════════════════════════════════════════════════════════════════════════════╣"
    echo " ║                                                                               ║"
    echo " ║   █████╗ ██████╗  ██████╗  ██████╗██████╗ ███████╗ ██████╗██╗  ██╗            ║"
    echo " ║  ██╔══██╗██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██║ ██╔╝            ║"
    echo " ║  ███████║██████╔╝██║   ██║██║     ██║  ██║█████╗  ██║     █████╔╝             ║"
    echo " ║  ██╔══██║██╔═══╝ ██║   ██║██║     ██║  ██║██╔══╝  ██║     ██╔═██╗             ║"
    echo " ║  ██║  ██║██║     ╚██████╔╝╚██████╗██████╔╝███████╗╚██████╗██║  ██╗            ║"
    echo " ║  ╚═╝  ╚═╝╚═╝      ╚═════╝  ╚═════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝            ║"
    echo " ║                                                                               ║"
    echo " ╠═════════════════════════════╦═════════════════════════════════════════════════╣"
    echo " ║  PLATFORM                   ║  MODULES                                        ║"
    echo " ║  ├─ Raspberry Pi 5 8GB      ║  ├─ [✓] Offensive Cyber                         ║"
    echo " ║  ├─ Bookworm 64-bit         ║  ├─ [✓] Offline Maps                            ║"
    echo " ║  ├─ ARM64 aarch64           ║  ├─ [✓] Kiwix + Hotspot                         ║"
    echo " ║  ├─ Kernel 6.x              ║  ├─ [✓] SDR + Comms                             ║"
    echo " ║  └─ Status: ARMED           ║  └─ [✓] Survival Utils                          ║"
    echo " ╠═════════════════════════════╩═════════════════════════════════════════════════╣"
    echo " ║  WHEN THE GRID GOES DARK — APOC DECK STAYS ON                                 ║"
    echo " ╠═══════════════════════════════════════════════════════════════════════════════╣"
    echo " ║  Log: $LOGFILE"
    echo -e " ╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

confirm() {
    read -rp "$(echo -e "${WHITE}[?] Install module: ${BOLD}$1${NC}${WHITE}? [Y/n]: ${NC}")" ans
    [[ "$ans" =~ ^[Nn]$ ]] && return 1 || return 0
}

section() {
    echo ""
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}  $1${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

info()    { echo -e "${BOLD_CYAN}[*] $1${NC}"; }
success() { echo -e "${GREEN}[✓] $1${NC}"; }
warn()    { echo -e "${WHITE}[!] $1${NC}"; }
error()   { echo -e "${RED}[✗] $1${NC}"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Run this script as root: sudo bash $0"
        exit 1
    fi
}

base_update() {
    section "System Update"
    info "Updating package lists and upgrading system..."
    apt-get update -qq
    apt-get upgrade -y -qq
    apt-get install -y -qq \
        curl wget git vim htop tmux screen \
        net-tools dnsutils build-essential \
        python3 python3-pip python3-venv \
        ufw fail2ban unattended-upgrades \
        ca-certificates gnupg lsb-release \
        zip unzip p7zip-full tree
    success "Base system updated."
}

# ============================================================
# MODULE 1: OFFENSIVE CYBER
# ============================================================
install_offensive() {
    section "MODULE 1: Offensive Cyber Tools"

    info "Installing network scanning tools..."
    apt-get install -y -qq \
        nmap masscan netcat-openbsd socat \
        proxychains4 tcpdump wireshark tshark \
        arp-scan nbtscan

    info "Installing web application tools..."
    apt-get install -y -qq \
        nikto sqlmap dirb gobuster \
        curl wget

    info "Installing password/cracking tools..."
    apt-get install -y -qq \
        john hydra medusa \
        hashcat



    info "Installing wireless tools..."
    apt-get install -y -qq \
        aircrack-ng reaver bully \
        iw wireless-tools wpasupplicant \
        dnsmasq hostapd macchanger

    info "Installing exploitation framework (Metasploit)..."
    if ! command -v msfconsole &>/dev/null; then
        curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg.key \
            | gpg --dearmor -o /usr/share/keyrings/metasploit-framework.gpg
        echo "deb [signed-by=/usr/share/keyrings/metasploit-framework.gpg] \
https://apt.metasploit.com/ buster main" \
            > /etc/apt/sources.list.d/metasploit-framework.list
        apt-get update -qq
        apt-get install -y -qq metasploit-framework
    else
        warn "Metasploit already installed, skipping."
    fi


    info "Extracting rockyou.txt and symlinking to /usr/share/wordlists/..."
    ROCKYOU_GZ="/usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.gz"
    ROCKYOU_TXT="/usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt"
    if [[ -f "$ROCKYOU_GZ" ]]; then
        gunzip -f "$ROCKYOU_GZ"
    fi
    if [[ -f "$ROCKYOU_TXT" ]]; then
        mkdir -p /usr/share/wordlists
        ln -sf "$ROCKYOU_TXT" /usr/share/wordlists/rockyou.txt
        success "rockyou.txt available at /usr/share/wordlists/rockyou.txt"
    else
        warn "rockyou.txt not found — SecLists clone may have failed."
    fi

    echo ""
    read -rp "$(echo -e "${WHITE}[?] Download additional password lists? (about 179.58 MB) [Y/n]: ${NC}")" ans_lists
    
    # =======================================================
    # DOWNLOADING OTHER PASSWORD LISTS...
    # =======================================================

    if [[ ! "$ans_lists" =~ ^[Nn]$ ]]; then
        info "Downloading 10k-most-common password list..."
        wget -q "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt" -O /usr/share/wordlists/top10k.txt
        success "top10k.txt available at /usr/share/wordlists/top10k.txt"


        info "Downloading top-20-common-SSH-passwords password list..."
        wget -q "https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/top-20-common-SSH-passwords.txt" -O /usr/share/wordlists/top-20-common-SSH-passwords.txt
        success "top-20-common-SSH-passwords.txt available at /usr/share/wordlists/top-20-common-SSH-passwords.txt"


        info "Downloading probable-v2_top-12000 password list..."
        wget -q "https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/probable-v2_top-12000.txt" -O /usr/share/wordlists/probable-v2_top-12000.txt
        success "probable-v2_top-12000.txt available at /usr/share/wordlists/probable-v2_top-12000.txt"


        info "Downloading default-passwords password list..."
        wget -q "https://github.com/danielmiessler/SecLists/blob/master/Passwords/Default-Credentials/default-passwords.txt -O /usr/share/wordlists/default-passwords.txt
        success "default-passwords.txt available at /usr/share/wordlists/default-passwords.txt"
        
    else
        info "Skipping additional password lists."
    fi

    info "Installing additional recon tools..."
    apt-get install -y -qq \
        whatweb fierce dnsrecon \
        whois traceroute

    info "Installing Bettercap..."
    apt-get install -y -qq bettercap || {
        warn "bettercap not in repos, building from source..."
        apt-get install -y -qq golang
        go install github.com/bettercap/bettercap@latest
        cp ~/go/bin/bettercap /usr/local/bin/
    }

    success "Offensive cyber tools installed."
}

# ============================================================
# MODULE 2: OFFLINE MAPS
# ============================================================
install_maps() {
    section "MODULE 2: Offline Maps"

    info "Installing map tile server dependencies..."
    apt-get install -y -qq \
        nodejs npm sqlite3

    info "Installing tileserver-gl-light (serves MBTiles offline)..."
    npm install -g tileserver-gl-light 2>/dev/null || \
        warn "tileserver-gl-light install failed — check node version."

    info "Installing QGIS for desktop map viewing..."
    apt-get install -y -qq qgis || warn "QGIS install failed — may need to add repo manually."

    info "Installing QMapShack..."
    apt-get install -y -qq qmapshack || warn "QMapShack not available in repos."

    # Create maps directory
    mkdir -p /opt/maps/mbtiles
    mkdir -p /opt/maps/scripts

    info "Creating map tile server startup script..."
    cat > /opt/maps/scripts/start_mapserver.sh << 'EOF'
#!/bin/bash
# Start offline map tile server
# Place your .mbtiles files in /opt/maps/mbtiles/
# Download MBTiles from: https://openmaptiles.com/downloads/
# or: https://download.geofabrik.de/

MBTILES_DIR="/opt/maps/mbtiles"
PORT=8080

if ls "$MBTILES_DIR"/*.mbtiles 1>/dev/null 2>&1; then
    echo "[*] Starting tileserver-gl on port $PORT..."
    tileserver-gl-light --mbtiles "$MBTILES_DIR" --port $PORT
else
    echo "[!] No .mbtiles files found in $MBTILES_DIR"
    echo "[!] Download your region from https://openmaptiles.com/downloads/"
    echo "[!] Place the .mbtiles file in $MBTILES_DIR and re-run."
fi
EOF
    chmod +x /opt/maps/scripts/start_mapserver.sh

    cat > /etc/systemd/system/mapserver.service << 'EOF'
[Unit]
Description=Offline Map Tile Server
After=network.target

[Service]
ExecStart=/opt/maps/scripts/start_mapserver.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    warn "Map tile server installed. Download MBTiles for your region:"
    warn "  https://openmaptiles.com/downloads/"
    warn "  Place files in /opt/maps/mbtiles/"
    warn "  Start with: systemctl start mapserver"
    success "Offline maps setup complete."
}

# ============================================================
# MODULE 3: KIWIX HOTSPOT
# ============================================================
install_kiwix_hotspot() {
    section "MODULE 3: Kiwix + Hotspot"

    info "Installing Kiwix server..."
    apt-get install -y -qq kiwix-tools || {
        warn "kiwix-tools not in repos, installing manually..."
        KIWIX_VER="2.3.1"
        KIWIX_ARCH="aarch64"
        KIWIX_URL="https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-${KIWIX_ARCH}-${KIWIX_VER}.tar.gz"
        wget -q "$KIWIX_URL" -O /tmp/kiwix-tools.tar.gz
        tar -xzf /tmp/kiwix-tools.tar.gz -C /tmp/
        cp /tmp/kiwix-tools_linux-${KIWIX_ARCH}-${KIWIX_VER}/kiwix-serve /usr/local/bin/
        chmod +x /usr/local/bin/kiwix-serve
    }

    mkdir -p /opt/kiwix/zims

    info "Creating Kiwix systemd service..."
    cat > /etc/systemd/system/kiwix.service << 'EOF'
[Unit]
Description=Kiwix Offline Content Server
After=network.target

[Service]
ExecStart=/usr/bin/kiwix-serve --port=8888 --library /opt/kiwix/library.xml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    info "Installing hotspot dependencies..."
    apt-get install -y -qq hostapd dnsmasq iptables

    # Detect wifi interface
    WIFI_IF=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -1)
    WIFI_IF="${WIFI_IF:-wlan0}"
    warn "Detected WiFi interface: $WIFI_IF (edit configs if different)"

    info "Configuring hostapd..."
    echo ""
    read -rp "$(echo -e "${WHITE}[?] Enter hotspot SSID [default: CYBERDECK]: ${NC}")" HOTSPOT_SSID
    HOTSPOT_SSID="${HOTSPOT_SSID:-CYBERDECK}"

    while true; do
        read -rsp "$(echo -e "${WHITE}[?] Enter hotspot password (min 8 chars): ${NC}")" HOTSPOT_PASS
        echo ""
        if [[ ${#HOTSPOT_PASS} -ge 8 ]]; then
            read -rsp "$(echo -e "${WHITE}[?] Confirm hotspot password: ${NC}")" HOTSPOT_PASS2
            echo ""
            if [[ "$HOTSPOT_PASS" == "$HOTSPOT_PASS2" ]]; then
                break
            else
                warn "Passwords do not match, try again."
            fi
        else
            warn "Password must be at least 8 characters."
        fi
    done

    cat > /etc/hostapd/hostapd.conf << EOF
interface=$WIFI_IF
driver=nl80211
ssid=$HOTSPOT_SSID
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$HOTSPOT_PASS
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
    success "Hotspot SSID: $HOTSPOT_SSID — credentials saved to /etc/hostapd/hostapd.conf"
    chmod 600 /etc/hostapd/hostapd.conf
    chown root:root /etc/hostapd/hostapd.conf
    success "Locked hostapd.conf to root-only access."

    info "Configuring dnsmasq for hotspot..."
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak 2>/dev/null || true
    cat > /etc/dnsmasq.d/hotspot.conf << EOF
interface=$WIFI_IF
dhcp-range=192.168.50.10,192.168.50.50,255.255.255.0,24h
address=/#/192.168.50.1
EOF

    info "Creating hotspot start/stop scripts..."
    cat > /usr/local/bin/hotspot-start << EOF
#!/bin/bash
WIFI_IF=$WIFI_IF
ip addr add 192.168.50.1/24 dev \$WIFI_IF 2>/dev/null || true
ip link set \$WIFI_IF up
systemctl start hostapd
systemctl start dnsmasq
systemctl start kiwix
echo "[*] Hotspot started on \$WIFI_IF"
echo "[*] Kiwix available at http://192.168.50.1:8888"
echo "[*] Maps available at http://192.168.50.1:8080"
EOF

    cat > /usr/local/bin/hotspot-stop << 'EOF'
#!/bin/bash
systemctl stop hostapd
systemctl stop dnsmasq
echo "[*] Hotspot stopped."
EOF

    chmod +x /usr/local/bin/hotspot-start /usr/local/bin/hotspot-stop

    systemctl daemon-reload
    systemctl enable kiwix

    success "Kiwix + hotspot configured."
    warn "Place .zim files in /opt/kiwix/zims/"
    warn "Run 'hotspot-start' to bring up the access point."
    warn "Clients connect to SSID: CYBERDECK and browse to http://192.168.50.1:8888"
}

# ============================================================
# MODULE 4: COMMS / SDR / RADIO
# ============================================================
install_comms() {
    section "MODULE 4: Comms, SDR, Radio"

    info "Installing SDR tools..."
    apt-get install -y -qq \
        rtl-sdr librtlsdr-dev \
        dump1090-mutability

    info "Installing GNU Radio and GQRX (this may take a while)..."
    apt-get install -y -qq gnuradio gqrx-sdr || true

    info "Removing problematic xtrx-dkms package (not needed for RTL-SDR)..."
    apt-get remove -y xtrx-dkms 2>/dev/null || true
    dpkg --configure -a || true
    apt-get install -f -y -qq || true

    info "Installing digital radio modes..."
    apt-get install -y -qq \
        fldigi flrig \
        direwolf

    info "Installing CHIRP (radio programmer)..."
    apt-get install -y -qq chirp || {
        warn "CHIRP not in repos. Install via:"
        warn "  pip3 install chirp"
    }

    info "Installing Meshtastic CLI..."
    pip3 install meshtastic --break-system-packages || \
        warn "Meshtastic install failed — try: pip3 install meshtastic"

    info "Installing packet radio tools..."
    apt-get install -y -qq ax25-tools ax25-apps || true

    success "Comms/SDR tools installed."
    warn "RTL-SDR: plug in dongle and run 'gqrx' to scan frequencies."
    warn "Meshtastic: connect LoRa module and run 'meshtastic --info'"
}

# ============================================================
# MODULE 5: SURVIVAL / OFFLINE UTILITIES
# ============================================================
install_survival() {
    section "MODULE 5: Survival & Offline Utilities"

    info "Installing KeePassXC (offline password vault)..."
    apt-get install -y -qq keepassxc

    info "Installing Syncthing (offline mesh file sync)..."
    curl -fsSL https://syncthing.net/release-key.gpg \
        | gpg --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] \
https://apt.syncthing.net/ syncthing stable" \
        > /etc/apt/sources.list.d/syncthing.list
    apt-get update -qq
    apt-get install -y -qq syncthing

    info "Installing Ollama (local LLM — offline AI)..."
    if ! command -v ollama &>/dev/null; then
        curl -fsSL https://ollama.com/install.sh | sh
        warn "After install, pull a small model: ollama pull llama3.2:3b"
    else
        warn "Ollama already installed."
    fi

    info "Installing media tools..."
    apt-get install -y -qq \
        ffmpeg vlc mpv \
        imagemagick

    info "Installing document/reference tools..."
    apt-get install -y -qq \
        zim calibre \
        libreoffice-writer libreoffice-calc \
        evince

    info "Installing survival reference tools..."
    apt-get install -y -qq \
        stellarium \
        gpsd gpsd-clients \
        python3-ephem

    info "Installing network utilities..."
    apt-get install -y -qq \
        openvpn wireguard \
        nfs-common samba-client \
        openssh-server rsync

    success "Survival utilities installed."
}

# ============================================================
# MODULE 6: SYSTEM HARDENING
# ============================================================
install_hardening() {
    section "MODULE 6: System Hardening"

    info "Configuring UFW firewall..."
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 8888/tcp comment 'Kiwix'
    ufw allow 8080/tcp comment 'Map server'
    ufw --force enable
    success "UFW configured."

    info "Configuring fail2ban..."
    systemctl enable fail2ban
    systemctl start fail2ban
    success "Fail2ban enabled."

    info "Hardening SSH..."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries.*/MaxAuthTries 4/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    success "SSH hardened."

    info "Disabling unused services..."
    for svc in bluetooth avahi-daemon; do
        systemctl disable "$svc" 2>/dev/null && \
            info "Disabled: $svc" || true
    done

    info "Enabling automatic security updates..."
    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
EOF

    success "System hardening complete."
    warn "Consider setting up LUKS full-disk encryption on your next fresh install."
    warn "Change your pi/root password if you haven't already: passwd"
}

# ============================================================
# SUMMARY
# ============================================================
print_summary() {
    section "Setup Complete — Quick Reference"
    echo ""
    echo -e "${BOLD}  HOTSPOT${NC}"
    echo "    Start:        hotspot-start"
    echo "    Stop:         hotspot-stop"
    echo "    SSID:         CYBERDECK"
    echo "    Password:     changeme123  ← CHANGE THIS"
    echo ""
    echo -e "${BOLD}  SERVICES${NC}"
    echo "    Kiwix:        http://192.168.50.1:8888  (zims in /opt/kiwix/zims/)"
    echo "    Maps:         http://192.168.50.1:8080  (mbtiles in /opt/maps/mbtiles/)"
    echo ""
    echo -e "${BOLD}  TOOLS${NC}"
    echo "    Metasploit:   msfconsole"
    echo "    Nmap:         nmap"
    echo "    Wordlists:    /usr/share/seclists/ or /usr/share/wordlists"
    echo "    Ollama LLM:   ollama run llama3.2:3b"
    echo "    Syncthing:    syncthing (browser UI on port 8384)"
    echo ""
    echo -e "${BOLD}  NEXT STEPS${NC}"
    echo "    1. Change hotspot password in /etc/hostapd/hostapd.conf"
    echo "    2. Change your system password: passwd"
    echo "    3. Download .zim files: https://download.kiwix.org/zim/"
    echo "    4. Download MBTiles for your region: https://openmaptiles.com/downloads/"
    echo "    5. Pull an LLM model: ollama pull llama3.2:3b"
    echo "    6. Register ham license if using TX on SDR/radio"
    echo ""
    echo -e "${CYAN}  Log saved to: $LOGFILE${NC}"
    echo ""
}

# ============================================================
# MAIN
# ============================================================
check_root
banner

echo -e "${BOLD}Select modules to install:${NC}"
echo ""

MODS=()
confirm "Base system update (recommended)"        && MODS+=(base)
confirm "Offensive Cyber Tools"                   && MODS+=(offensive)
confirm "Offline Maps (tileserver + QGIS)"        && MODS+=(maps)
confirm "Kiwix + WiFi Hotspot"                    && MODS+=(kiwix)
confirm "Comms / SDR / Radio (GNU Radio, CHIRP)"  && MODS+=(comms)
confirm "Survival Utilities (Ollama, KeePass...)" && MODS+=(survival)
confirm "System Hardening (UFW, fail2ban, SSH)"   && MODS+=(hardening)

echo ""
info "Installing selected modules: ${MODS[*]}"
echo ""

for mod in "${MODS[@]}"; do
    case $mod in
        base)      base_update ;;
        offensive) install_offensive ;;
        maps)      install_maps ;;
        kiwix)     install_kiwix_hotspot ;;
        comms)     install_comms ;;
        survival)  install_survival ;;
        hardening) install_hardening ;;
    esac
done

print_summary
