# Changelog

All notable changes to this network appliance configuration repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Modern nftables firewall configuration with rate limiting
- Kea DHCP server configuration (JSON format)
- Enhanced DNS security with BIND9 rate limiting
- Comprehensive SSH hardening configuration
- System security hardening with kernel parameters
- Automated security setup script
- File integrity monitoring configuration
- GitHub Actions workflows for validation and security auditing
- Comprehensive documentation with customization guidance
- Security policy and contributing guidelines

### Changed
- **BREAKING**: Renamed `dhcp/dhcpd.conf` to `dhcp/kea-dhcp4.conf` (Kea DHCP format)
- **BREAKING**: Renamed `dns/resolv.conf` to `dns/named.conf.local` (BIND9 format)
- **BREAKING**: Renamed `fw/rules.v4` to `fw/nftables.conf` (nftables format)
- Updated all README files with proper placeholder documentation
- Enhanced SSH configuration with modern cipher suites
- Improved firewall rules with stateful filtering and logging
- Updated DNS configuration with security hardening

### Fixed
- Corrected DHCP configuration syntax for Kea compatibility
- Fixed DNS zone file references and configuration paths
- Improved firewall rule organization and security
- Enhanced SSH security with proper authentication restrictions

### Security
- Implemented default-deny firewall policy
- Added rate limiting for SSH and DNS services
- Disabled weak SSH authentication methods
- Enhanced DNS query restrictions and transfer protections
- Added comprehensive system hardening parameters
- Implemented file integrity monitoring
- Added automated security checks and reporting

## [1.0.0] - 2024-10-29

### Added
- Initial repository structure
- Basic network service configurations
- Documentation framework
- Service-specific README files

---

## Migration Guide

### From Legacy Configurations

If you're upgrading from previous versions, please note these breaking changes:

#### DHCP Service Migration
```bash
# Old: ISC DHCP Server
sudo systemctl stop isc-dhcp-server
sudo systemctl disable isc-dhcp-server

# New: Kea DHCP Server
sudo apt install kea-dhcp4
sudo cp dhcp/kea-dhcp4.conf /etc/kea/
sudo systemctl enable kea-dhcp4
sudo systemctl start kea-dhcp4
```

#### Firewall Migration
```bash
# Old: iptables rules
sudo iptables-save > /tmp/old-rules.txt

# New: nftables configuration
sudo cp fw/nftables.conf /etc/nftables.conf
sudo systemctl enable nftables
sudo nft -f /etc/nftables.conf
```

#### DNS Configuration Update
```bash
# Update BIND9 configuration
sudo cp dns/named.conf.local /etc/bind/
sudo cp dns/db.* /etc/bind/
sudo systemctl reload bind9
```

### Customization Requirements

After upgrading, you **must** customize these placeholder values:

- Replace `mycorp.lan` with your actual domain
- Update `10.207.0.0/24` network range if different
- Change `ens18`/`ens19` interface names to match your system
- Set actual MAC addresses in DHCP reservations
- Configure proper SSH public keys
- Update admin email addresses

---

For detailed upgrade instructions, see the README.md file in each service directory.