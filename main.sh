#!/bin/bash

# nHentai Downloader - CLI tool with WebP to PNG conversion support
# Author: [meicookies]
# Lightweight, modular, clean formatting.

BASE_URL="https://nhentai.net"

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

log() {
	local type="$1"
	local message="$2"
	local timestamp
	timestamp=$(date +"%H:%M:%S")

	local color_type
	case "$type" in
		INFO) color_type="${GREEN}[$type]${NC}" ;;
		WARNING) color_type="${YELLOW}[$type]${NC}" ;;
		ERROR) color_type="${RED}[$type]${NC}" ;;
		*) color_type="[$type]" ;;
	esac

	echo -e "${BLUE}[$timestamp]${NC} $color_type $message"
}

handle_CTRLC() {
	echo -e "\x0a"
	log "WARNING" "Interruption detected!"
	exit 1
}

handle_CTRLZ() {
	echo -e "\x0a"
	log "WARNING" "[!] Abort signal intercepted"
	exit 1
}

check_extension() {
	local URL="$1"
	echo "$URL" | grep -oP '\.[^.]+$'
}

image_fetcher() {
	curl -s "$BASE_URL/g/$1/$2/" \
		| grep -Po '(?<=<img src=")[^"]+\.(webp|jpg|jpeg|png)'
}

final_page() {
	curl -s "$BASE_URL/g/$1/" \
		| grep -oP '<span class="name">\K[0-9]+(?=</span>)'
}

snatch_nh() {
	local code="$1"
	local total_pages
	total_pages=$(final_page "$code")

	if [[ -z "$total_pages" ]]; then
		log "ERROR" "ERR_NOT_FOUND."
		return 1
	fi
	webp_count=0
	mkdir -p "$code"
	log "INFO" "Found $total_pages pages from $code"
	for ((page=1; page<=total_pages; page++)); do

		local image_url
		local image_ext
		image_url=$(image_fetcher "$code" "$page")
		image_ext=$(check_extension "$image_url")

		if [[ "$image_ext" == ".webp" ]]; then
			wget --quiet --show-progress "$image_url" -O "$page.webp"
			webp_count=$((webp_count + 1))

		elif [[ "$image_ext" =~ \.(jpg|jpeg|png)$ ]]; then
			wget --quiet --show-progress "$image_url" -O "$code/${page}${image_ext}"
		fi
	done
	if [[ $webp_count -ne 0 ]]; then
		for ((num=1; num<=$webp_count; num++)); do
			dwebp -quiet "$num.webp" -o "$code/$num.png"
			log "INFO" "Decoding $num.webp to $code/$num.png"
			rm "$num.webp"
		done		
	fi
	log "INFO" "All done successfully"
}
cat << "EOF"
⠄⠄⠄⢰⣧⣼⣯⠄⣸⣠⣶⣶⣦⣾⠄⠄⠄⠄⡀⠄⢀⣿⣿⠄⠄⠄⢸⡇⠄⠄
⠄⠄⠄⣾⣿⠿⠿⠶⠿⢿⣿⣿⣿⣿⣦⣤⣄⢀⡅⢠⣾⣛⡉⠄⠄⠄⠸⢀⣿⠄
⠄⠄⢀⡋⣡⣴⣶⣶⡀⠄⠄⠙⢿⣿⣿⣿⣿⣿⣴⣿⣿⣿⢃⣤⣄⣀⣥⣿⣿⠄
⠄⠄⢸⣇⠻⣿⣿⣿⣧⣀⢀⣠⡌⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⣿⣿⣿⠄
⠄⢀⢸⣿⣷⣤⣤⣤⣬⣙⣛⢿⣿⣿⣿⣿⣿⣿⡿⣿⣿⡍⠄⠄⢀⣤⣄⠉⠋⣰
⠄⣼⣖⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⢇⣿⣿⡷⠶⠶⢿⣿⣿⠇⢀⣤
⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣷⣶⣥⣴⣿⡗
⢀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠄
⢸⣿⣦⣌⣛⣻⣿⣿⣧⠙⠛⠛⡭⠅⠒⠦⠭⣭⡻⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠄
⠘⣿⣿⣿⣿⣿⣿⣿⣿⡆⠄⠄⠄⠄⠄⠄⠄⠄⠹⠈⢋⣽⣿⣿⣿⣿⣵⣾⠃⠄
⠄⠘⣿⣿⣿⣿⣿⣿⣿⣿⠄⣴⣿⣶⣄⠄⣴⣶⠄⢀⣾⣿⣿⣿⣿⣿⣿⠃⠄⠄
⠄⠄⠈⠻⣿⣿⣿⣿⣿⣿⡄⢻⣿⣿⣿⠄⣿⣿⡀⣾⣿⣿⣿⣿⣛⠛⠁⠄⠄⠄
⠄⠄⠄⠄⠈⠛⢿⣿⣿⣿⠁⠞⢿⣿⣿⡄⢿⣿⡇⣸⣿⣿⠿⠛⠁⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠉⠻⣿⣿⣾⣦⡙⠻⣷⣾⣿⠃⠿⠋⠁⠄⠄⠄⠄⠄⢀⣠⣴
⣿⣿⣿⣶⣶⣮⣥⣒⠲⢮⣝⡿⣿⣿⡆⣿⡿⠃⠄⠄⠄⠄⠄⠄⠄⣠⣴⣿⣿⣿ coded by ./meicookies
EOF
trap handle_CTRLC SIGINT
trap handle_CTRLZ SIGTSTP

echo -e "\n\t${YELLOW}nhentai-dl${NC}\n"
echo -e "${BLUE}nhentai.net downloader script\nRetrieves and stores doujinshi directly to local storage.${NC}\n"

read -rp "Input your doujin code: " code

if [[ "$code" =~ ^[0-9]+$ ]]; then
	snatch_nh "$code"
else
	log "WARNING" "Only numbers allowed (integer)."
fi
