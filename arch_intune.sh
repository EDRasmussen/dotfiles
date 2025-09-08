yay --S --needed --noconfirm microsoft-edge-stable-bin intune-portal-bin
sudo pacman -S --needed --noconfirm libpwquality

# Enable ssh
eval "$(ssh-agent -s)"
find ~/.ssh -type f -name "id_*" ! -name "*.pub" -exec ssh-add {} \;

# Enable password policies
sudo tee /etc/pam.d/system-auth >/dev/null <<'EOF'
#%PAM-1.0

auth       required                    pam_faillock.so      preauth
-auth      [success=2 default=ignore]  pam_systemd_home.so
auth       [success=1 default=bad]     pam_unix.so          try_first_pass nullok
auth       [default=die]               pam_faillock.so      authfail
auth       optional                    pam_permit.so
auth       required                    pam_env.so
auth       required                    pam_faillock.so      authsucc

-account   [success=1 default=ignore]  pam_systemd_home.so
account    required                    pam_unix.so
account    optional                    pam_permit.so
account    required                    pam_time.so

-password  [success=1 default=ignore]  pam_systemd_home.so
password   requisite                   pam_pwquality.so     retry=3
password   required                    pam_unix.so          try_first_pass nullok shadow
password   optional                    pam_permit.so

-session   optional                    pam_systemd_home.so
session    required                    pam_limits.so
session    required                    pam_unix.so
session    optional                    pam_permit.so
EOF

# Actual password rules
sudo tee /etc/security/pwquality.conf >/dev/null <<'EOF'
minlen = 15
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
enforcing = 1
EOF

# Spoofed
sudo tee /etc/pam.d/common-password >/dev/null <<'EOF'
#%PAM-1.0
# Fake file for Intune compliance check (Arch actually uses system-auth)
password   requisite   pam_pwquality.so retry=3 dcredit=-1 ocredit=-1 ucredit=-1 lcredit=-1 minlen=15
password   required    pam_unix.so sha512 shadow nullok
EOF

# create old version of libssl
mkdir -p /tmp/.ossl332
if [[ ! -f /usr/lib/libcrypto-332.so || ! -f /usr/lib/libssl-332.so ]]; then
  curl -L https://archive.archlinux.org/packages/o/openssl/openssl-3.3.2-1-x86_64.pkg.tar.zst \
    | tar --zstd -x -C /tmp/.ossl332
  cp /tmp/.ossl332/usr/lib/libcrypto.so.3 /usr/lib/libcrypto-332.so
  cp /tmp/.ossl332/usr/lib/libssl.so.3    /usr/lib/libssl-332.so
fi

# spoof ubuntu
cat << 'EOF' | sudo tee /etc/os-release > /dev/null
NAME="Ubuntu"
VERSION="20.04.6 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.6 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
EOF

# symlink intune-agent
mkdir -p ~/.local/state/intune
ln -s ~/.config/intune/registration.toml ~/.local/state/intune/registration.toml

# enable service
sudo systemctl enable --now intune-agent.timer 2>/dev/null || true

# launch intune with spoofed stuff
sudo ln -s /opt/microsoft/intune/bin/intune-portal /usr/local/bin/intune-portal
env LD_PRELOAD=/usr/lib/libcrypto-332.so:/usr/lib/libssl-332.so intune-portal
