# Changelog

All notable changes to this repository will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2025-10-30

This is a major release focused on repository reorganization, CI/CD integration, and comprehensive documentation overhaul based on live deployment feedback.

### Added

- **CI/CD Workflows**: Added GitHub Actions for:
  - `validate-configs.yml`: Validates syntax of Kea, BIND9, nftables, and SSH configs.
  - `documentation-check.yml`: Lints all Markdown files.
  - `security-audit.yml`: Performs basic security checks.
- **Intelligent Verification**: `scripts/verify-placeholders.sh` was rewritten to be smarter, reducing false positives by ignoring comments and its own content.
- **Extensive Documentation**: Created new guides and improved all existing ones.
  - `docs/PLACEHOLDERS-GUIDE.md`: A detailed guide for replacing placeholder values.
  - `docs/FALSE-POSITIVES.md`: Explains common warnings from the verification script.
  - `docs/DEPLOYMENT-ISSUES.md`: Documents issues found and fixed during testing.

### Changed

- **BREAKING: Repository Structure**: The entire repository was reorganized for clarity.
  - All configuration files moved into `configs/`.
  - All scripts moved into `scripts/`.
  - All documentation moved into `docs/`.
- **BREAKING: Renamed DNS Files**: Renamed DNS zone files for better comprehension.
  - `db.mycorp.lan` -> `db.forward-dns.template`
  - `db.10.207.0` -> `db.reverse-dns.template`
- **Documentation Overhaul**: All `.md` files (`README.md`, `STEP-BY-STEP-GUIDE.md`, etc.) were completely rewritten for clarity, accuracy, and consistency.
- **Kea DHCP Config**: Changed `//` comments to `/* */` block comments to be JSON compliant and pass CI validation.
- **SSH Config**: Changed `PasswordAuthentication yes` to `no` to pass security audits.

### Fixed

- **CI/CD Failures**: Fixed all GitHub Actions workflows by updating file paths to match the new `configs/` structure and correcting validation commands.
- **Hardcoded Paths**: Updated all hardcoded file paths in scripts and documentation to reflect the new repository structure.

### Removed

- **Root Files**: Removed all configuration, script, and documentation files from the root directory. Everything is now organized under `configs/`, `scripts/`, and `docs/`.

## [1.0.0] - 2024-10-29

### Added

- Initial repository structure with basic configurations for BIND9, Kea, nftables, and SSH.
- Initial documentation framework and service-specific README files.
- Basic deployment and testing scripts.

---

For detailed upgrade instructions, see the README.md file in each service directory.


