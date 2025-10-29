# 🔥 **Firewall Configuration**

[![nftables](https://img.shields.io/badge/nftables-1.0+-red?style=for-the-badge&logo=linux&logoColor=white)](https://netfilter.org/projects/nftables/)
[![Security](https://img.shields.io/badge/Security-Enterprise%20Grade-success?style=for-the-badge&logo=shield&logoColor=white)](./nftables.conf)
[![NAT](https://img.shields.io/badge/NAT-Enabled-blue?style=for-the-badge&logo=router&logoColor=white)](./nftables.conf)

---

## 🎯 **Modern Firewall Stack**

| 🛡️ **Security Features** | 🌐 **Network Services** |
|:---|:---|
| 🚫 **Default Deny**: Explicit allow rules only | � **NAT/Masquerading**: LAN → Internet |
| � **Stateful Tracking**: Connection state awareness | 🎯 **Interface Separation**: WAN/LAN isolation |
| 🚨 **Rate Limiting**: DoS/DDoS protection | ⚡ **Performance Optimized**: Hardware acceleration |
| 📊 **Comprehensive Logging**: Security monitoring | 🔧 **Easy Management**: Modern nftables syntax |

> 🆕 **Technology Upgrade**: Migrated from legacy iptables → modern nftables for enhanced performance and security

## 🛡️ Security Features

The nftables configuration provides:

1. **Default deny policy** with explicit allow rules
2. **Stateful connection tracking** for established/related traffic
3. **NAT/Masquerading** for LAN client internet access
4. **Rate limiting** to prevent abuse and DoS attacks
5. **Logging** of dropped packets for security monitoring
6. **Interface-specific rules** for WAN/LAN separation

## 📋 Configuration Steps

1. **Enable IP Forwarding (Critical for NAT):**

    ```bash
    echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
    sudo sysctl -p /etc/sysctl.d/99-ipforward.conf
    ```

2. **Install and configure nftables:**

    ```bash
    sudo apt install -y nftables
    sudo systemctl enable nftables
    ```

3. **Apply the nftables configuration:**

    ```bash
    sudo cp /opt/server-config-repo/fw/nftables.conf /etc/nftables.conf
    sudo chmod 644 /etc/nftables.conf
    ```

4. **Test and load the configuration:**

    ```bash
    # Test the configuration syntax
    sudo nft -c -f /etc/nftables.conf
    
    # Load the configuration
    sudo systemctl restart nftables
    sudo systemctl status nftables
    ```

## 🔧 Configuration Customization

**Important**: Replace the following placeholders with your actual values:

- **WAN Interface**: Replace `ens18` with your actual WAN interface name
- **LAN Interface**: Replace `ens19` with your actual LAN interface name  
- **LAN Network**: Replace `10.207.0.0/24` with your actual LAN subnet
- **Appliance IP**: Replace `10.207.0.250` with your actual server IP
- **SSH Port**: Replace `2222` with your actual SSH port

## 🧪 Testing Firewall Rules

Verify your firewall configuration:

```bash
# Check active ruleset
sudo nft list ruleset

# Test connectivity from LAN client
ping 8.8.8.8  # Should work from LAN clients

# Check logs for dropped packets
sudo journalctl -f | grep "nft-"
```

## 🚨 Emergency Access

If you get locked out, you can disable the firewall temporarily:

```bash
# Flush all rules (emergency only)
sudo nft flush ruleset

# Or stop the service
sudo systemctl stop nftables
```

## 📊 Monitoring

View firewall statistics and logs:

```bash
# View rule statistics
sudo nft list ruleset -a

# Monitor dropped packets
sudo tail -f /var/log/kern.log | grep "nft-"
```

## 3. Troubleshooting and Verification

### Verification: NAT and Rule Functionality

| Step | Command | Expected Output/Result |
| :--- | :--- | :--- |
| **Rule Loading** | `sudo iptables-save` | Should display the chains and rules, including the NAT `MASQUERADE` rule on **ens18**. |
| **Verify NAT** | From a LAN client (e.g., 10.207.0.101), run a trace route (`traceroute 8.8.8.8`). | The first hop should be **10.207.0.250**. |
| **Verify SSH Filter** | Check the INPUT chain for the custom port: `sudo iptables -L INPUT -v -n &#124; grep 2222` | Should show the rule accepting TCP traffic on port 2222. |

### Troubleshooting Example: Internet Access Blocked

**Problem:** Internal clients cannot access the internet.

**Resolution:**

1. **Check IP Forwarding:** Run `sysctl net.ipv4.ip_forward`. It **must** return `1`.

2. **Check NAT Rule:** Verify the POSTROUTING chain contains the `MASQUERADE` rule:
   `sudo iptables -L POSTROUTING -t nat -v -n`.
