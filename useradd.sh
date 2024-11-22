#!/bin/bash

# Check if the script is run as root
if [[ "${UID}" -ne 0 ]]; then
    echo 'Please run with sudo or as root'
    exit 1
fi

# Ensure at least one argument (username) is provided
if [[ "${#}" -lt 1 ]]; then
    echo "Usage: ${0} USER_NAME [COMMENT]..."
    echo 'Create a user with USER_NAME and optionally add a COMMENT.'
    exit 1
fi


# Store the first argument as the username
USER_NAME="${1}"

# Shift to get the rest of the arguments as comments
shift
COMMENT="${@}"

# Generate a password
PASSWORD=$(date +%s%N | sha256sum | head -c12)

# Create the user
useradd -c "${COMMENT}" -m "${USER_NAME}"

# Check if the user was successfully created
if [[ "${?}" -ne 0 ]]; then
    echo 'The account could not be created.'
    exit 1
fi

# Set the password for the user
echo "${USER_NAME}:${PASSWORD}" | chpasswd

# Check if the password was successfully set
if [[ "${?}" -ne 0 ]]; then
    echo 'The password could not be set.'
    exit 1
fi

# Force the user to change their password on first login
passwd -e "${USER_NAME}"

# Display the username, password, and hostname
echo
echo "Username: ${USER_NAME}"
echo "Password: ${PASSWORD}"
echo "Host: $(hostname)"

