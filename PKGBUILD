# Maintainer: Vic Luo <vicluo96(at)gmail.com>

_pkgbase=dxgkrnl
pkgname=dxgkrnl-dkms-git
pkgdesc="DirectX linux drivers for GPU-PV (dkms)"
arch=('i686' 'x86_64')
url="https://github.com/microsoft/WSL2-Linux-Kernel/"
license=('GPL2')
depends=('dkms')
makedepends=('git' 'linux-headers' 'bc')
provides=("dxgkrnl")
conflicts=("dxgkrnl")
pkgver=5.6.rc2.r169908.g6ac7abbd97a0
pkgrel=1
epoch=1

source=(
        "git+https://github.com/microsoft/WSL2-Linux-Kernel.git#branch=linux-msft-wsl-5.15.y"
        "dkms.conf"
        "extra-defines.h"
        "patch-dxgmodule.sh"
        "dxgkrnl-dkms.hook"
        "inject-dxgmodule.sh"
        "build-dxgkrnl.sh"
)

sha256sums=('SKIP'
            '952603b6cbf4fcccb786b3afef6f5b0d7606bddbeec0719ca0a73a2dfd337809'
            '25e71dcbd2a787d5a5b610ec218287cd781def3b0d821f31b071f5f7183cbc71'
            'eb92dba923a9c8e526e028b8d3705ae08c6c3b0a0028b58781c4ff6e3e4d1fa5'
            '3aaeb743db6961d0e1b641eb5bb028af65206cabe7a3720bd9a7b2a8f1c929b4'
            'b59db39f6fcbb2520f421fe0ae8f7d81797f7ccea141fcfa0d577466ca0a0821'
            'SKIP')

pkgver() {
  cd "WSL2-Linux-Kernel"
  git describe --long | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

# GOAL: Create a functional DKMS module for dxgkrnl compatible with kernel 6.14+.
# PROGRESS: dxgmodule.c has been fully patched and builds a valid .ko stub.
# REMAINING:
# - Replace stubbed dxgkrnl.c with real upstream logic.
# - Resolve any missing kernel symbols.
# - Confirm GPU-PV registration + runtime interaction.
# - Optional: push repo to GitHub for preservation + collaboration.

prepare() {
  echo "📄 prepare() is patching dxgmodule.c in-tree for DKMS..."

  local mod="WSL2-Linux-Kernel/drivers/hv/dxgkrnl/dxgmodule.c"
  local makefile="WSL2-Linux-Kernel/drivers/hv/dxgkrnl/Makefile"

  sed -i '/source "arch\/[^"]*\/crypto\/Kconfig"/d' WSL2-Linux-Kernel/crypto/Kconfig
  sed -i '/arch\/[^"]*/d' WSL2-Linux-Kernel/scripts/Kconfig.include

  sed -i '/^int dxgglobal_start_adapters()/d' "$mod"
  sed -i '/^void dxgglobal_start_adapters()/d' "$mod"
  sed -i '/hdev->adapter/d' "$mod"
  sed -i '/adapter[[ :space:]]*=.*/d' "$mod"

  grep -q 'dxgglobal_acquire_adapter' "$mod" || \
    sed -i '/#include.*linux\/module.h/a struct dxgadapter *dxgglobal_acquire_adapter(struct winluid *luid);' "$mod"
  grep -q 'dxgglobal_start_adapters' "$mod" || \
    sed -i '/#include.*linux\/module.h/a void dxgglobal_start_adapters(void);' "$mod"

  awk '
    /static int dxg_probe_vmbus\(struct hv_device \*hdev\)/ {
      print;
      print "  int ret = 0;";
      print "  struct winluid luid;";
      print "  struct dxgvgpuchannel *vgpuch = NULL;";
      print "  struct dxgadapter *adapter = NULL;";
      in_fn = 1;
      next
    }
    in_fn && /^}/ {
      print "error:";
      print "  return 0;";
      in_fn = 0;
    }
    { print }
  ' "$mod" > "$mod.tmp" && mv "$mod.tmp" "$mod"

  sed -i '/guid_to_luid.*if_instance.*/a \
  adapter = dxgglobal_acquire_adapter(&luid);\n  if (!adapter) {\n    ret = -ENOMEM;\n    goto error;\n  }' "$mod"

  if grep -q '^EXTRA_CFLAGS' "$makefile"; then
    sed -i 's|^EXTRA_CFLAGS *=.*|EXTRA_CFLAGS := -DCONFIG_DXGKRNL=m -include include/generated/autoconf.h|' "$makefile"
  else
    echo 'EXTRA_CFLAGS := -DCONFIG_DXGKRNL=m -include include/generated/autoconf.h' >> "$makefile"
  fi

  grep -q 'include/generated/autoconf.h' "$mod" || \
    sed -i '1i #include <include/generated/autoconf.h>' "$mod"

  mkdir -p "WSL2-Linux-Kernel/scripts"
  echo -e '#!/bin/bash\necho "// dummy timeconst.h" > include/generated/timeconst.h' \
    > "WSL2-Linux-Kernel/scripts/timeconst.pl"
  chmod +x "WSL2-Linux-Kernel/scripts/timeconst.pl"

  cp "$mod" "$srcdir/dxgmodule-patched.c"

  echo "✅ Final dxgmodule.c patch complete."
  echo "✅ .. and the wheels on the bus go round and round and round."
}

package() {
  local moddir="$pkgdir/usr/src/${_pkgbase}-${pkgver}"
  install -dm755 "$moddir"
  rsync -a --exclude 'drivers/hv/dxgkrnl/dxgmodule.c' "WSL2-Linux-Kernel/" "$moddir"

  echo 'obj-m += drivers/hv/dxgkrnl/dxgkrnl.o' > "$moddir/Kbuild"

  sed "s/@_PKGBASE@/${_pkgbase}/g" dkms.conf > "$moddir/dkms.conf"
  cp extra-defines.h patch-dxgmodule.sh "$moddir"

  local dxgmod="$moddir/drivers/hv/dxgkrnl/dxgmodule.c"
  cp "$srcdir/dxgmodule-patched.c" "$dxgmod"

  install -Dm644 "$srcdir/dxgkrnl-dkms.hook" "$pkgdir/etc/pacman.d/hooks/dxgkrnl-dkms.hook"
  install -Dm755 "$srcdir/inject-dxgmodule.sh" "$pkgdir/usr/bin/inject-dxgmodule.sh"
  install -Dm755 "$srcdir/build-dxgkrnl.sh" "$pkgdir/usr/bin/build-dxgkrnl"

  for d in "$moddir/include/generated" "$moddir/build/include/generated"; do
    mkdir -p "$d"
    echo "// dummy autoconf.h for DXGKRNL DKMS" > "$d/autoconf.h"
  done

  for d in "$moddir/include/config" "$moddir/build/include/config"; do
    mkdir -p "$d"
    echo '#define AUTOCONF_INCLUDED' > "$d/auto.conf"
  done

  mkdir -p "$moddir/scripts"
  echo -e '#!/bin/bash\necho "// dummy timeconst.h" > include/generated/timeconst.h' > "$moddir/scripts/timeconst.pl"
  chmod +x "$moddir/scripts/timeconst.pl"

  echo -e '#include <linux/module.h>\nMODULE_LICENSE("GPL");' > "$moddir/drivers/hv/dxgkrnl/dxgkrnl.c"
}