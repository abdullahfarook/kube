# Inorder to copy content from old vm to new vm
# 1. zip the content (metaphor, red, seq) in old vm
# sudo zip -r everything.zip metaphor red seq

# 2. Copy content to new vm
# chmod 400 my-key.pem
# sudo scp -i my-key.pem everything.zip  metadmin@<vm ip>:/home/metadmin/

# 3. Unzip the content in new vm
# sudo unzip everything.zip -d /shared