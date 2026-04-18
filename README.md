# APOCODECK
### *When the grid goes dark — APOCODECK stays on.*

```
 █████╗ ██████╗  ██████╗  ██████╗██████╗ ███████╗ ██████╗██╗  ██╗
██╔══██╗██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██║ ██╔╝
███████║██████╔╝██║   ██║██║     ██║  ██║█████╗  ██║     █████╔╝ 
██╔══██║██╔═══╝ ██║   ██║██║     ██║  ██║██╔══╝  ██║     ██╔═██╗ 
██║  ██║██║     ╚██████╔╝╚██████╗██████╔╝███████╗╚██████╗██║  ██╗
╚═╝  ╚═╝╚═╝      ╚═════╝  ╚═════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝
```

---

## Overview

APOCODECK is a self-contained, offline-first cyberdeck built on a **Raspberry Pi 5 8GB** (while the Raspberry Pi 5 is recommended, it is not necessary) running **Debian Bookworm 64-bit (ARM64)** (The chosen OS is necessary so as not to cause conflicts with the packages). It is designed to operate fully independently of the internet — combining offensive cybersecurity tooling, offline reference systems, emergency communications, and survival utilities into a single portable platform.

Whether the scenario is a penetration test in a dead zone, a grid-down emergency, or a field operation with no infrastructure, APOCODECK is built to function.

---

## Hardware

| Component | Spec |
|-----------|------|
| Platform | Raspberry Pi 5 |
| RAM | 8GB |
| OS | Raspberry Pi OS Bookworm 64-bit |
| Architecture | ARM64 (aarch64) |
| Kernel | 6.x |
| Network | Built-in WiFi (hotspot-capable) + optional RTL-SDR dongle |

---

## Setup

The entire stack is deployed via a single modular bash script:

```bash
sudo bash cyberdeck_setup.sh
```

The script will prompt you to select which modules to install. All modules are optional and independent.

### Prerequisites

- Fresh Raspberry Pi OS Bookworm 64-bit install
- Internet connection for initial package download
- Run as root (`sudo`)

---

## Modules

### Module 1 — Offensive Cyber

A full offensive security toolkit for network reconnaissance, exploitation, wireless attacks, and password cracking.

**Network Scanning**
- `nmap` — port scanning, service detection, OS fingerprinting
- `masscan` — high-speed large-range port scanner
- `netcat` — raw TCP/UDP connections, reverse shells, file transfer
- `socat` — advanced relay and tunneling
- `proxychains4` — route traffic through proxy chains or Tor
- `tcpdump` — command-line packet capture
- `wireshark` / `tshark` — deep packet inspection
- `arp-scan` — local network host discovery
- `nbtscan` — NetBIOS/Windows host discovery

**Web Application Testing**
- `nikto` — automated web server vulnerability scanner
- `sqlmap` — automated SQL injection and database extraction
- `dirb` / `gobuster` — hidden directory and file brute-forcing
- `whatweb` — web technology fingerprinting
- `ffuf` — fast web fuzzer

**Password & Cracking**
- `john` (John the Ripper) — multi-format offline password cracker
- `hydra` — network login brute-forcer (SSH, FTP, HTTP, RDP, and more)
- `medusa` — parallel network brute-forcer
- `hashcat` — GPU/CPU accelerated hash cracking
- **SecLists** — comprehensive wordlist collection at `/usr/share/seclists/`
- **rockyou.txt** — classic 14M password wordlist at `/usr/share/wordlists/rockyou.txt`

**Wireless**
- `aircrack-ng` — WEP/WPA capture and cracking suite
- `reaver` / `bully` — WPS PIN brute-force
- `macchanger` — MAC address spoofing
- `bettercap` — MitM framework, ARP/DNS spoofing, credential capture

**Exploitation**
- `metasploit-framework` — industry-standard exploitation framework
- `bettercap` — active network attack framework

**Recon**
- `fierce` / `dnsrecon` — DNS enumeration and subdomain discovery
- `whois` — domain and IP registration lookup
- `traceroute` — network path mapping

---

### Module 2 — Offline Maps

Serve interactive OpenStreetMap tiles locally with no internet required.

- **tileserver-gl-light** — serves `.mbtiles` files as interactive map tiles over HTTP
- **QGIS** — full desktop GIS application for geographic data analysis
- **QMapShack** — lightweight map viewer for hiking/navigation maps

**Map tile server** runs at `http://192.168.50.1:8080` when the hotspot is active.

**To add maps:** Download `.mbtiles` files for your region and place them in `/opt/maps/mbtiles/`
- OpenMapTiles: https://openmaptiles.com/downloads/
- Geofabrik: https://download.geofabrik.de/

**Start map server:**
```bash
systemctl start mapserver
```

---

### Module 3 — Kiwix + WiFi Hotspot

Serve offline reference content (Wikipedia, medical guides, survival manuals, Stack Overflow, etc.) over a local WiFi hotspot to any connected device.

**Components:**
- `kiwix-serve` — serves `.zim` files as a local website
- `hostapd` — turns the Pi's WiFi into an access point
- `dnsmasq` — provides DHCP and DNS for hotspot clients

**Hotspot credentials** are set during installation (prompted at setup time).

**Quick commands:**
```bash
hotspot-start    # bring up hotspot + Kiwix + maps
hotspot-stop     # shut down hotspot
```

**Kiwix library** available at `http://192.168.50.1:8888` for all connected clients.

**To add content:** Place `.zim` files in `/opt/kiwix/zims/`
- Download ZIMs: https://download.kiwix.org/zim/
- Recommended: Wikipedia, WikiMed (medical), Wikivoyage, Stack Overflow

---

### Module 4 — Comms / SDR / Radio

Software-defined radio reception, digital radio modes, and off-grid mesh communications.

- **rtl-sdr** — driver for RTL-SDR USB dongles (~$25), enabling wideband radio reception
- **GNU Radio** — signal processing framework for building custom radio pipelines
- **GQRX** — GUI SDR receiver; tune FM, aviation, weather satellites, and more
- **dump1090** — ADS-B decoder; tracks nearby aircraft with no internet
- **fldigi** — digital radio modes (PSK31, RTTY, Olivia) — pass text over audio
- **Direwolf** — APRS software modem for packet radio over audio
- **CHIRP** — program Baofeng and other handheld radios from the Pi
- **Meshtastic CLI** — manage LoRa mesh radio modules for off-grid encrypted messaging
- **ax25-tools** — AX.25 packet radio stack

**Recommended hardware:** RTL-SDR v3 dongle (~$25), Baofeng UV-5R handheld, Meshtastic LoRa module

---

### Module 5 — Survival Utilities

General-purpose offline tools for long-term field operation.

- **KeePassXC** — encrypted offline password vault
- **Syncthing** — peer-to-peer file sync across devices with no server
- **Ollama** — run large language models locally; pull `llama3.2:3b` for an offline AI assistant
- **ffmpeg** — video/audio conversion and processing
- **VLC** / **mpv** — media playback
- **Calibre** — offline ebook library management
- **LibreOffice** — full offline office suite
- **Stellarium** — offline planetarium; identify stars and planets in the field
- **gpsd** — GPS daemon for USB GPS receivers
- **OpenVPN** / **WireGuard** — VPN and private network tunneling
- **Rsync** — efficient file backup and sync

**Pull an offline AI model after install:**
```bash
ollama pull llama3.2:3b
ollama run llama3.2:3b
```

---

### Module 6 — System Hardening

- **UFW** — firewall; blocks all inbound except SSH (22), Kiwix (8888), Maps (8080)
- **fail2ban** — auto-bans IPs with repeated failed login attempts
- **SSH hardening** — root login disabled, max auth tries limited
- **hostapd.conf** — locked to root-only read (`chmod 600`)
- **Unattended-upgrades** — automatic security patch application
- **LUKS** (recommended) — full disk encryption; set up during OS install

---

## Directory Structure

```
/usr/share/seclists/          # SecLists wordlists
/usr/share/wordlists/         # rockyou.txt symlink
/opt/kiwix/zims/              # ZIM files for Kiwix
/opt/maps/mbtiles/            # MBTiles for offline maps
/etc/hostapd/hostapd.conf     # Hotspot config (root-only)
/etc/dnsmasq.d/hotspot.conf   # DHCP/DNS config
/usr/local/bin/hotspot-start  # Hotspot start script
/usr/local/bin/hotspot-stop   # Hotspot stop script
/var/log/cyberdeck_setup.log  # Full install log
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Start hotspot + services | `hotspot-start` |
| Stop hotspot | `hotspot-stop` |
| Browse Kiwix (on hotspot) | `http://192.168.50.1:8888` |
| Browse maps (on hotspot) | `http://192.168.50.1:8080` |
| Run Metasploit | `msfconsole` |
| Run offline AI | `ollama run llama3.2:3b` |
| Scan network | `nmap -sV 192.168.x.x/24` |
| Crack hashes | `hashcat -m 0 hashes.txt /usr/share/wordlists/rockyou.txt` |
| Brute-force SSH | `hydra -l user -P /usr/share/wordlists/rockyou.txt ssh://target` |
| Start map server | `systemctl start mapserver` |
| View install log | `cat /var/log/cyberdeck_setup.log` |

---

## Post-Install Checklist

- [ ] Change hotspot password in `/etc/hostapd/hostapd.conf`
- [ ] Change system user password: `passwd`
- [ ] Download `.zim` files to `/opt/kiwix/zims/`
- [ ] Download `.mbtiles` for your region to `/opt/maps/mbtiles/`
- [ ] Pull Ollama model: `ollama pull llama3.2:3b`
- [ ] Program Baofeng with CHIRP
- [ ] Set up KeePassXC vault
- [ ] Test hotspot: `hotspot-start`
- [ ] Verify Kiwix serves at `http://192.168.50.1:8888`

---

## Security Notes

- This device is designed for authorized penetration testing and personal resilience use only
- All offensive tools should only be used on networks and systems you own or have explicit written permission to test
- The hotspot password is stored in plaintext at `/etc/hostapd/hostapd.conf` (root-only read) — this is a limitation of hostapd, not a misconfiguration
- Full disk encryption (LUKS) is strongly recommended and should be configured during the initial OS flash

---

## License & Use

APOCODECK is a personal build project. The setup script and documentation are free to use, modify, and redistribute. All included software retains its original license. Use responsibly.

---

*Built on Raspberry Pi OS Bookworm · ARM64 · Pi 5 8GB · No cloud. No mercy.*
