# Ubuntu 24.04 LTS Documentation Cross-Reference

This document cross-references the configurations in this repository with the official Ubuntu 24.04 LTS Server Guide and other relevant documentation. The goal is to ensure our settings are aligned with best practices and to note any intentional deviations.

## Core Services

- **Notes & Discrepancies:**
  - **Alignment:** The configuration is strong and aligns with Ubuntu's security-first approach. Key settings like `PermitRootLogin no`, `PasswordAuthentication no`, and `PubkeyAuthentication yes` are all best practices recommended by the official documentation.
  - **Port Inconsistency:** The `sshd_config` file itself specifies `Port 22`. However, the `deploy-complete.sh` script includes a "Next Steps" instruction to "Verify SSH access on port 2222". The `nftables.conf` also expects traffic on port 2222. This implies the port is intended to be changed, but the base config file does not reflect this. This is a documentation/script inconsistency.
  - **Ciphers and MACs:** The configuration explicitly sets `Ciphers aes256-ctr,aes192-ctr,aes128-ctr` and `MACs hmac-sha2-256,hmac-sha2-512`. The default Ubuntu 24.04 configuration is generally more broad. Your configuration is more strict, which is a valid security posture, but it's a deviation from the default.
  - **`AllowUsers`:** The use of `AllowUsers YOUR_USERNAME` is a critical security measure and aligns with the principle of least access. The documentation mentions this as a valid option for restricting access.

### 2. BIND9 DNS Server

- **Package:** `bind9`
- **Configuration Files:**
  - `/etc/bind/named.conf.local` (Repo: `configs/dns/named.conf.local`)
  - `/etc/bind/db.mycorp.lan` (Repo: `configs/dns/db.forward-dns.template`)
  - `/etc/bind/db.10.207.0` (Repo: `configs/dns/db.reverse-dns.template`)
- **Official Documentation:**
  - [Ubuntu 24.04 BIND9 DNS Server Documentation](https://ubuntu.com/server/docs/service-dns-bind)
- **Notes & Discrepancies:**
  - **Alignment:** The use of `named.conf.local` to define custom zones is the standard, recommended practice in Ubuntu's BIND9 packaging. The structure of the zone files (`db.forward-dns.template` and `db.reverse-dns.template`) also follows the correct syntax for SOA and record types.
  - **Template-based Approach:** The repository uses template files (`.template`) that are not used directly by BIND9. The `deploy-complete.sh` script is responsible for copying these to the correct location (e.g., `/etc/bind/db.mycorp.lan`). This is a valid strategy for configuration management, but it's a deviation from a simple, direct configuration. The official documentation assumes direct editing of the final configuration files.
  - **`allow-update { none; }`:** This is a secure default, preventing dynamic DNS updates. The Ubuntu documentation mentions dynamic DNS as an advanced feature, so disabling it by default is a sensible security measure.
  - **systemd-resolved Integration:** The `deploy-complete.sh` script correctly disables the `systemd-resolved` stub listener to prevent conflicts with BIND9 on port 53. This is a critical step and is aligned with the official documentation's guidance for running a local resolver.

### 3. Kea DHCP Server

- **Package:** `kea-dhcp4-server`
- **Configuration File:** `/etc/kea/kea-dhcp4.conf` (Repo: `configs/dhcp/kea-dhcp4.conf`)
- **Official Documentation:**
  - [Ubuntu 24.04 Kea DHCP Documentation](https://ubuntu.com/server/docs/service-dhcp-kea)
- **Notes & Discrepancies:**
  - **Alignment:** The configuration structure is fully compliant with Kea's JSON format. Key sections like `interfaces-config`, `lease-database`, `option-data`, and `subnet4` are all configured according to the official Kea documentation, which is the primary reference for this service on Ubuntu.
  - **Interface Binding:** The config correctly binds the DHCP server to the LAN interface (`ens37`), which is a critical step for ensuring it only serves the internal network.
  - **Lease Database:** The use of `memfile` for the lease database is a simple and effective choice for a single-server setup. The Ubuntu documentation notes that for larger, high-availability setups, a database backend like MySQL or PostgreSQL would be recommended. This configuration is appropriate for the scope of this repository.
  - **Reservations:** The inclusion of a `reservations` block is a good practice for ensuring critical servers (like the example `server.mycorp.lan`) always receive the same IP address. The placeholders are well-documented.

### 4. Nftables Firewall

- **Package:** `nftables`
- **Configuration File:** `/etc/nftables.conf` (Repo: `configs/fw/nftables.conf`)
- **Official Documentation:**
  - [Ubuntu 24.04 Nftables Documentation](https://ubuntu.com/server/docs/security-firewall-nftables)
- **Notes & Discrepancies:**
  - **Alignment:** The configuration is a textbook example of a secure, stateful firewall using `nftables`. It correctly uses `filter` and `nat` tables, defines input/forward/output chains, and sets a default `drop` policy for incoming and forwarded traffic. This aligns perfectly with the best practices in the Ubuntu documentation.
  - **Variable Definitions:** The use of variables (`define`) for interfaces and ports is an excellent practice that makes the ruleset clean and easy to maintain. This is highlighted in the documentation as a key feature of `nftables`.
  - **NAT/Masquerading:** The `postrouting` chain correctly uses `masquerade` to perform Network Address Translation (NAT) for the LAN network, which is the standard way to provide internet access to a private network.
  - **Service Ports:** The rules correctly open ports for the services deployed by this repository (SSH on 2222, DNS on 53, DHCP on 67/68) and restricts them to the LAN interface, which is a critical security measure.

### 5. Fail2Ban

- **Package:** `fail2ban`
- **Configuration:** Handled by the `security-setup.sh` script.
- **Official Documentation:**
  - [Ubuntu 24.04 Fail2Ban Documentation](https://ubuntu.com/server/docs/security-fail2ban)
- **Notes & Discrepancies:**
  - **Alignment:** The process of creating a `jail.local` file to override the default `jail.conf` is the correct, recommended way to configure Fail2Ban on Ubuntu. This ensures that package updates won't overwrite the custom configuration.
  - **Custom Jail:** The script creates a custom `[sshd]` jail that is more aggressive than the default. It sets a longer `bantime` (2 hours) and enables the `aggressive` filter mode, which are strong security enhancements.
  - **Custom Filter:** The script includes logic to deploy a `user.rules` file. This is an advanced feature that demonstrates a solid understanding of Fail2Ban's capabilities, allowing for custom log monitoring beyond the default filters.
  - **Port Configuration:** The `port = 2222` setting in the `[sshd]` jail correctly aligns with the `nftables.conf` and the intended SSH configuration. This is a good example of inter-service consistency.

## Security & System Tools

### 6. Unattended Upgrades

- **Package:** `unattended-upgrades`
- **Configuration:** Handled by `deploy-complete.sh`.
- **Official Documentation:**
  - [Ubuntu 24.04 Automated Security Updates](https://ubuntu.com/server/docs/security-updates)
- **Notes & Discrepancies:**
  - **Alignment:** The implementation is perfectly aligned with the official Ubuntu documentation for automatic security updates. The script installs the `unattended-upgrades` package and then creates a configuration file (`/etc/apt/apt.conf.d/51myunattended-upgrades`) to enable it.
  - **Security-Only Updates:** The configuration correctly limits the allowed origins to `"${distro_id}:${distro_codename}-security"`. This is the recommended best practice for servers, as it ensures that only critical security patches are applied automatically, minimizing the risk of service disruption from other package updates.
  - **Configuration Method:** Creating a new file in `/etc/apt/apt.conf.d/` is the standard way to manage `apt` configurations. The file `51myunattended-upgrades` will be read after the default `50unattended-upgrades` file, making it an effective way to specify the desired behavior.

### 7. AIDE (Advanced Intrusion Detection Environment)

- **Package:** `aide`
- **Configuration:** Installed by `deploy-complete.sh`, initialized by `security-setup.sh`.
- **Official Documentation:**
  - General documentation is available, but specific guides for 24.04 are less common. We will reference general best practices.
- **Notes & Discrepancies:**
  - **Alignment:** The `security-setup.sh` script follows the standard procedure for initializing AIDE. It installs the package, runs `aideinit` to create the initial database, and moves it to the standard location (`/var/lib/aide/aide.db`). This is the correct, documented procedure.
  - **Manual Operation:** The script runs an initial `aide --check`, but ongoing monitoring is a manual process. The Ubuntu documentation notes that AIDE is often run via a `cron` job to automate regular file integrity checks. This repository sets up the tool correctly but leaves the automation of future checks to the administrator, which is a reasonable approach.

### 8. Rkhunter & chkrootkit

- **Packages:** `rkhunter`, `chkrootkit`
- **Configuration:** Installed by `deploy-complete.sh`, run by `security-setup.sh`.
- **Official Documentation:**
  - These are standard Linux security tools. Documentation is typically found in their respective project manuals.
- **Notes & Discrepancies:**
  - **Alignment:** The scripts follow the standard usage pattern for these tools. They are installed via `apt` and then executed directly from the command line.
  - **On-Demand Scans:** The `security-setup.sh` script runs an initial, on-demand scan of both `rkhunter` and `chkrootkit`. This is a common practice for initial system hardening.
  - **Automation:** Similar to AIDE, the repository does not set up `cron` jobs to run these scans automatically. Automating rootkit scans is a common practice, but leaving it as a manual task for the administrator is also a valid choice, especially since these scans can be resource-intensive. The setup provides the tools and leaves the automation strategy to the end-user.
