# Installing GuardOS (User)

## Supported (Tier 1)
- Framework 13/16, ThinkPad T480/X270, MinisForum UM790, Librem 14

## Steps
1. Back up your data.
2. Boot GuardOS USB (UEFI).
3. Installer: choose Full Disk (LUKS2) or Dual Boot.
4. Create passkeys (FIDO2) and recovery key.
5. Reboot; enroll Secure Boot keys (if prompted).

## Post‑Install
- App Center → install needed apps (Flatpak).
- Connect FIDO2 key for seamless login.
- (Optional) Enable Travel/Untrusted Wi‑Fi WireGuard profile.

Rollback: Settings → Updates → “Rollback to previous snapshot”.
