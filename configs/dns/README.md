# 🌐 **DNS Service Configuration**

[![BIND9](https://img.shields.io/badge/BIND9-9.18+-blue?style=for-the-badge&logo=cloudflare&logoColor=white)](https://www.isc.org/bind/)
[![Security](https://img.shields.io/badge/Security-Hardened-success?style=for-the-badge&logo=shield&logoColor=white)](./named.conf.local)
[![Domain](https://img.shields.io/badge/Internal%20Domain-mycorp.lan-purple?style=for-the-badge&logo=domain&logoColor=white)](./db.forward-dns.template)

---

## 🎯 **Service Overview**

| 🏠 **Internal DNS** | 🌍 **External Forwarding** |
|:---|:---|
| 🌐 **Domain**: `mycorp.lan` | 🚀 **Primary**: Cloudflare (`1.1.1.1`) |
| 📍 **Zone Files**: Forward & Reverse | 🔒 **Secondary**: Google (`8.8.8.8`) |
| 🔄 **Auto-Updates**: Dynamic records | ⚡ **Performance**: Caching enabled |
| 🏗️ **Security**: Rate limiting enabled | 🎯 **Reliability**: Multi-server fallback |

> 🆕 **Configuration Update**: Replaced incorrect `resolv.conf` with `named.conf.local` for proper BIND9 configuration.

## 1. Initial Installation and Configuration

### BIND9 Configuration (`named.conf.local`)

This file defines the internal zones and configures recursive lookup behavior using the specified forwarders
(**8.8.8.8, 1.1.1.1**).

**Configuration Steps:**

1. **Apply the main configuration:**

    ```bash
    sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak
    sudo cp /opt/server-config-repo/configs/dns/named.conf.local /etc/bind/
    ```

2. **Apply zone files:**

    ```bash
    sudo cp /opt/server-config-repo/configs/dns/db.forward-dns.template /etc/bind/db.mycorp.lan
    sudo cp /opt/server-config-repo/configs/dns/db.reverse-dns.template /etc/bind/db.10.207.0
    sudo chown bind:bind /etc/bind/db.*
    sudo chmod 644 /etc/bind/db.*
    ```

3. **Check configuration syntax:**

    ```bash
    sudo named-checkconf /etc/bind/named.conf.local
    sudo named-checkzone mycorp.lan /etc/bind/db.mycorp.lan
    sudo named-checkzone 0.207.10.in-addr.arpa /etc/bind/db.10.207.0
    ```

4. **Restart and enable the service:**

    ```bash
    sudo systemctl restart bind9
    sudo systemctl enable bind9
    sudo systemctl status bind9
    ```

## 🔧 Configuration Customization

**Important**: Replace the following placeholders with your actual values:

- **Domain Name**: Replace `mycorp.lan` with your actual internal domain
- **Admin Email**: Replace `admin.mycorp.lan` with your actual email
- **Server Names**: Replace example hostnames with your actual servers
- **IP Addresses**: Update all IP addresses to match your network
- **Interface IP**: Replace `10.207.0.250` with your actual DNS server IP

## 🧪 Testing DNS Resolution

Test your DNS configuration:

```bash
# Test forward resolution
nslookup server.mycorp.lan 10.207.0.250

# Test reverse resolution  
nslookup 10.207.0.250

# Test external forwarding
nslookup google.com 10.207.0.250
```

```bash
sudo systemctl restart bind9
```

## 2. Applying Configuration to a New Server (Recovery)

1. **Copy all configuration files:**

    ```bash
    sudo cp /opt/server-config-repo/configs/dns/named.conf.local /etc/bind/
    # If zone files were in repo: sudo cp /opt/server-config-repo/configs/dns/db.* /etc/bind/
    ```

2. **Set ownership:** `sudo chown -R bind:bind /etc/bind/`.

3. **Restart the service:** `sudo systemctl restart bind9`.

## 3. Troubleshooting and Verification

### Verification: Resolving Internal and External Names

| Step | Command | Expected Output/Result |
| :--- | :--- | :--- |
| **Verify Internal**| `dig server-core.mycorp.lan @127.0.0.1` | The query should resolve to the appliance's LAN IP (**10.207.0.250**). |
| **Verify External**| `dig google.com @127.0.0.1` | The query should resolve successfully via the forwarders. |
| **Service Status** | `sudo systemctl status bind9` | Should show the service as **active (running)**. |

### Troubleshooting Example: Zone Loading Failure

**Problem:** BIND9 fails to start after config change.

**Resolution:**

1. **Check Logs:** `sudo journalctl -u bind9.service`.

2. **Check Zone Syntax:** Use `named-checkzone` on the specific zone file to find the syntax error.

This directory contains the BIND9 DNS server configuration files.

### How It Works

The configuration is designed to be both robust and easy to manage. It uses a template-based system that works directly with the main deployment script (`scripts/deploy-complete.sh`).

1.  **Templates**: The files `db.forward-dns.template` and `db.reverse-dns.template` contain the structure for your DNS zones. You should edit these files to add, remove, or change any DNS records for your network.
2.  **Automation**: You do **not** need to rename these template files. The `deploy-complete.sh` script automatically copies them to the correct final destination (e.g., `/etc/bind/db.mycorp.lan`) during the deployment process.
3.  **Configuration**: The `named.conf.local` file tells the BIND9 service where to find the zone files. This file is also copied automatically by the deployment script.

Your only task is to **edit the contents of the `.template` files** to match your network's requirements. The deployment script handles the rest.
