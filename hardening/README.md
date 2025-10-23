# 🛡️ System Hardening and Baseline Security

This directory contains instructions to modify the default `/etc/ssh/sshd_config` file, establishing a secure baseline for SSH access.

## 1. Initial Installation and Configuration

### SSH Daemon (`sshd_config` - Edit Default File)

The hardening procedure involves editing the default SSH configuration file to enforce key-based authentication and a custom port (**2222**).

**Configuration Steps:**

1. **Backup the default file:**

    ```bash
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```

2. **Edit the file** (`sudo nano /etc/ssh/sshd_config`) and **uncomment/change** the following lines to match the settings below:

    | Line | Default Value (often commented out) | Custom Value | Action |
    | :--- | :--- | :--- | :--- |
    | `Port` | `#Port 22` | `Port 2222` | **Uncomment and Change** |
    | `PermitRootLogin` | `#PermitRootLogin prohibit-password` | `PermitRootLogin no` | **Uncomment and Change** |
    | `PasswordAuthentication` | `#PasswordAuthentication yes` | `PasswordAuthentication no` | **Uncomment and Change** |
    | `KbdInteractiveAuthentication`| `#KbdInteractiveAuthentication yes` | `KbdInteractiveAuthentication no` | **Uncomment and Change** |
    | `PubkeyAuthentication` | `#PubkeyAuthentication yes` | `PubkeyAuthentication yes` | **Uncomment** |
    | `AuthorizedPrincipalsFile` | (often commented) | `AuthorizedPrincipalsFile no` | **Uncomment** |
    | `UsePAM` | (often commented) | `UsePAM yes` | **Uncomment** |

    *Note: Ensure `StrictModes yes` and `LoginGraceTime 2m` are also uncommented if not already.*

3. **Restart the SSH service:**

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

For recovery, you would follow the same steps: edit the default config file with the specified changes, and re-run the user/group commands.

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

2. **Check Firewall:** Verify that the firewall rules explicitly permit inbound TCP traffic on port **2222**. The firewall configuration is in **`fw/rules.v4`**.
    * **Check current running rules:** `sudo iptables -L INPUT -v -n | grep 2222`
    * **If rules are missing:** Reload the saved rules: `sudo iptables-restore < /etc/iptables/rules.v4`
