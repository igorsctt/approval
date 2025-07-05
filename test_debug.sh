#!/bin/bash
# Test debug auth endpoint

echo "Testing debug auth endpoint..."

curl -X POST https://kaefer-approval-system.onrender.com/debug_auth \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=admin@kaefer.com&password=admin123" \
  -v

echo -e "\n\nTesting with curl JSON format..."

curl -X POST https://kaefer-approval-system.onrender.com/debug_auth \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@kaefer.com","password":"admin123"}' \
  -v
