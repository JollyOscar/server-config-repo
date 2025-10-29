# 🌐 DNS Service (BIND9) Configuration

This service provides internal network name resolution for the **mycorp.lan** domain and forwards all external queries to public DNS servers.

> **Note**: The configuration file has been renamed from `resolv.conf` to `named.conf.local` to correctly reflect BIND9 configuration format.

## 1. Initial Installation and Configuration

### BIND9 Configuration (`named.conf.local`)

This file defines the internal zones and configures recursive lookup behavior using the specified forwarders (**8.8.8.8, 1.1.1.1**).

**Configuration Steps:**

1. **Apply the main configuration:**

    ```bash
    sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak
    sudo cp /opt/server-config-repo/dns/named.conf.local /etc/bind/
    ```

2. **Apply zone files:**

    ```bash
    sudo cp /opt/server-config-repo/dns/db.mycorp.lan /etc/bind/
    sudo cp /opt/server-config-repo/dns/db.10.207.0 /etc/bind/
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
    sudo cp /opt/server-config-repo/dns/named.conf.local /etc/bind/
    # If zone files were in repo: sudo cp /opt/server-config-repo/dns/db.* /etc/bind/
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
