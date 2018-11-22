# Add nymea repository
echo -e "\n## nymea repo\ndeb http://repository.nymea.io stretch main raspbian\n#deb-src http://repository.nymea.io stretch main raspbian" | tee /etc/apt/sources.list.d/nymea.list
wget -qO - http://repository.nymea.io/repository-pubkey.gpg | apt-key add -

# Set repository priority (prefere packages from raspbian section
cat <<EOM >/etc/apt/preferences.d/nymea
Package: *
Pin: release c=raspbian
Pin-Priority: 700

Package: *
Pin: origin repository.nymea.io c=main
Pin-Priority: 500
EOM

apt-get update
