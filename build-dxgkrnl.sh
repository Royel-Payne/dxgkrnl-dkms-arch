#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

pkgver=$(grep ^pkgver= PKGBUILD | cut -d= -f2)

echo "🧼 Cleaning old build and DKMS state..."
sudo dkms remove -m dxgkrnl -v "$pkgver" --all || true
rm -rf src/ pkg/

echo "📦 Building and installing dxgkrnl-dkms-git with makepkg..."
makepkg -si --noconfirm

echo "🔧 Manually touching bounds.h to satisfy DKMS deps..."
for v in /usr/src/dxgkrnl-*/; do
 sudo mkdir -p "$v/include/generated"
 sudo touch "$v/include/generated/bounds.h"
done

echo "⚙️ Building DKMS module for installed kernels..."
for kver in $(ls /usr/lib/modules); do
  sudo dkms build -m dxgkrnl -v "$pkgver" -k "$kver" || true
done

echo "🪵 Errors (if any):"
grep -i error /var/lib/dkms/dxgkrnl/*/build/make.log | head -n 30 || echo "✅ No DKMS errors"

echo "✅ Done."
