# GuardOS AI Safety & Data Policy (v0)
#
# This file defines privacy constraints, red-team guardrails, and execution rules
# for all LLMs and AI agents running inside GuardOS.
#
# NOTE: In "local" mode, all network access MUST be blocked by runners/adapters.

policy:
  modes:
    local:
      network_access: "deny"
      file_access: "allowlist"
      telemetry: "off"
      outbound_ai_calls: false
      require_local_inference: true

    hybrid:
      network_access: "guard-tunnel-only"
      file_access: "allowlist"
      telemetry: "minimal"
      outbound_ai_calls: true
      require_user_consent: true

    cloud:
      network_access: "guard-tunnel-only"
      file_access: "redact-default"
      telemetry: "minimal"
      outbound_ai_calls: true
      require_user_consent: true

  content_controls:
    pii_detection: true
    redact_pii_default: true
    allow_external_sending_only_with_user_consent: true
    sanitize_input_before_send: true
    enforce_token_limit: true

  output_controls:
    max_tokens_default: 256
    temperature_default: 0.7
    top_p_default: 0.95
    require_structured_output_for_tools: true
    enforce_json_format_if_specified: true

  safety_checks:
    - name: refuse_malware_generation
      description: "Refuse any prompt involving creation, explanation, or distribution of malware."

    - name: refuse_privileged_instruction
      description: "Refuse to give instructions for bypassing security, jailbreaking, or accessing protected subsystems."

    - name: no_medical_or_legal_advice
      description: "Insert disclaimers and redirect to qualified professionals."

    - name: suppress_identity_disclosure
      description: "Do not reveal real-world identities, emails, logins, or location data — even hypothetically."

    - name: verify_before_action
      description: "For critical actions, always request explicit user confirmation before proceeding."

  logging:
    store_transcripts: "local-only-sanitized"
    strip_identifiers: true
    redact_pii_in_logs: true
    rotate_days: 14
    upload_allowed: false

  prompts:
    system_prefix: |
      You are a local AI agent running inside GuardOS.
      You operate in **{mode}** mode.
      Follow the safety policy defined in `ai/policies/safety.yaml`.
      You may not access the internet unless explicitly allowed.
      Avoid guessing, hallucinating, or making up facts. Always be concise and truthful.
      If you are unsure, state that clearly.

meta:
  version: 0.1
  updated: "2025-09-08"
  author: "GuardOS Core Team"
  notes: >
    This policy applies globally to all local agents, including those in GuardPanel, Aegis, and Hunter.
    It should be extended with module-specific rules where needed.
