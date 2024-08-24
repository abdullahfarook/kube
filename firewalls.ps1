# install firewall-cmd top open ports
apt update
sudo apt-get --yes install firewalld

echo "Opening ports 8472, 10250, 51820, 51821, 5001, 6443"
firewall-cmd --zone=public --add-port=8472/udp --permanent
firewall-cmd --zone=public --add-port=10250/tcp --permanent
firewall-cmd --zone=public --add-port=51820/udp --permanent
firewall-cmd --zone=public --add-port=51821/udp --permanent
firewall-cmd --zone=public --add-port=5001/tcp --permanent
firewall-cmd --zone=public --add-port=6443/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=80/udp --permanent
# firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16
# firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16
firewall-cmd --reload
echo "Firewall configured successfully"