# 🤝 DHCP Service (Kea DHCP) Configuration

The DHCP service runs the **Kea DHCP Server** on the **LAN interface (ens19)**, dynamically assigning IPs within the **10.207.0.0/24** subnet, using the range **10.207.0.100 to 10.207.0.200**.

> **Note**: This configuration has been updated to use Kea DHCP (modern JSON format) instead of ISC DHCP Server. The filename has been changed from `dhcpd.conf` to `kea-dhcp4.conf`.

## 1. Initial Installation and Configuration

### Kea DHCP Configuration (`kea-dhcp4.conf` - JSON Format)

The custom `kea-dhcp4.conf` defines the DHCP range and specifies network options (Gateway and DNS Server) for the internal network using the appliance's static IP (**10.207.0.250**).

**Configuration Steps:**

1. **Install Kea DHCP Server and stop old ISC DHCP** (if present):

    ```bash
    sudo apt install -y kea-dhcp4 kea-ctrl-agent
    sudo systemctl stop isc-dhcp-server
    sudo systemctl disable isc-dhcp-server
    ```

2. **Backup the default configuration:**

    ```bash
    sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.bak
    ```

3. **Apply the custom configuration:**

    ```bash
    sudo cp /opt/server-config-repo/dhcp/kea-dhcp4.conf /etc/kea/
    sudo chown root:root /etc/kea/kea-dhcp4.conf
    sudo chmod 644 /etc/kea/kea-dhcp4.conf
    ```

4. **Test configuration syntax:**

    ```bash
    sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
    ```

5. **Enable and start the service:**

    ```bash
    sudo systemctl enable kea-dhcp4
    sudo systemctl start kea-dhcp4
    sudo systemctl status kea-dhcp4
    ```

## 🔧 Configuration Customization

**Important**: Replace the following placeholders with your actual values:

- **MAC Address**: Replace `aa:bb:cc:dd:ee:ff` in reservations with actual MAC addresses
- **Hostnames**: Replace `server.mycorp.lan` with your actual server names  
- **Domain**: Replace `mycorp.lan` with your actual domain name
- **Interface**: Replace `ens19` with your actual LAN interface name
- **IP Range**: Adjust `10.207.0.100 - 10.207.0.200` if needed

## 2. Applying Configuration to a New Server (Recovery)

1. **Copy configuration file:**

    ```bash
    sudo cp /opt/server-config-repo/dhcp/kea-dhcp4.conf /etc/kea/
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

1. **Check Logs:** `sudo journalctl -u kea-dhcp4.service`. Errors will usually point to the specific line number in the JSON file.

2. **Verify Configuration:** Run the syntax test: `sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf`.
