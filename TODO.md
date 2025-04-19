
---

### ✅ `TODO.md` (Add to Repo Root)

```markdown
# TODO: dxgkrnl-dkms-arch

Tracking tasks to reach a fully functional dxgkrnl DKMS module for GPU-PV.

## 🔧 Technical Tasks
- [ ] Replace stubbed `dxgkrnl.c` with real upstream source
- [ ] Confirm module loads with no unresolved symbols
- [ ] Validate behavior in Windows WSL guest (via QEMU or passthrough)

## 💡 Refactor & Automation
- [ ] Parameterize kernel version detection in PKGBUILD
- [ ] Clean up sed/awk logic to use patch files or inline functions
- [ ] Explore use of patch queue or quilt to manage source diffs
- [ ] Add fallback support for LTS kernel

## 🧪 Testing Targets
- [ ] Load `.ko` and confirm registration under `/dev/dxg`
- [ ] Trace `dmesg` logs during WSL launch for dxgkrnl
- [ ] Build on at least two kernel versions (6.14.x and 6.12 LTS)

## 📦 Long-Term Goals
- [ ] Package for the AUR (`dxgkrnl-dkms-git`)
- [ ] Add test suite or CI (GitHub Actions)
- [ ] Document kernel differences or breakages upstream

---
