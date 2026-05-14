#!/bin/bash

BASE_URL="http://localhost:3000"

echo "Generating test events..."

# Gate Access Success (5x) - pakai gate yang valid
for i in {1..5}; do
  curl -s -X POST "$BASE_URL/gate/access" \
    -H "Content-Type: application/json" \
    -d "{\"player_id\":\"P000$i\",\"player_name\":\"Player$i\",\"linked_gate\":\"CHUNITHM\"}" > /dev/null
done
echo "Gate Access Success: done"

# Gate Unlock Failed (5x) - condition_met tidak dikirim
for i in {1..5}; do
  curl -s -X POST "$BASE_URL/gate/unlock" \
    -H "Content-Type: application/json" \
    -d "{\"player_id\":\"P000$i\",\"player_name\":\"Player$i\",\"linked_gate\":\"AIR\"}" > /dev/null
done
echo "Gate Unlock Failed: done"

# Challenge Start (5x)
for i in {1..5}; do
  curl -s -X POST "$BASE_URL/challenge/start" \
    -H "Content-Type: application/json" \
    -d "{\"player_id\":\"P000$i\",\"player_name\":\"Player$i\",\"linked_gate\":\"STAR\"}" > /dev/null
done
echo "Challenge Start: done"

# Challenge Clear (5x) - cleared: true
for i in {1..5}; do
  curl -s -X POST "$BASE_URL/challenge/result" \
    -H "Content-Type: application/json" \
    -d "{\"player_id\":\"P000$i\",\"player_name\":\"Player$i\",\"linked_gate\":\"AMAZON\",\"cleared\":true}" > /dev/null
done
echo "Challenge Clear: done"

# Challenge Failed (5x) - cleared: false
for i in {1..5}; do
  curl -s -X POST "$BASE_URL/challenge/result" \
    -H "Content-Type: application/json" \
    -d "{\"player_id\":\"P000$i\",\"player_name\":\"Player$i\",\"linked_gate\":\"CRYSTAL\",\"cleared\":false}" > /dev/null
done
echo "Challenge Failed: done"

# Invalid Gate Request - 3x dari IP yang sama (suspicious activity)
for i in {1..3}; do
  curl -s -X POST "$BASE_URL/gate/access" \
    -H "Content-Type: application/json" \
    -H "X-Forwarded-For: 192.168.1.100" \
    -d "{\"player_id\":\"P0099\",\"player_name\":\"SuspiciousPlayer\",\"linked_gate\":\"GATE-FAKE\"}" > /dev/null
done
echo "Invalid Gate Request (suspicious): done"

# Invalid Gate Request tambahan (5x)
for i in {1..5}; do
  curl -s -X POST "$BASE_URL/gate/access" \
    -H "Content-Type: application/json" \
    -d "{\"player_id\":\"P00$i\",\"player_name\":\"Player$i\",\"linked_gate\":\"FAKE-GATE-$i\"}" > /dev/null
done
echo "Invalid Gate Request (misc): done"

# Debug endpoints
curl -s -X POST "$BASE_URL/debug/malformed-log" > /dev/null
echo "Malformed log: done"

curl -s -X POST "$BASE_URL/debug/missing-field-log" > /dev/null
echo "Missing field log: done"

echo "=============================="
echo "Total events generated: 33+"
echo "Check logs/linked-verse.log"