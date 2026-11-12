#!/usr/bin/env bash
# Jalankan app di HP dengan API_BASE otomatis = IP LAN laptop yang satu subnet
# dengan HP. `adb reverse` sering gagal di device tertentu, jadi LAN yang dipakai.
# Pakai: ./run_phone.sh [device-id]
set -euo pipefail
cd "$(dirname "$0")"

ADB="${ADB:-$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe}"

# 1. subnet HP dari tabel route (mis. 192.168.100.0/24 dev wlan0)
PREFIX=$("$ADB" shell ip route 2>/dev/null \
         | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+ dev wlan" \
         | head -1 | grep -oE "^([0-9]{1,3}\.){3}" || true)

# 2. IP laptop di subnet itu
IP=""
if [ -n "$PREFIX" ]; then
  IP=$(ipconfig | grep -i "IPv4" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" \
       | grep -F "$PREFIX" | head -1 || true)
fi
# fallback: IPv4 non-loopback pertama
[ -n "$IP" ] || IP=$(ipconfig | grep -i "IPv4" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" \
                     | grep -vE "^127\." | head -1)
[ -n "$IP" ] || { echo "IP LAN tidak ditemukan"; exit 1; }

API="http://$IP:5000/api"

# 3. backend harus hidup dan mendengar di semua interface
if ! curl -s -m 3 -o /dev/null "http://$IP:5000/api/health"; then
  echo "Backend tidak terjangkau di $IP:5000."
  echo "Jalankan dulu: cd backend && FLASK_HOST=0.0.0.0 ../.venv/Scripts/python.exe app.py"
  exit 1
fi

# 4. pastikan HP benar-benar bisa menjangkau backend
if ! "$ADB" shell "printf 'GET /api/health HTTP/1.0\r\n\r\n' | toybox nc -w 5 $IP 5000 | grep -q '200 OK'"; then
  echo "HP tidak bisa menjangkau $IP:5000. Cek: HP & laptop di Wi-Fi sama,"
  echo "dan Windows Firewall mengizinkan python.exe pada jaringan privat."
  exit 1
fi

echo "API_BASE=$API (terverifikasi dari HP)"
exec flutter run ${1:+-d "$1"} --dart-define=API_BASE="$API"
