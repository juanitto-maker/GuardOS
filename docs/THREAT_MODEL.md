# Threat Model

## In‑Scope
- Malware, RATs, phishing, supply chain risks at OS/app level
- Firmware tampering detection (via measurements/attestation)
- Network‑borne attacks (MITM, DNS spoofing, DGA/C2)
- Data exfil, token/session theft, macro pivots

## Out‑of‑Scope (v1)
- Nation‑state hardware implants at fabrication
- Side‑channel micro‑architectural attacks at scale (we apply mitigations but cannot guarantee)
- Full TEMPEST defenses

## Assumptions
- User cooperates with prompts and keeps FIDO2 key safe
- Hardware supports TPM 2.0 and Secure Boot (Tier 1)

## Attacker Classes
- Commodity malware actors
- Targeted intruders with 0‑days
- Malicious insiders with physical access

## Controls Mapping
- See table mapping each layer to controls and detections (linked to ARCHITECTURE).
