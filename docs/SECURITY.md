# Security Policy

This document outlines the security policy for the `server-config-repo` project.

## 🛡️ Security Philosophy

The configurations in this repository are designed with a "secure-by-default" philosophy. This includes:
- **Principle of Least Privilege**: Services and users are granted only the permissions they absolutely need.
- **Defense in Depth**: Security is applied in layers, from the kernel and firewall to individual service configurations.
- **Fail-Secure**: In case of a configuration error, the system is designed to default to a secure state (e.g., firewall blocking traffic).

## reporting-a-vulnerability Reporting a Vulnerability

We take all security vulnerabilities seriously.
If you discover a security issue, please report it to us privately to protect the project and its users.

- **Private Disclosure**: Please create a new **private** security advisory on the repository's GitHub page.
- **Contact**: For urgent matters, mention `@JollyOscar` in the advisory.
- **Response Time**: We aim to provide an initial response within 48 hours.

When reporting, please include:
- A clear description of the vulnerability.
- Step-by-step instructions to reproduce the issue.
- The potential impact of the vulnerability.
- Any suggested mitigations or fixes.

## 📝 Security Best Practices for Users

- **Never Deploy to Production Blindly**: Always test configurations in a non-production environment first.
- **Replace All Placeholders**: Before deployment, you **must** run the `verify-placeholders.sh` script and replace all default values (usernames, passwords, IPs, etc.).
- **Keep Systems Updated**: Regularly apply security patches to the underlying operating system and all installed packages.
- **Monitor Your System**: Actively monitor logs for suspicious activity. Tools like `fail2ban` are included but are not a substitute for vigilance.

## 🔐 Implemented Security Measures

This repository includes several built-in security features:

- **SSH Hardening**:
  - Key-only authentication is enforced (`PasswordAuthentication no`).
  - Runs on a non-standard port (`2222`).
  - Access is restricted to a specific user via `AllowUsers`.
- **Firewall (nftables)**:
  - A default-deny policy is used for incoming traffic.
  - Explicit rules allow only necessary services (SSH, DNS, DHCP).
  - Rate-limiting is applied to SSH to prevent brute-force attacks.
- **System & Kernel Hardening**:
  - The `security-setup.sh` script applies secure kernel parameters via `sysctl`.
  - File integrity monitoring with `AIDE` is configured for manual runs.
- **Service-Specific Security**:
  - **BIND9**: Configured to prevent unauthorized zone transfers and restrict queries.
  - **Fail2ban**: Actively monitors SSH logs and bans malicious IPs.

## 🚨 Incident Response

If you suspect a security incident on a system running these configurations:
1. **Isolate**: Disconnect the affected system from the network if possible.
2. **Preserve**: Create snapshots or backups of the system state and logs for analysis.
3. **Analyze**: Review system logs, firewall logs, and authentication attempts to identify the source and extent of the compromise.
4. **Remediate**: Address the vulnerability, restore the system from a clean backup, and enhance monitoring.

**This repository is for educational and template purposes. The user is ultimately responsible for the security of their own systems.**