#!/bin/bash

set -e

#############################################################################
#                                                                           #
# JSKI-FLEX-INSTALLER                                                       #
#                                                                           #
# Copyright (C)2022, JSKI,                                                  #
#                                                                           #
#                                                                           #
#                                                                           #
#############################################################################

SCRIPT_VERSION="v.0.2"
GITHUB_BASE_URL="https://raw.githubusercontent.com/jskiweb/flex-installer"

LOG_PATH="/var/log/flex-installer.log"

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives)"
  exit 1
fi

output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

execute() {
  echo -e "\n\n* flex-installer $(date) \n\n" >> $LOG_PATH

  bash <(curl -s "$1") | tee -a $LOG_PATH
  [[ -n $2 ]] && execute "$2"
}

done=false

output "
JSKI FLEX-INSTALLER"
output
output "Copyright (C) 22, JSKI,"
output 'ONLY DEBIAN AND UBUNTU ARE SUPPORTED!'
output "No Support"
output "This script is not associated with any of the listed Projects"

JAVA="$GITHUB_BASE_URL/$SCRIPT_VERSION/source/java.sh"

NGINX="$GITHUB_BASE_URL/$SCRIPT_VERSION/source/nginx.sh"

APACHE2="$GITHUB_BASE_URL/$SCRIPT_VERSION/source/apache2.sh"

NJSNPM="$GITHUB_BASE_URL/$SCRIPT_VERSION/source/njsnpm.sh"

WIREGUARD="$GITHUB_BASE_URL/$SCRIPT_VERSION/source/wireguard.sh"

while [ "$done" == false ]; do
  options=(
    "Java"
    "Nginx"
    "Apache2"
    "NodeJS+NPM"
    "Wireguard"
  )

  actions=(
    "$JAVA"
    "$NGINX"
    "$APACHE2"
    "$NJSNPM"
    "$WIREGUARD"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<< "${actions[$action]}" && execute "$i1" "$i2"
done
