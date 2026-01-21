#!/bin/bash

set -e -o pipefail

if [ -z "$1" ]; then
	echo "Give a name" >&2
	exit 1;
fi

if [ -d "$1" ]; then
	echo "$1 exists." >&2
	exit 1;
fi

hostname=$1

mkdir --mode=0755 -v "${hostname}"
mkdir --mode=0755 -v "${hostname}/build" "${hostname}/logs" "${hostname}/stats"
mkdir --mode=0700 -v "${hostname}/ssh" "${hostname}/gpg"

ssh-keygen -C "${hostname}" -t ed25519 -f "${hostname}/ssh/id_ed25519" -N ""

cat > "${hostname}/gpg/gpg.conf" <<EOF
personal-digest-preferences SHA512
primary-keyring pubring.gpg
EOF
touch "${hostname}/gpg/pubring.gpg" 
gpg --homedir "${hostname}/gpg" --batch --gen-key --cert-digest-algo SHA256 <<EOF
%echo Generating key for ${hostname} ...
%no-protection
Key-Type: RSA
Key-Usage: sign
Key-Length: 4096
Name-Real: buildd autosigning key ${hostname}
Name-Email: buildd_loong64-${hostname}@buildd.debian.org
Expire-Date: 365d
%commit
EOF

ssh-keyscan deb.internal.apernet.io buildd.internal.apernet.io > "${hostname}/ssh/known_hosts" || true

gpg --homedir "${hostname}/gpg" --export --armor

echo
keyid="0x$(
gpg --homedir "${hostname}/gpg" --list-secret-keys --keyid-format=long --with-colons  | \
  grep "^sec:" | cut -d ":" -f 5
)"
echo "group builders add $keyid"
echo "no-agent-forwarding,no-port-forwarding,no-pty,no-X11-forwarding,command=\"/home/uploader/rsync-ssh-wrap ${hostname}\" $(cat "${hostname}/ssh/id_ed25519.pub")"

echo 
echo "no-agent-forwarding,no-port-forwarding,no-pty,no-X11-forwarding,command=\"/srv/wanna-build/bin/wanna-build --ssh-wrapper ${hostname}\" $(cat "${hostname}/ssh/id_ed25519.pub")"
cat <<EOF
- ${hostname}:
  - architecture: loong64
EOF

gpgconf --homedir "${hostname}/gpg"  --kill all

chown -R 1000:1000 "${hostname}"
