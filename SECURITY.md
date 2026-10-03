# Security Policy

## Reporting a vulnerability

Please do not disclose security vulnerabilities through public issues.

If you discover a vulnerability in Synapse, report it privately to the repository owner through GitHub so the issue can be reviewed before public disclosure.

When reporting a vulnerability, include:

- A clear description of the issue
- The affected file or component
- Reproduction steps
- The potential impact
- Any relevant logs or screenshots

Do not include passwords, access tokens, API keys, private keys, or other credentials in reports.

## Secrets

Synapse should not require credentials to run its public source code. Never commit:

- API keys
- Access tokens
- Private keys
- Passwords
- Session cookies
- Personal access credentials

If a credential is accidentally committed, revoke or rotate it immediately. Removing it from the latest commit does not invalidate a credential that was already exposed in Git history.
