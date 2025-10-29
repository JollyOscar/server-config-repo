# 🛡️ **System Hardening & Baseline Security**

[![Ubuntu](https://img.shields.io/badge/Ubuntu-Hardened-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/server)
[![SSH](https://img.shields.io/badge/SSH-Key%20Only-success?style=for-the-badge&logo=openssh&logoColor=white)](./sshd_config)
[![Security](https://img.shields.io/badge/Security-Enterprise-red?style=for-the-badge&logo=shield&logoColor=white)](./security-setup.sh)

---

## 🎯 **Security Arsenal**

| 🔐 **Component** | 📝 **Purpose** | 📁 **File** | 🚀 **Status** |
|:---:|:---|:---:|:---:|
| 🔑 **SSH Hardening** | Key-only auth, custom port, rate limiting | [`sshd_config`](./sshd_config) | ✅ Ready |
| ⚙️ **Kernel Security** | System-level security parameters | [`sysctl-security.conf`](./sysctl-security.conf) | ✅ Ready |
| 🤖 **Auto Setup** | One-command security deployment | [`security-setup.sh`](./security-setup.sh) | ✅ Ready |
| 🚨 **Login Banner** | Legal notice & deterrent | [`issue.net`](./issue.net) | ✅ Ready |
| 📖 **Deploy Guide** | Complete deployment procedures | [`DEPLOYMENT.md`](./DEPLOYMENT.md) | ✅ Ready |

## 🚀 Quick Start (Recommended)

Run the automated security setup script:

```bash
sudo chmod +x /opt/server-config-repo/hardening/security-setup.sh
sudo /opt/server-config-repo/hardening/security-setup.sh
```

This script will:
- Install security packages (fail2ban, AIDE, etc.)
- Configure SSH hardening
- Set up file integrity monitoring
- Apply kernel security parameters
- Create security monitoring cron jobs

## 📋 Manual Configuration Steps

### 1. SSH Daemon Hardening

**Quick Apply:**

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo cp /opt/server-config-repo/hardening/sshd_config /etc/ssh/
sudo systemctl restart sshd
```

**Key Security Changes (Following Ubuntu's Official Recommendations):**
- Custom port (2222) instead of default 22
- Root login disabled (Ubuntu security best practice)
- Password authentication disabled (Ubuntu: "massively improves your security")
- Key-only authentication (Ubuntu's recommended method)
- Connection rate limiting (MaxStartups 2:30:10)
- Forwarding disabled (Ubuntu: "gives more options to attacker")
- Verbose logging enabled (Ubuntu: "recommended to log more information")
- Modern cipher suites only

**Rate Limiting (Ubuntu's UFW Recommendation):**

Ubuntu recommends using UFW to rate-limit SSH connections:

```bash
sudo ufw limit ssh
# This limits one IP to 10 connection attempts in 30 seconds
```

### Optional: Enable Login Banner

Uncomment the Banner line in sshd_config and copy the banner file:

```bash
sudo cp /opt/server-config-repo/hardening/issue.net /etc/
```

### 2. Restart the SSH service

```bash
sudo systemctl restart ssh
```

### Custom User/Group Setup

This step ensures the necessary administrative group exists on the system.

**Configuration Steps:**

1. **Create Admin Group and Add User:**

    ```bash
    # Create the 'sysadmin' group and add your default user
    sudo groupadd sysadmin
    sudo usermod -aG sysadmin $USER
    ```

## 2. Applying Configuration to a New Server (Recovery)

For recovery, you would follow the same steps: edit the default config file with the specified changes, and
re-run the user/group commands.

## 3. Troubleshooting and Verification

### Verification: SSH Port and Key Authentication

| Step | Command | Expected Output/Result |
| :--- | :--- | :--- |
| **Verify Port** | `sudo ss -tulpn \| grep ssh` | The service should be listening on port **2222**. |
| **Test Login** | `ssh -p 2222 user@server-ip` | Successful login using your SSH key. Attempting to log in on port 22 or as `root` should **fail**. |

### Troubleshooting Example: SSH Connection Refused

**Problem:** Cannot connect after changing `sshd_config`.
**Resolution:**

1. **Check Config:** `sudo sshd -t` (returns nothing on success).

2. **Check Firewall:** Verify that the firewall rules explicitly permit inbound TCP traffic on port **2222**.
   The firewall configuration is in **`fw/nftables.conf`**.
   - **Check current running rules:** `sudo nft list chain inet filter input | grep 2222`
   - **If rules are missing:** Reload the saved rules: `sudo systemctl restart nftables`
