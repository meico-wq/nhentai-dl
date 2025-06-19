#!/bin/bash

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

packages=(dwebp wget curl sed grep)

for pkg in "${packages[@]}"; do
	cmd="$pkg"
	[[ "$pkg" == "dwebp" ]] && cmd="libwebp"

	if command -v "$pkg" &>/dev/null; then
		echo -e "${GREEN}✓ $pkg is already installed${RESET}"
	else
		echo -e "${YELLOW}→ Installing $pkg...${RESET}"
		apt install -y "$cmd" &>/dev/null \
			&& echo -e "${GREEN}✓ $pkg installed successfully${RESET}" \
			|| echo -e "${RED}✗ failed to install $pkg${RESET}"
	fi
done
