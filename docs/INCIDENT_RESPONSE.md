# Incident Response (Personal Device)

## Triage Levels
- L1: Suspicious app behavior → auto network cut + prompt
- L2: Privilege escalation attempt → system isolation + snapshot
- L3: Firmware mismatch → Yellow Boot (sealed disk), guided reflash

## Playbooks
- App compromise: kill, snapshot, SafeView restore, optional Hunter Mode
- Network beacon: freeze egress, capture ring buffer, blocklists update
- Lost/stolen: Travel/Lockdown mode; crypto‑wipe with FIDO2 confirmation

## Forensics
- Minimal volatile capture with user consent
- Export encrypted incident bundle for expert help
