# Contributing to Server Configuration Repository

Thank you for your interest in contributing to this network appliance configuration repository! 

## 🎯 Project Purpose

This repository provides secure, production-ready configurations for a multi-service network appliance running:
- **DNS** (BIND9) for internal name resolution
- **DHCP** (Kea) for IP address management  
- **Firewall** (nftables) for network security
- **System Hardening** for baseline security

## 🤝 How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs or suggest improvements
- Include relevant configuration details and error messages
- Describe your network environment and use case

### Suggesting Enhancements
- Propose new features or security improvements via GitHub Issues
- Explain the use case and expected benefits
- Consider backward compatibility

### Code Contributions
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/improvement-name`)
3. **Test** your changes thoroughly
4. **Commit** your changes (`git commit -m 'Add security improvement'`)
5. **Push** to the branch (`git push origin feature/improvement-name`)
6. **Create** a Pull Request

## 📋 Contribution Guidelines

### Configuration Changes
- **Test all changes** in isolated environments first
- **Validate syntax** using appropriate tools (named-checkconf, nft -c, etc.)
- **Update documentation** to reflect configuration changes
- **Maintain security** - never weaken existing security measures

### Documentation
- Update relevant README files when changing configurations
- Use clear, concise language
- Include examples and customization instructions
- Mark placeholder values clearly

### Security Considerations
- **Review security implications** of all changes
- **Follow security best practices** for network services
- **Test security configurations** before proposing changes
- **Document security features** and their purposes

## 🔧 Development Setup

### Prerequisites
```bash
# Install validation tools
sudo apt install -y bind9-utils kea-dhcp4 nftables
```

### Testing Changes
```bash
# Validate DNS configuration
named-checkconf dns/named.conf.local
named-checkzone mycorp.lan dns/db.mycorp.lan

# Validate DHCP configuration  
kea-dhcp4 -t dhcp/kea-dhcp4.conf

# Validate firewall rules
sudo nft -c -f fw/nftables.conf

# Validate SSH configuration
sudo sshd -t -f hardening/sshd_config
```

## 📊 Quality Standards

### Configuration Files
- Use proper syntax and formatting
- Include helpful comments
- Follow service-specific best practices
- Maintain consistency across configurations

### Documentation  
- Keep README files up to date
- Use clear headings and structure
- Include troubleshooting information
- Provide customization guidance

### Security
- Apply security hardening principles
- Use least privilege access
- Implement defense in depth
- Document security features

## 🚦 Pull Request Process

1. **Ensure** all validations pass (run GitHub Actions locally if possible)
2. **Update** documentation for any configuration changes
3. **Include** clear description of changes and rationale
4. **Test** configurations in representative environment
5. **Request** review from repository maintainers

### PR Requirements
- [ ] All configuration files validate successfully
- [ ] Documentation updated
- [ ] Security implications considered
- [ ] Changes tested in safe environment
- [ ] Clear commit messages

## 🎨 Style Guide

### Configuration Files
- Use consistent indentation (2 spaces for JSON, tabs for others as appropriate)
- Include descriptive comments
- Group related settings logically
- Use meaningful variable/option names

### Documentation
- Use markdown formatting consistently
- Include code examples in fenced blocks
- Use emoji icons sparingly for visual organization
- Write in clear, professional language

## 🔒 Security

- Never commit secrets, passwords, or private keys
- Use placeholder values for sensitive configuration
- Test security configurations thoroughly
- Report security issues responsibly (see SECURITY.md)

## 🏷️ Labeling

Use these labels for issues and PRs:
- `bug` - Bug reports or fixes
- `enhancement` - New features or improvements
- `documentation` - Documentation changes
- `security` - Security-related changes
- `configuration` - Service configuration changes

## 📞 Questions?

- **General questions**: Create a GitHub Issue
- **Security concerns**: See SECURITY.md
- **Contact maintainer**: @JollyOscar

## 📄 License

This project contains configuration files for private use. By contributing, you agree that your contributions will be used under the same terms as the existing project.

---

Thank you for helping to improve this network appliance configuration repository! 🚀