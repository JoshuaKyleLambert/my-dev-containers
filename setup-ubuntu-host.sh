#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "====================================================="
echo " Starting Ubuntu WSL Host Environment Setup Script"
echo "====================================================="

# 1. Update system package definitions
echo "--> Updating system package lists..."
sudo apt update

# 2. Install native system dependencies and runtimes
echo "--> Installing Node.js, NPM, Podman, and Podman Compose..."
sudo apt install -y nodejs npm podman podman-compose

# 3. Configure WSL for Systemd
echo "--> Checking /etc/wsl.conf for systemd configuration..."
if [ ! -f /etc/wsl.conf ]; then
    echo -e "[boot]\nsystemd=true" | sudo tee /etc/wsl.conf > /dev/null
    echo "--> Created /etc/wsl.conf and enabled systemd."
    REBOOT_REQUIRED=true
elif ! grep -q "systemd=true" /etc/wsl.conf; then
    # If the file exists but doesn't have systemd enabled, append it safely
    if ! grep -q "\[boot\]" /etc/wsl.conf; then
        echo -e "\n[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf > /dev/null
    else
        sudo sed -i '/\[boot\]/a systemd=true' /etc/wsl.conf
    fi
    echo "--> Updated /etc/wsl.conf to enable systemd."
    REBOOT_REQUIRED=true
else
    echo "--> Systemd is already enabled in /etc/wsl.conf."
fi

# 4. Configure and Enable User-Level Podman Socket
# Note: We don't use sudo here because this must run in your specific user space
echo "--> Enabling and starting rootless user-level Podman service..."
systemctl --user daemon-reload || true
systemctl --user enable --now podman.socket || true

# 5. Sanity Verification Checks
echo "====================================================="
echo " Verification & Diagnostic Check"
echo "====================================================="

USER_ID=$(id -u)
SOCKET_PATH="/run/user/${USER_ID}/podman/podman.sock"

echo "Current User ID (UID): ${USER_ID}"
echo "Expected Socket Path:  ${SOCKET_PATH}"

if [ -S "$SOCKET_PATH" ]; then
    echo " SUCCESS: Rootless Podman socket is live and active!"
else
    echo " WARNING: Socket file not detected at the path yet."
    echo "          This is expected if systemd hasn't initialized yet."
fi

echo "====================================================="
if [ "$REBOOT_REQUIRED" = true ]; then
    echo " IMPORTANT NEXT STEP REQUIRED:"
    echo " Systemd configuration was updated. You MUST restart WSL for this to take effect."
    echo " Close this terminal, open Windows PowerShell/CMD, and run:"
    echo "     wsl --shutdown"
    echo " Then reopen Ubuntu to finish initialization."
else
    echo " Setup complete! Host environment is ready for Dev Containers."
fi
echo "====================================================="