#!/bin/bash

# ==========================================================
#  TankScan - OSINT Tool
#  coded by shcrypta27
#  https://github.com/shcrypta27
# ==========================================================

RED='\033[0;31m'
ORANGE='\033[0;33m'
WHITE='\033[0;37m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ---------- Banner ----------
show_banner() {
    echo -e "${RED}"
    cat << "EOF"
 dMMMMMMP .aMMMb  dMMMMb  dMP dMP .dMMMb  .aMMMb  .aMMMb  dMMMMb                    .-----,____________     _                                    
   dMP   dMP"dMP dMP dMP dMP.dMP dMP" VP dMP"VMP dMP"dMP dMP dMP                  __l_____l------------    '-'                                     
  dMP   dMMMMMP dMP dMP dMMMMK"  VMMMb  dMP     dMMMMMP dMP dMP                 _/__________\_                                        
 dMP   dMP dMP dMP dMP dMP"AMF dP .dMP dMP.aMP dMP dMP dMP dMP                 /______________\                                    
dMP   dMP dMP dMP dMP dMP dMP  VMMMP"  VMMMP" dMP dMP dMP dMP                  ',(o)(o)(o)(o),'                             
EOF
    echo -e "${NC}"
    echo -e "        ${WHITE}coded by ${MAGENTA}shcrypta27${NC}  ${DIM}•${NC}  ${CYAN}https://github.com/shcrypta27${NC}"
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ---------- Menu ----------
show_menu() {
    echo -e "  ${ORANGE}[1]${NC} ${WHITE}Username Lookup ${DIM}(250+ sites)${NC}"
    echo -e "  ${ORANGE}[2]${NC} ${WHITE}Email Recon${NC}"
    echo -e "  ${ORANGE}[3]${NC} ${WHITE}Domain Info${NC}"
    echo -e "  ${ORANGE}[4]${NC} ${WHITE}IP Geolocation${NC}"
    echo -e "  ${ORANGE}[5]${NC} ${WHITE}Phone Number Lookup${NC}"
    echo -e "  ${ORANGE}[6]${NC} ${WHITE}WHOIS Lookup${NC}"
    echo -e "  ${ORANGE}[7]${NC} ${WHITE}DNS Records${NC}"
    echo -e "  ${ORANGE}[8]${NC} ${WHITE}Port Scan ${DIM}(nmap)${NC}"
    echo -e "  ${ORANGE}[0]${NC} ${WHITE}Exit${NC}"
    echo ""
}

# ==========================================================
#  UI HELPERS
# ==========================================================
spinner() {
    local msg="$1"; shift
    local out; out=$(mktemp)
    "$@" > "$out" 2>&1 &
    local pid=$!
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r  ${CYAN}${spin:$i:1}${NC}  ${WHITE}%s${NC}    " "$msg"
        sleep 0.08
    done
    wait "$pid"; local rc=$?
    printf "\r  ${GREEN}✔${NC}  ${WHITE}%s${NC}    \n" "$msg"
    cat "$out"; rm -f "$out"
    return $rc
}

loading_bar() {
    local msg="$1"
    local dur="${2:-1.0}"
    local steps=36
    local delay; delay=$(awk "BEGIN{print $dur/$steps}")
    for ((i=0; i<=steps; i++)); do
        local bar="" b=""
        for ((j=0; j<i; j++)); do bar+="█"; done
        for ((j=0; j<steps-i; j++)); do bar+="░"; done
        local pct=$(( i * 100 / steps ))
        printf "\r  ${ORANGE}[${GREEN}%s${ORANGE}]${NC} ${WHITE}%3d%%${NC}  ${DIM}%s${NC}  " "$bar" "$pct" "$msg"
        sleep "$delay"
    done
    printf "\n"
}

draw_progress() {
    local current=$1 total=$2 label="$3"
    local width=40
    [ "$total" -eq 0 ] && total=1
    [ "$current" -gt "$total" ] && current=$total
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local pct=$(( current * 100 / total ))
    local bar=""
    for ((j=0; j<filled; j++)); do bar+="█"; done
    for ((j=0; j<empty;  j++)); do bar+="░"; done
    printf "\r  ${ORANGE}[${GREEN}%s${ORANGE}]${NC} ${WHITE}%3d%%${NC}  ${DIM}%s  %d/%d${NC}    " \
           "$bar" "$pct" "$label" "$current" "$total"
}

# ==========================================================
#  SITE LIST
# ==========================================================
read -r -d '' SITES <<'EOF'
GitHub|https://github.com/USER
GitLab|https://gitlab.com/USER
Bitbucket|https://bitbucket.org/USER
SourceForge|https://sourceforge.net/u/USER
StackOverflow|https://stackoverflow.com/users/USER
CodePen|https://codepen.io/USER
JSFiddle|https://jsfiddle.net/user/USER
Replit|https://replit.com/@USER
Glitch|https://glitch.com/@USER
CodeSandbox|https://codesandbox.io/u/USER
HackerRank|https://hackerrank.com/USER
LeetCode|https://leetcode.com/USER
Codeforces|https://codeforces.com/profile/USER
TopCoder|https://topcoder.com/members/USER
NPM|https://npmjs.com/~USER
PyPI|https://pypi.org/user/USER
Crates|https://crates.io/users/USER
RubyGems|https://rubygems.org/profiles/USER
Packagist|https://packagist.org/users/USER
DockerHub|https://hub.docker.com/u/USER
DevTo|https://dev.to/USER
Hashnode|https://hashnode.com/@USER
Medium|https://medium.com/@USER
HackerNoon|https://hackernoon.com/u/USER
freeCodeCamp|https://freecodecamp.org/USER
Exercism|https://exercism.io/profiles/USER
Kaggle|https://kaggle.com/USER
HuggingFace|https://huggingface.co/USER
StackExchange|https://stackexchange.com/users/USER
Sourcegraph|https://sourcegraph.com/users/USER
Twitter|https://twitter.com/USER
X|https://x.com/USER
Instagram|https://instagram.com/USER
Facebook|https://facebook.com/USER
Reddit|https://reddit.com/user/USER
TikTok|https://tiktok.com/@USER
Snapchat|https://snapchat.com/add/USER
Pinterest|https://pinterest.com/USER
Tumblr|https://USER.tumblr.com
LinkedIn|https://linkedin.com/in/USER
VK|https://vk.com/USER
Weibo|https://weibo.com/USER
Mastodon|https://mastodon.social/@USER
Threads|https://threads.net/@USER
Bluesky|https://bsky.app/profile/USER
Gab|https://gab.com/USER
Minds|https://minds.com/USER
MeWe|https://mewe.com/i/USER
Vero|https://vero.co/USER
WeHeartIt|https://weheartit.com/USER
Flickr|https://flickr.com/people/USER
500px|https://500px.com/p/USER
Unsplash|https://unsplash.com/@USER
VSCO|https://vsco.co/USER
EyeEm|https://eyeem.com/u/USER
Imgur|https://imgur.com/user/USER
Giphy|https://giphy.com/USER
Tenor|https://tenor.com/users/USER
9GAG|https://9gag.com/u/USER
DeviantArt|https://deviantart.com/USER
Behance|https://behance.net/USER
Dribbble|https://dribbble.com/USER
ArtStation|https://artstation.com/USER
Pixiv|https://pixiv.net/users/USER
FurAffinity|https://furaffinity.net/user/USER
Newgrounds|https://USER.newgrounds.com
Sketchfab|https://sketchfab.com/USER
YouTube|https://youtube.com/@USER
Vimeo|https://vimeo.com/USER
Dailymotion|https://dailymotion.com/USER
BitChute|https://bitchute.com/channel/USER
Odysee|https://odysee.com/@USER
Rumble|https://rumble.com/user/USER
Twitch|https://twitch.tv/USER
Kick|https://kick.com/USER
Trovo|https://trovo.live/USER
Steam|https://steamcommunity.com/id/USER
Xbox|https://xboxgamertag.com/search/USER
PlayStation|https://psnprofiles.com/USER
Roblox|https://roblox.com/users/profile?username=USER
Minecraft|https://namemc.com/profile/USER
EpicGames|https://fortnitetracker.com/profile/all/USER
BattleNet|https://overwatch.blizzard.com/en-us/search/?q=USER
OSU|https://osu.ppy.sh/users/USER
Chess|https://chess.com/member/USER
Lichess|https://lichess.org/@/USER
Faceit|https://faceit.com/en/players/USER
ESEA|https://play.esea.net/users/USER
Discord|https://discord.com/users/USER
Spotify|https://open.spotify.com/user/USER
SoundCloud|https://soundcloud.com/USER
Bandcamp|https://USER.bandcamp.com
LastFM|https://last.fm/user/USER
Audiomack|https://audiomack.com/USER
Mixcloud|https://mixcloud.com/USER
Deezer|https://deezer.com/en/profile/USER
Tidal|https://tidal.com/USER
Pandora|https://pandora.com/profile/USER
Genius|https://genius.com/USER
WordPress|https://USER.wordpress.com
Blogger|https://USER.blogspot.com
Substack|https://USER.substack.com
Ghost|https://USER.ghost.io
Write.as|https://write.as/USER
TelegraPh|https://telegra.ph/USER
Wix|https://USER.wixsite.com/USER
Weebly|https://USER.weebly.com
Squarespace|https://USER.squarespace.com
Goodreads|https://goodreads.com/USER
Letterboxd|https://letterboxd.com/USER
MyAnimeList|https://myanimelist.net/profile/USER
AniList|https://anilist.co/user/USER
Trakt|https://trakt.tv/users/USER
Simkl|https://simkl.com/USER
IMDb|https://imdb.com/user/urUSER
Strava|https://strava.com/athletes/USER
MyFitnessPal|https://myfitnesspal.com/profile/USER
Nike|https://nike.com/member/USER
Garmin|https://connect.garmin.com/modern/profile/USER
Fitbit|https://fitbit.com/user/USER
Peloton|https://onepeloton.com/member/USER
MapMyRun|https://mapmyrun.com/profile/USER
Venmo|https://venmo.com/u/USER
CashApp|https://cash.app/$USER
PayPal|https://paypal.me/USER
KoFi|https://ko-fi.com/USER
BuyMeACoffee|https://buymeacoffee.com/USER
Patreon|https://patreon.com/USER
OnlyFans|https://onlyfans.com/USER
Gumroad|https://USER.gumroad.com
Etsy|https://etsy.com/shop/USER
eBay|https://ebay.com/usr/USER
Poshmark|https://poshmark.com/closet/USER
Depop|https://depop.com/USER
Vinted|https://vinted.com/member/USER
Mercari|https://mercari.com/u/USER
Grailed|https://grailed.com/USER
Reverb|https://reverb.com/shop/USER
Discogs|https://discogs.com/user/USER
OKCupid|https://okcupid.com/profile/USER
Bumble|https://bumble.com/en/
PoF|https://pof.com/user/USER
Match|https://match.com/profile/USER
Quora|https://quora.com/profile/USER
HackerNews|https://news.ycombinator.com/user?id=USER
Lobsters|https://lobste.rs/~USER
V2EX|https://v2ex.com/member/USER
Slashdot|https://slashdot.org/~USER
Digg|https://digg.com/@USER
ProductHunt|https://producthunt.com/@USER
AngelList|https://angel.co/u/USER
Crunchbase|https://crunchbase.com/person/USER
AboutMe|https://about.me/USER
Gravatar|https://gravatar.com/USER
Keybase|https://keybase.io/USER
Telegram|https://t.me/USER
Pastebin|https://pastebin.com/u/USER
Hastebin|https://hastebin.com/USER
Rentry|https://rentry.co/USER
Notion|https://notion.so/USER
Carrd|https://USER.carrd.co
Linktree|https://linktr.ee/USER
BioLink|https://bio.link/USER
Beacons|https://beacons.ai/USER
SoloTo|https://solo.to/USER
AllMyLinks|https://allmylinks.com/USER
Bento|https://bento.me/USER
Taplink|https://taplink.cc/USER
Campsite|https://campsite.bio/USER
Wattpad|https://wattpad.com/user/USER
FanFiction|https://fanfiction.net/u/USER
ArchiveOfOurOwn|https://archiveofourown.org/users/USER
RoyalRoad|https://royalroad.com/profile/USER
Scribd|https://scribd.com/USER
SlideShare|https://slideshare.net/USER
Academia|https://independent.academia.edu/USER
ResearchGate|https://researchgate.net/profile/USER
ORCID|https://orcid.org/USER
GoogleScholar|https://scholar.google.com/citations?user=USER
Zotero|https://zotero.org/USER
Mendeley|https://mendeley.com/profiles/USER
PeerJ|https://peerj.com/USER
Figshare|https://figshare.com/authors/USER
Zenodo|https://zenodo.org/search?q=USER
Ravelry|https://ravelry.com/people/USER
Instructables|https://instructables.com/member/USER
Hackaday|https://hackaday.io/USER
Hackster|https://hackster.io/USER
Thingiverse|https://thingiverse.com/USER
Printables|https://printables.com/@USER
Cults3D|https://cults3d.com/en/users/USER
MyMiniFactory|https://myminifactory.com/users/USER
CGTrader|https://cgtrader.com/USER
TurboSquid|https://turbosquid.com/Search/Artists/USER
Pexels|https://pexels.com/@USER
Pixabay|https://pixabay.com/users/USER
Freepik|https://freepik.com/USER
Shutterstock|https://shutterstock.com/g/USER
AdobeStock|https://stock.adobe.com/contributor/USER
Envato|https://envato.com/user/USER
CreativeMarket|https://creativemarket.com/USER
Fiverr|https://fiverr.com/USER
Upwork|https://upwork.com/freelancers/USER
Freelancer|https://freelancer.com/u/USER
PeoplePerHour|https://peopleperhour.com/freelancer/USER
Toptal|https://toptal.com/resume/USER
Codementor|https://codementor.io/@USER
Airbnb|https://airbnb.com/users/show/USER
Couchsurfing|https://couchsurfing.com/people/USER
Warmshowers|https://warmshowers.org/user/USER
BlaBlaCar|https://blablacar.com/member/USER
Yelp|https://USER.yelp.com
Foursquare|https://foursquare.com/USER
TripAdvisor|https://tripadvisor.com/members/USER
Zomato|https://zomato.com/user/USER
AllRecipes|https://allrecipes.com/cook/USER
Habbo|https://habbo.com/home/USER
Neopets|https://neopets.com/userlookup.phtml?user=USER
IMVU|https://imvu.com/next/av/USER
SecondLife|https://my.secondlife.com/USER
VRchat|https://vrchat.com/home/user/USER
RecRoom|https://rec.net/user/USER
Houseparty|https://houseparty.com/user/USER
Clubhouse|https://clubhouse.com/@USER
Spoon|https://spooncast.net/USER
Yubo|https://yubo.live/USER
YikYak|https://yikyak.com/user/USER
Tellonym|https://tellonym.me/USER
ASKfm|https://ask.fm/USER
CuriousCat|https://curiouscat.me/USER
Retrospring|https://retrospring.net/@USER
EOF

# ==========================================================
#  SCAN FUNCTIONS
# ==========================================================

# ---------- 1. Username Lookup ----------
username_lookup() {
    read -p "  Enter username > " user
    [ -z "$user" ] && return

    echo ""
    echo -e "${CYAN}━━━ Username Scan ━━━${NC}  ${BOLD}${WHITE}$user${NC}"
    echo ""

    local total
    total=$(echo "$SITES" | grep -c .)
    local tmp counter lock
    tmp=$(mktemp); counter=$(mktemp); lock=$(mktemp)
    echo "0" > "$counter"

    check_one() {
        local entry="$1" user="$2" outfile="$3" counter="$4" lock="$5"
        local name="${entry%%|*}"
        local url="${entry#*|}"
        local target="${url//USER/$user}"
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 8 \
               -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
               "$target")
        if [ "$code" = "200" ]; then
            printf "\033[0;32m[+]\033[0m %-22s \033[2m%s\033[0m\n" "$name" "$target" >> "$outfile"
        elif [ "$code" = "301" ] || [ "$code" = "302" ]; then
            printf "\033[0;33m[~]\033[0m %-22s \033[2m%s\033[0m\n" "$name" "$target" >> "$outfile"
        fi
        flock "$lock" bash -c "c=\$(cat '$counter'); echo \$((c+1)) > '$counter'"
    }
    export -f check_one

    echo "$SITES" | grep . | xargs -d '\n' -I {} -P 40 \
        bash -c 'check_one "$@"' _ "{}" "$user" "$tmp" "$counter" "$lock" &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local cur
        cur=$(cat "$counter" 2>/dev/null || echo 0)
        draw_progress "$cur" "$total" "Scanning sites"
        sleep 0.15
    done
    wait "$pid"
    draw_progress "$total" "$total" "Scanning sites"
    printf "\n\n"

    local hits=0 redirects=0
    if [ -s "$tmp" ]; then
        sort "$tmp"
        hits=$(grep -c "\[+\]" "$tmp" 2>/dev/null || echo 0)
        redirects=$(grep -c "\[~\]" "$tmp" 2>/dev/null || echo 0)
    else
        echo -e "  ${RED}No matches found.${NC}"
    fi
    rm -f "$tmp" "$counter" "$lock"

    echo ""
    echo -e "${DIM}─── Summary ───${NC}"
    echo -e "  ${GREEN}● Confirmed:${NC} $hits    ${ORANGE}● Redirects:${NC} $redirects    ${DIM}● Total:${NC} $total"
}

# ---------- 2. Email Recon ----------
email_recon() {
    read -p "  Enter email > " email
    [ -z "$email" ] && return
    local domain="${email#*@}"
    echo ""
    echo -e "${CYAN}━━━ Email Recon ━━━${NC}  ${BOLD}${WHITE}$email${NC}"
    echo ""
    echo -e "${WHITE}▸ MX Records${NC}"
    spinner "Looking up MX records" dig +short MX "$domain"
    echo ""
    echo -e "${WHITE}▸ Breach Check (HaveIBeenPwned)${NC}"
    local hibp_out; hibp_out=$(mktemp)
    curl -s --max-time 12 \
        "https://haveibeenpwned.com/api/v3/breachedaccount/$email?truncateResponse=true" \
        -H "User-Agent: TankScan-OSINT" > "$hibp_out" &
    local pid=$!
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'; local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r  ${CYAN}${spin:$i:1}${NC}  ${WHITE}Querying breach database${NC}    "
        sleep 0.08
    done
    wait "$pid"
    printf "\r  ${GREEN}✔${NC}  ${WHITE}Querying breach database${NC}    \n"
    if [ -s "$hibp_out" ]; then
        cat "$hibp_out" | (command -v jq >/dev/null && jq . || cat)
    else
        echo -e "  ${DIM}No public breaches found (or HIBP API key required).${NC}"
    fi
    rm -f "$hibp_out"
}

# ---------- 3. Domain Info ----------
domain_info() {
    read -p "  Enter domain > " domain
    [ -z "$domain" ] && return
    echo ""
    echo -e "${CYAN}━━━ Domain Info ━━━${NC}  ${BOLD}${WHITE}$domain${NC}"
    echo ""
    echo -e "${WHITE}▸ A Records${NC}"
    spinner "Resolving A records" dig +short A "$domain"
    echo ""
    echo -e "${WHITE}▸ NS Records${NC}"
    spinner "Fetching NS records" dig +short NS "$domain"
    echo ""
    echo -e "${WHITE}▸ WHOIS Summary${NC}"
    if command -v whois >/dev/null 2>&1; then
        local who_out; who_out=$(mktemp)
        whois "$domain" > "$who_out" 2>/dev/null &
        local pid=$!
        local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'; local i=0
        while kill -0 "$pid" 2>/dev/null; do
            i=$(( (i+1) % ${#spin} ))
            printf "\r  ${CYAN}${spin:$i:1}${NC}  ${WHITE}Querying WHOIS server${NC}    "
            sleep 0.08
        done
        wait "$pid"
        printf "\r  ${GREEN}✔${NC}  ${WHITE}Querying WHOIS server${NC}    \n"
        grep -iE "registrar:|creation date|expiry|expiration|updated date|name server" "$who_out" | head -20 \
            || echo -e "  ${DIM}(no summary fields)${NC}"
        rm -f "$who_out"
    else
        echo -e "  ${RED}[!] whois not installed${NC} (sudo apt install whois)"
    fi
}

# ---------- 4. IP Geolocation ----------
ip_geo() {
    read -p "  Enter IP or domain > " ip
    [ -z "$ip" ] && return
    echo ""
    echo -e "${CYAN}━━━ IP Geolocation ━━━${NC}  ${BOLD}${WHITE}$ip${NC}"
    echo ""
    loading_bar "Contacting ip-api.com" 0.6
    local data
    data=$(curl -s --max-time 10 \
        "http://ip-api.com/json/$ip?fields=status,message,country,regionName,city,zip,lat,lon,timezone,isp,org,as,query")
    echo ""
    if command -v jq >/dev/null 2>&1; then
        echo "$data" | jq .
    else
        echo "$data"
        echo ""
        echo -e "  ${DIM}[i] Install jq for pretty output: sudo apt install jq${NC}"
    fi
}

# ---------- 5. Phone Number Lookup ----------
phone_lookup() {
    read -p "  Enter phone (with country code, e.g. +14155552671) > " phone
    [ -z "$phone" ] && return
    echo ""
    echo -e "${CYAN}━━━ Phone Analysis ━━━${NC}  ${BOLD}${WHITE}$phone${NC}"
    echo ""
    loading_bar "Parsing number" 0.5
    local digits
    digits=$(echo "$phone" | tr -cd '0-9')
    echo ""
    echo -e "${WHITE}▸ Basic${NC}"
    echo "  Digits : $digits"
    echo "  Length : ${#digits}"
    echo ""
    echo -e "${WHITE}▸ Country Code Cheat-Sheet${NC}"
    echo "  1 = US/CA | 44 = UK | 91 = IN | 49 = DE | 33 = FR"
    echo "  81 = JP   | 86 = CN | 7  = RU | 55 = BR | 61 = AU"
    echo ""
    if command -v phoneinfoga >/dev/null 2>&1; then
        echo -e "${WHITE}▸ PhoneInfoga Scan${NC}"
        spinner "Running phoneinfoga" phoneinfoga scan -n "$phone"
    else
        echo -e "  ${DIM}[i] Install phoneinfoga for deeper scans:${NC}"
        echo -e "  ${DIM}    https://github.com/sundowndev/phoneinfoga${NC}"
    fi
}

# ---------- 6. WHOIS Lookup ----------
whois_lookup() {
    read -p "  Enter domain or IP > " target
    [ -z "$target" ] && return
    echo ""
    echo -e "${CYAN}━━━ WHOIS ━━━${NC}  ${BOLD}${WHITE}$target${NC}"
    echo ""
    if command -v whois >/dev/null 2>&1; then
        spinner "Querying WHOIS" whois "$target"
    else
        echo -e "  ${RED}[!] whois not installed.${NC} Run: sudo apt install whois"
    fi
}

# ---------- 7. DNS Records ----------
dns_records() {
    read -p "  Enter domain > " domain
    [ -z "$domain" ] && return
    echo ""
    echo -e "${CYAN}━━━ DNS Records ━━━${NC}  ${BOLD}${WHITE}$domain${NC}"
    echo ""
    local types=(A AAAA MX NS TXT CNAME SOA)
    local total=${#types[@]}
    local i=0
    for type in "${types[@]}"; do
        i=$((i+1))
        draw_progress "$i" "$total" "Querying $type records"
        local out; out=$(dig +short "$type" "$domain" 2>/dev/null)
        sleep 0.25
        printf "\r"
        echo -e "${WHITE}▸ $type${NC}"
        if [ -z "$out" ]; then
            echo -e "  ${DIM}(none)${NC}"
        else
            echo "$out" | sed 's/^/  /'
        fi
        echo ""
    done
}

# ---------- 8. Port Scan (nmap) ----------
port_scan() {
    # Flag definitions
    local names=(  "-sn"  "-sS"  "-p-"  "-p"  "-sV"  "-sC"  "-o"  "-Pn"  "-F"  "-D"  "-T5"  "-v"  "-oA"  "-A"  "-sN"  "-sT" )
    local descs=(
        "Ping scan (no port scan)"
        "SYN stealth scan (needs root)"
        "Scan all 65535 ports"
        "Specific ports"
        "Service/version detection"
        "Run default NSE scripts"
        "Normal output to file (-oN)"
        "Skip host discovery"
        "Fast scan (top 100 ports)"
        "Decoy scan"
        "Insane timing template"
        "Verbose output"
        "Output in all formats (-oA)"
        "Aggressive scan (OS+ver+scripts+trace)"
        "TCP NULL scan (needs root)"
        "TCP connect scan"
    )
    local needs=(
        "" "" "" "ports (e.g. 22,80,443 or 1-1000)" "" "" "filename" "" "" \
        "decoys (e.g. RND:10 or 1.2.3.4,5.6.7.8)" "" "" "basename" "" "" ""
    )
    local n=${#names[@]}
    local -a en vals
    for ((i=0;i<n;i++)); do en[$i]=0; vals[$i]=""; done

    while true; do
        clear
        show_banner
        echo -e "${CYAN}━━━ Port Scan Configuration ━━━${NC}   ${DIM}(nmap)${NC}"
        echo ""

        # Two-column layout for compactness
        for ((i=0;i<n;i+=2)); do
            printf_column() {
                local idx=$1
                local mark=" " col="$DIM"
                [ "${en[$idx]}" = "1" ] && { mark="✔"; col="$GREEN"; }
                local line
                line=$(printf "${col}[%2d] %s${NC} ${BOLD}%-6s${NC} ${WHITE}%s${NC}" \
                    $((idx+1)) "$mark" "${names[$idx]}" "${descs[$idx]}")
                if [ "${en[$idx]}" = "1" ] && [ -n "${vals[$idx]}" ]; then
                    line+=$(printf " ${MAGENTA}→ %s${NC}" "${vals[$idx]}")
                fi
                printf "  %-72b" "$line"
            }
            printf_column $i
            if [ $((i+1)) -lt "$n" ]; then printf_column $((i+1)); fi
            echo ""
        done

        echo ""
        echo -e "  ${ORANGE}[r]${NC} ${WHITE}Run scan${NC}    ${ORANGE}[c]${NC} ${WHITE}Clear${NC}    ${ORANGE}[b]${NC} ${WHITE}Back${NC}"
        echo ""
        read -p "  Toggle option / action > " opt

        case "$opt" in
            r|R)
                local any=0
                for ((i=0;i<n;i++)); do [ "${en[$i]}" = "1" ] && any=1; done
                if [ "$any" = "0" ]; then
                    echo -e "  ${RED}[!] Select at least one option first.${NC}"
                    read -p "  Press Enter..."
                    continue
                fi
                if ! command -v nmap >/dev/null 2>&1; then
                    echo -e "  ${RED}[!] nmap not installed.${NC} Run: sudo apt install nmap"
                    read -p "  Press Enter..."
                    continue
                fi
                read -p "  Enter target (IP, hostname, or CIDR) > " target
                [ -z "$target" ] && continue

                # Build nmap command
                local -a cmd
                cmd=(nmap)
                for ((i=0;i<n;i++)); do
                    if [ "${en[$i]}" = "1" ]; then
                        local flag="${names[$i]}"
                        [ "$flag" = "-o" ] && flag="-oN"
                        cmd+=("$flag")
                        [ -n "${vals[$i]}" ] && cmd+=("${vals[$i]}")
                    fi
                done
                cmd+=("$target")

                echo ""
                echo -e "${CYAN}━━━ Command ━━━${NC}"
                echo -e "  ${DIM}\$ ${cmd[*]}${NC}"
                echo ""
                loading_bar "Launching nmap" 0.4
                echo ""
                echo -e "${CYAN}━━━ Result ━━━${NC}"
                echo ""
                "${cmd[@]}"
                echo ""
                read -p "  Press Enter to return..."
                ;;
            c|C)
                for ((i=0;i<n;i++)); do en[$i]=0; vals[$i]=""; done
                ;;
            b|B) return ;;
            *)
                if [[ "$opt" =~ ^[0-9]+$ ]] && [ "$opt" -ge 1 ] && [ "$opt" -le "$n" ]; then
                    local idx=$((opt-1))
                    if [ "${en[$idx]}" = "1" ]; then
                        en[$idx]=0; vals[$idx]=""
                    else
                        en[$idx]=1
                        if [ -n "${needs[$idx]}" ]; then
                            read -p "  ${names[$idx]} requires ${needs[$idx]} > " v
                            vals[$idx]="$v"
                        fi
                    fi
                fi
                ;;
        esac
    done
}

# ==========================================================
#  MAIN LOOP
# ==========================================================
clear
show_banner
show_menu

while true; do
    read -p "  Select an option > " choice
    echo ""
    case $choice in
        1) username_lookup ;;
        2) email_recon ;;
        3) domain_info ;;
        4) ip_geo ;;
        5) phone_lookup ;;
        6) whois_lookup ;;
        7) dns_records ;;
        8) port_scan ;;
        0) echo -e "${RED}  Exiting TankScan...${NC}"; exit 0 ;;
        *) echo -e "${RED}  [!] Invalid option${NC}" ;;
    esac
    echo ""
    read -p "  Press Enter to return to menu..."
    clear
    show_banner
    show_menu
done
