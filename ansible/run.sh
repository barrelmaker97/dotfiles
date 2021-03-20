#!/bin/bash
RED='\e[1;31m'
GREEN='\e[1;32m'
RESET='\e[0m'

TICK="\\r[${GREEN}✓${RESET}]"
CROSS="\\r[${RED}✗${RESET}]"
INFO="\\r[i]"
DEPENDENCIES=(ansible)

check_dependencies ()
{
	echo -ne "${INFO} Checking for dependencies..."
	for DEPENDENCY in "${DEPENDENCIES[@]}"
	do
		command -v "${DEPENDENCY}" > /dev/null
		EXIT_CODE=$?
		if [ $EXIT_CODE -ne 0 ]; then
			echo -e "${CROSS} ${DEPENDENCY} is not installed or cannot be found on this system"
			exit $EXIT_CODE
		fi
	done
	echo -e "${TICK}"
}

check_dependencies
read -rp "IP: " IP
read -rp "Username (Default barrelmaker): " USERNAME
USERNAME=${USERNAME:-barrelmaker}
echo -e "Starting Deployment Playbook..."
echo server ansible_host="${IP}" ansible_user="${USERNAME}" > inventory_hostname
ansible-playbook kubesetup.yaml -i inventory_hostname -v
rm inventory_hostname
