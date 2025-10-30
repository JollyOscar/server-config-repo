# 📡 **DHCP Service Configuration**

[![Kea DHCP](https://img.shields.io/badge/Kea%20DHCP-2.4+-orange?style=for-the-badge&logo=internet-archive&logoColor=white)](https://www.isc.org/kea/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge&logo=checkmarx&logoColor=white)](./kea-dhcp4.conf)

---

## 🎯 **Service Overview**

| 📊 **Network Configuration** | ⚡ **Technology Stack** |
|:---|:---|
| 🌐 **Interface**: `ens37` (LAN) | 🚀 **Server**: Kea DHCP 2.4+ |
| 🏠 **Subnet**: `10.207.0.0/24` | 📝 **Format**: Modern JSON Configuration |
| 📡 **DHCP Range**: `10.207.0.100-200` | 🔄 **Migration**: ISC DHCP → Kea DHCP |
| 🚪 **Gateway**: `10.207.0.250` | 🎛️ **Management**: RESTful API Support |

> 🆕 **Modern Upgrade**: Migrated from legacy ISC DHCP to Kea DHCP with JSON configuration format

---

## 🚀 **Quick Deployment**

### 📦 **One-Command Setup**

```bash
# 🎯 Complete DHCP deployment
sudo apt install -y kea-dhcp4-server kea-ctrl-agent && \
sudo cp /opt/server-config-repo/configs/dhcp/kea-dhcp4.conf /etc/kea/ && \
sudo systemctl enable --now kea-dhcp4
```

---

## 📋 **Step-by-Step Installation**

### 🔧 **Phase 1: Package Management**

```bash
# 📥 Install Kea DHCP Server
sudo apt install -y kea-dhcp4-server kea-ctrl-agent

# 🛑 Stop legacy ISC DHCP (if present)
sudo systemctl stop isc-dhcp-server 2>/dev/null || true
sudo systemctl disable isc-dhcp-server 2>/dev/null || true
```

### 🛠️ **Phase 2: Configuration Deployment**

```bash
# 💾 Backup existing configuration
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.bak

# 📋 Deploy custom configuration
sudo cp /opt/server-config-repo/configs/dhcp/kea-dhcp4.conf /etc/kea/
sudo chown root:root /etc/kea/kea-dhcp4.conf
sudo chmod 644 /etc/kea/kea-dhcp4.conf
```

### ✅ **Phase 3: Validation & Launch**

```bash
# 🔍 Test configuration syntax
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf

# 🚀 Enable and start service
sudo systemctl enable kea-dhcp4
sudo systemctl start kea-dhcp4

# 📊 Verify status
sudo systemctl status kea-dhcp4
```

## 🔧 Configuration Customization

**Important**: Replace the following placeholders with your actual values:

- **MAC Address**: Replace `aa:bb:cc:dd:ee:ff` in reservations with actual MAC addresses
- **Hostnames**: Replace `server.mycorp.lan` with your actual server names  
- **Domain**: Replace `mycorp.lan` with your actual domain name
- **Interface**: Replace `ens37` with your actual LAN interface name
- **IP Range**: Adjust `10.207.0.100 - 10.207.0.200` if needed

## 2. Applying Configuration to a New Server (Recovery)

1. **Copy configuration file:**

    ```bash
    sudo cp /opt/server-config-repo/configs/dhcp/kea-dhcp4.conf /etc/kea/
    ```

2. **Restart the service:** `sudo systemctl restart kea-dhcp4`.

## 3. Troubleshooting and Verification

### Verification: Lease Assignment

| Step | Command (on server) | Expected Output/Result |
| :--- | :--- | :--- |
| **Check Leases** | `sudo cat /var/lib/kea/kea-leases4.csv` | Should show lease entries in the CSV database. |
| **Client Test** | Connect a client device to the LAN interface. | The client should receive an IP in the defined range, with **10.207.0.250** as its Gateway and DNS server. |

### Troubleshooting Example: Kea Service Failure

**Problem:** Kea fails to start after config change.

**Resolution:**

1. **Check Logs:** `sudo journalctl -u kea-dhcp4.service`. Errors will usually point to the specific line number in
   the JSON file.

2. **Verify Configuration:** Run the syntax test: `sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf`.
