#!/usr/bin/env bash

set -e

if ! command -v mkcert >/dev/null 2>&1; then
    echo "ERROR: mkcert is not installed."
    echo "Please install mkcert to generate trusted local SSL certificates."
    echo "Installation instructions:"
    echo "  macOS:  brew install mkcert nss"
    echo "  Ubuntu/Debian:  sudo apt install mkcert libnss3-tools"
    echo "  Windows (choco): choco install mkcert"
    echo "For more details, visit: https://github.com/FiloSottile/mkcert"
    exit 1
fi

echo "mkcert found. Provisioning local SSL certificates..."

mkcert -install

mkdir -p ./certs/

mkcert -cert-file ./certs/localhost.pem -key-file ./certs/localhost-key.pem localhost 127.0.0.1 ::1

echo "Certificates successfully generated in ./certs/"
