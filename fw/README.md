# 🔥 Firewall Service (iptables) Configuration

The firewall uses the **legacy `iptables` utility** (persisted via `iptables-persistent`) to implement robust security, including stateful packet inspection and Network Address Translation (NAT) for LAN clients.

## 1. Initial Installation and Configuration

### IPTables Rules (`rules.v4` - File in Repo: `fw/rules.v4`)

The configuration file contains rules that:
1. Enable **NAT (Masquerading)** on the WAN interface (`ens18`).
2. Allow all necessary inbound traffic to the appliance from the LAN (`ens19`): **SSH (2222), DNS (53), HTTP (80), HTTPS (443), DHCP (67/68)**.
3. Set the default policy to drop unwanted traffic.

**Configuration Steps:**

1. **Enable IP Forwarding (Critical for NAT):**

```bash
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf
```

2. **Apply `rules.v4`:** Copy the custom rules to the persistent file location.

```bash
sudo cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.bak
sudo cp /opt/server-config-repo/fw/rules.v4 /etc/iptables/
```

3. **Load the Rules:** Use the persistence utility to load the custom configuration immediately.

```bash
sudo iptables-restore < /etc/iptables/rules.v4
```

## 2. Applying Configuration to a New Server (Recovery)

1. **Copy the configuration file:**

```bash
sudo cp /opt/server-config-repo/fw/rules.v4 /etc/iptables/
```

2. **Ensure IP Forwarding is active** (as per step 1 above).

3. **Load the rules:** `sudo iptables-restore < /etc/iptables/rules.v4`.

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

2. **Check NAT Rule:** Verify the POSTROUTING chain contains the `MASQUERADE` rule: `sudo iptables -L POSTROUTING -t nat -v -n`.
