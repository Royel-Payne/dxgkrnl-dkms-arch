# dxgkrnl-dkms-git

Arch Linux DKMS package for the `dxgkrnl` module (Microsoft's GPU-PV DirectX driver), patched for Linux kernel 6.14+.

## 🚀 Goal

Enable GPU paravirtualization (GPU-PV) via DirectX in Arch Linux using a patched version of Microsoft's dxgkrnl for WSL2.

## 🧪 Progress

- ✅ DKMS integration complete
- ✅ Kernel 6.14 compatibility: patched `dxgmodule.c`, memory allocation fixes, symbol injection
- ✅ Successfully builds a minimal `.ko` stub module
- 🔧 Remaining: replace stub with full upstream logic, verify GPU-PV runtime

## 📦 Usage

Build and install using:

```bash
git clone https://github.com/Royel-Payne/dxgkrnl-dkms-arch.git
cd dxgkrnl-dkms-arch
makepkg -si
