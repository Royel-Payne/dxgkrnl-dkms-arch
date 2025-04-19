#!/bin/sh
for ver in /var/lib/dkms/dxgkrnl/*; do
  src="/usr/src/dxgkrnl-$(basename "$ver")/drivers/hv/dxgkrnl/dxgmodule.c"
  [ -f "$src" ] && install -Dm644 "$src" "$ver/source/dxgmodule.c"
done
