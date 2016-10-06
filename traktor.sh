#!/bin/bash
clear

echo -e "Traktor v1.2\nTor will be automatically installed and configured…\n\n"

# Install Packages
sudo apt install -y tor obfs4proxy polipo dnscrypt-proxy torbrowser-launcher

# Write Bridge
echo "UseBridges 1
Bridge obfs4 194.132.209.170:36441 B16B4B1B10910B6EC4A3E713297C4EAE9DFB5229 cert=SzdrMUoL49NrQ0WpTy3dw26MlxNAcvD3lLFqZDrAA/euN++77WueeirzoV2OU5QpJplfUQ iat-mode=0
Bridge obfs4 154.35.22.12:80 00DC6C4FA49A65BD1472993CF6730D54F11E0DBB cert=N86E9hKXXXVz6G7w2z8wFfhIDztDAzZ/3poxVePHEYjbKDWzjkRDccFMAnhK75fc65pYSg iat-mode=0
Bridge obfs4 154.35.22.13:443 FE7840FE1E21FE0A0639ED176EDA00A3ECA1E34D cert=fKnzxr+m+jWXXQGCaXe4f2gGoPXMzbL+bTBbXMYXuK0tMotd+nXyS33y2mONZWU29l81CA iat-mode=0
Bridge obfs4 154.35.22.10:80 8FB9F4319E89E5C6223052AA525A192AFBC85D55 cert=GGGS1TX4R81m3r0HBl79wKy1OtPPNR2CZUIrHjkRg65Vc2VR8fOyo64f9kmT1UAFG7j0HQ iat-mode=0
Bridge obfs4 154.35.22.11:443 A832D176ECD5C7C6B58825AE22FC4C90FA249637 cert=YPbQqXPiqTUBfjGFLpm9JYEFTBvnzEJDKJxXG5Sxzrr/v2qrhGU4Jls9lHjLAhqpXaEfZw iat-mode=0
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" | sudo tee /etc/tor/torrc

# Fix Problem Apparmor
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Write Polipo config
echo 'proxyAddress = "::0"        # both IPv4 and IPv6
allowedClients = 127.0.0.1
socksParentProxy = "localhost:9050"
socksProxyType = socks5' | sudo tee -a /etc/polipo/config
sudo service polipo restart

# Set IP and Port on HTTP
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 127.0.0.1
gsettings set org.gnome.system.proxy.http port 8123

# Restart Tor Service
sudo service tor restart

# Install Finish
echo "Install Finished successfully…"
sleep 3
echo -e "Please type '\e[32mtail -f /var/log/tor/log\e[0m to see log." 'but see "\e[31mBootstrapped 100%: Done\e[0m"' "mean tor is \e[92mActive!"
