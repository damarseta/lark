#!/bin/bash
set -euo pipefail

# Variables
DOMAIN="yourdomain.com"   # Replace with your domain
CERT_DIR="/etc/nginx/ssl" # Directory to store the SSL certificate and key
CERT_KEY="$CERT_DIR/$DOMAIN.key"
CERT_CRT="$CERT_DIR/$DOMAIN.crt"
DAYS_VALID=365 # Number of days the certificate is valid

# Create the directory to store the SSL certificate and key if it doesn't exist
mkdir -p "$CERT_DIR"

# Generate the SSL certificate
openssl req -x509 -nodes -days "$DAYS_VALID" -newkey rsa:2048 \
  -keyout "$CERT_KEY" \
  -out "$CERT_CRT" \
  -subj "/CN=$DOMAIN"

# Output information
if [ $? -eq 0 ]; then
  echo "Self-signed SSL certificate generated successfully."
  echo "Key: $CERT_KEY"
  echo "Cert: $CERT_CRT"
else
  echo "Failed to generate SSL certificate."
  exit 1
fi
