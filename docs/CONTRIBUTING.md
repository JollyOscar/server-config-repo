# How to Contribute

We welcome contributions to improve this repository!
Whether you're fixing a bug, adding a feature, or improving documentation, your help is appreciated.

## 💡 Getting Started

- **Report a Bug**: If you find a problem, please [open an issue](https://github.com/JollyOscar/server-config-repo/issues) and provide as much detail as possible, including steps to reproduce the error.
- **Suggest an Enhancement**: Have an idea for a new feature or an improvement to an existing one? [Open an issue](https://github.com/JollyOscar/server-config-repo/issues) to start a discussion.

## 🚀 Making a Contribution

If you're ready to contribute code or documentation, please follow these steps:

1. **Fork the Repository**: Create your own copy of the project.
2. **Create a Branch**: Make a new branch for your changes.
    ```bash
    git checkout -b feature/my-new-feature
    ```
3. **Make Your Changes**: Edit the files and test your changes thoroughly.
4. **Commit Your Work**: Write a clear, concise commit message.
    ```bash
    git commit -am 'Add new feature: Description of changes'
    ```
5. **Push to Your Branch**:
    ```bash
    git push origin feature/my-new-feature
    ```
6. **Open a Pull Request**: Submit a pull request from your forked repository to the `main` branch of the original repository.

## ✅ Contribution Guidelines

- **Maintain Security**: Do not introduce changes that weaken the security posture. All contributions must align with the [Security Policy](SECURITY.md).
- **Update Documentation**: If you change a configuration, you **must** update the corresponding documentation (`README.md`, guides, etc.).
- **Test Your Changes**: Before submitting a pull request, validate your configurations using the provided tools.
- **Keep it Clean**: Ensure your code and documentation are well-formatted and easy to read.

## 🛠️ Development and Testing

To test your changes locally, you'll need the appropriate validation tools.

### Prerequisites

```bash
# Install validation tools for Debian/Ubuntu
sudo apt update
sudo apt install -y bind9-utils kea-dhcp4-server nftables openssh-server
```

### Validation Commands

Run these commands from the root of the repository to test the configuration files.

```bash
# Validate DNS configuration
sudo named-checkconf configs/dns/named.conf.local

# Validate DHCP configuration
sudo kea-dhcp4 -t configs/dhcp/kea-dhcp4.conf

# Validate Firewall rules
sudo nft -c -f configs/fw/nftables.conf

# Validate SSH configuration
sudo sshd -t -f configs/hardening/sshd_config
```

Thank you for contributing!