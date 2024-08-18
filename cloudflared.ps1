# Guide to setup Cloudflare Tunnel to expose kubernetes cluster to the internet
# Goto https://one.dash.cloudflare.com

# Step 1: Create Cloudflare Tunnel and get the token
# Create a Tunnel
# Tunnels > Create Tunnel > Select Cloudflared > Tunnel Name > Token

# Step 2: Install Cloudflared on Kubernetes cluster server
# Use token to setup tunnel on Kubernetes cluster server
# sudo nerdctl run --network host -d --restart unless-stopped --name cloudflared cloudflare/cloudflared:latest tunnel --no-autoupdate run --token <token>


# Step 3: Setup public hostname on tunnel
# Click on service Type: HTTPS
# Configure TLS settings: Origin Server Name: kube.metaphorltd.com
# Origin Server Name: kube.metaphorltd.com
# No TLS Verify: Checked
# Now create a hostname with following configurations
# Subdomain: kube
# Domain: metaphorltd.com
# Type: TCP
# URL: localhost:6443

# Step 4: Setup Secret based authentication
# Goto: Access > Service Auth > Create Service Token
# Create a service token with following configurations
# Name: dev
# Expiry: 1 year
# Copy Client ID and Secret

# Goto: Access > Applications > Add an Application > Self Hosted 
# Setup the application with following configurations
# Application Name: kube
# Subdomain: kube
# Domain: metaphorltd.com
# Settings: 
#   => HttpOnly: Checked
#   => HTTPS: Enable automatic cloudflared authentication

# Goto: Access > Applications > kube > Policies > Add a Policy
# Create a policy with following configurations
# Name: kube
# Action: Service Auth
# Include
#   => Service Token: dev

# Step 5: Two Factor Login in Cloudflare Tunnel
# Goto Access > Applications > kube > Policies > Add a Policy
# Create a policy with following configurations
# Name: kube-login
# Action: Allow
# Include: 
#   => Login Method: One-Time PIN

# Step 6: Setup Cloudflare Tunnel on local machine
# winget install --id Cloudflare.cloudflared
# cloudflared tunnel login

# Step 7: Access Kubernetes cluster
# cloudflared tunnel create kube --url tcp://localhost:6443

# Step 8: Access SSH using MobaXterm
# Hostname: kube.metaphorltd.com
# Port: 22
# Username: <username>
# Network Settings:
# Proxy Type: Local 
# Local Proxy Command: cloudflared access ssh --hostname ssh.metaphorltd.com