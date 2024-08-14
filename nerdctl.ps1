# download and extract containerd
wget https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.20-linux-amd64.tar.gz
rm containerd-1.7.20-linux-amd64.tar.gz

# download and extract cni plugins
mkdir -p -m 755 /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.1.tgz
rm cni-plugins-linux-amd64-v1.5.1.tgz

# download ans install runc
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
rm runc.amd64

# configure containerd
mkdir -m 755 /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

# start containerd
systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd

# download and install nerdctl
wget https://github.com/containerd/nerdctl/releases/download/v1.7.6/nerdctl-1.7.6-linux-amd64.tar.gz
tar -zxf  nerdctl-1.7.6-linux-amd64.tar.gz nerdctl
mv nerdctl /usr/local/bin
rm nerdctl-1.7.6-linux-amd64.tar.gz
nerdctl --version