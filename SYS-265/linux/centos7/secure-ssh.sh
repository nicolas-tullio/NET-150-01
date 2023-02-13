#secure-ssh.sh
#author nicolas-tullio
#creates a new ssh user using $1 parameter
#adds a public key from the local repo or curled from the remote repo
#removes roots ability to ssh in
echo Create user name?
read USERNAME
sudo useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME
sudo mkdir /home/$USERNAME/.ssh
sudo cp /home/nicolas.tullio/Tech-Journal/SYS265/linux/public-keys/id_rsa.pub /home/$USERNAME/.ssh/authorized_keys
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
