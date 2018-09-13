echo -e "\n## nymea repo\ndeb http://repository.nymea.io stretch main\n#deb-src http://repository.nymea.io stretch main" | tee /etc/apt/sources.list.d/nymea.list
wget -qO - http://repository.nymea.io/repository-pubkey.gpg | apt-key add -
apt-get update
