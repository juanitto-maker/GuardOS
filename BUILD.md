# Building GuardOS (Developer)

## Prereqs
- Linux build host, Nix installed (latest stable)
- QEMU/KVM for local testing
- `cosign`, `skopeo`, `git`, `gnupg`

## Steps
1. Clone repo and init submodules.
2. `nix build .#guardos-image` (produces ISO/IMG under `./result`)
3. Verify provenance:
   - `cosign verify-blob --key cosign.pub ./result/guardos.img`
4. Boot in QEMU or write to USB (read-only if possible).

## Notes
- Builds must be reproducible; see [REPRODUCIBLE_BUILDS.md](docs/REPRODUCIBLE_BUILDS.md).
- Do not commit secrets; use `secrets/` via `git-crypt` or age (not in repo).
