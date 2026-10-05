# TankScan

A menu-driven OSINT and recon toolkit in one Bash script. Wraps `curl`, `dig`, `whois` and `nmap` in a clean terminal UI so you don't have to remember flags.

```
 dMMMMMMP .aMMMb  dMMMMb  dMP dMP .dMMMb  .aMMMb  .aMMMb  dMMMMb                    .-----,____________     _                                    
   dMP   dMP"dMP dMP dMP dMP.dMP dMP" VP dMP"VMP dMP"dMP dMP dMP                  __l_____l------------    '-'                                     
  dMP   dMMMMMP dMP dMP dMMMMK"  VMMMb  dMP     dMMMMMP dMP dMP                 _/__________\_                                        
 dMP   dMP dMP dMP dMP dMP"AMF dP .dMP dMP.aMP dMP dMP dMP dMP                 /______________\                                    
dMP   dMP dMP dMP dMP dMP dMP  VMMMP"  VMMMP" dMP dMP dMP dMP                  ',(o)(o)(o)(o),'                             

```

---

## What's in it

| # | Option | Does |
|---|--------|------|
| 1 | Username Lookup | Checks a username against 250+ sites in parallel |
| 2 | Email Recon | MX records + HaveIBeenPwned breach check |
| 3 | Domain Info | A records, NS records, WHOIS summary |
| 4 | IP Geolocation | Country, city, ISP, ASN via ip-api.com |
| 5 | Phone Lookup | Digit breakdown + optional PhoneInfoga |
| 6 | WHOIS | Full WHOIS for a domain or IP |
| 7 | DNS Records | A / AAAA / MX / NS / TXT / CNAME / SOA |
| 8 | Port Scan | Toggle nmap flags and run them like normal |

---

## Tested on

Kali Linux (rolling). Should work on any Linux with bash, `curl`, `dig`, `whois` and `nmap`.

---

## Install

### Debian / Ubuntu / Kali
```bash
sudo apt update
sudo apt install -y curl dnsutils whois nmap jq
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```

### Fedora / RHEL / CentOS
```bash
sudo dnf install -y curl bind-utils whois nmap jq util-linux
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```

### Arch / Manjaro
```bash
sudo pacman -S --needed curl bind whois nmap jq util-linux
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```

### openSUSE
```bash
sudo zypper install -y curl bind-utils whois nmap jq util-linux
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```

### macOS
Needs GNU `flock` from Homebrew.
```bash
brew install curl bind whois nmap jq flock
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```
If `dig` or `whois` isn't found: `brew link --force bind` and `brew link --force whois`.

### Windows
Use WSL2. In PowerShell as admin:
```powershell
wsl --install -d Ubuntu
```
Then inside Ubuntu:
```bash
sudo apt update
sudo apt install -y curl dnsutils whois nmap jq
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```
Git Bash works too but `flock` isn't available, so the username scan runs serially. WSL is better.

### Termux
```bash
pkg update && pkg upgrade -y
pkg install -y git curl dnsutils whois nmap jq
pkg install -y tur-repo
pkg install -y util-linux
git clone https://github.com/shcrypta27/TankScanOSint.git
cd TankScanOSint
chmod +x tankscan.sh
./tankscan.sh
```
If `flock` still isn't working, the username scan falls back to one-at-a-time.

---

## Usage

```bash
./tankscan.sh
```

Pick a number from the menu. Each option asks for whatever it needs.

Some nmap scans (`-sS`, `-sN`, decoys) need root:
```bash
sudo ./tankscan.sh
```

---

## Feedback

If you find a bug, a site that's listed wrong in the username scan, or something that doesn't work on your system, let me know. Same goes the other way — if you've got a tip, a cleaner way to do something, or a tool worth adding, open an issue or send a PR. I'd rather hear about it than not.

- Bugs & site corrections: [open an issue](https://github.com/shcrypta27/TankScanOSint/issues)
- Tips, refactors, new tools: [send a PR](https://github.com/shcrypta27/TankScanOSint/pulls)

---

## Note

Only use this on systems you own or have permission to test. Scanning systems without permission is illegal in most countries.

---

## Disclaimer

Provided as-is, no warranty. I'm not responsible for what you do with it. You're the one on the hook for any laws you break.

By using TankScan you agree that:

1. You only target systems you own or have written permission to test.
2. You know that port scans, username lookups and WHOIS queries can be logged.
3. You take full responsibility for your actions.

If you're not sure whether you're allowed to scan something, don't.

---

## Author

shcrypta27 — [github.com/shcrypta27](https://github.com/shcrypta27)

MIT License.
