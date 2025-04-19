# dxgkrnl-dkms-arch

DirectX GPU-PV driver module (`dxgkrnl`) for Arch Linux using DKMS, targeting kernel 6.14+ compatibility.

---

## 🎯 Project Goal

Patch and build a working `dxgkrnl` kernel module from the WSL2 kernel source to enable DirectX GPU paravirtualization on Arch Linux VMs (QEMU, VMware, Hyper-V) with recent kernels (≥ 6.14), supporting accelerated graphics.

---

## 📌 Current Status

✅ Patched `dxgmodule.c` to resolve:
- Invalid memory allocation calls (`kvmalloc`)
- Incorrect function types and missing return statements
- Legacy `uuid_le_cmp` usage (converted to `memcmp`)
- Patching logic fully embedded in `prepare()` of PKGBUILD  
- Builds a placeholder `.ko` module on kernel `6.14.2-arch1-1`

---

## 🧩 Remaining Work

- Replace placeholder `dxgkrnl.c` stub with upstream logic
- Resolve unresolved symbols during full module linkage
- Validate GPU-PV behavior in Windows guest under WSL kernel
- (Optional) Refactor for AUR submission

---

## 🧱 Structure

- Fully self-contained `PKGBUILD`
- Patches `dxgmodule.c` automatically in-tree
- Injects headers and fixes to enable reproducible builds
- Custom DKMS hook preserves modifications post-install

---

## 🚀 Getting Started

```bash
git clone https://github.com/Royel-Payne/dxgkrnl-dkms-arch.git
cd dxgkrnl-dkms-arch
makepkg -si --noconfirm
sudo dkms build -m dxgkrnl -v <version>
