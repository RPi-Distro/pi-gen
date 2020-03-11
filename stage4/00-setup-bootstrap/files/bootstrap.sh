#!/usr/bin/bash -e

echo "Begining pikube bootstrapping"

if [ ! -f "/boot/pikube.tar.gz" ];then
    echo "Error: unable to find /boot/pikube.tar.gz" | tee /var/pikube.status
    exit 1
fi

root_dir=/opt/pikube
conf_dir=$root_dir/conf

mkdir -p $conf_dir
tar -xzf /boot/pikube.tar.gz -C $conf_dir

if [ -f "$conf_dir/hostname" ];then
    echo "Updating hostname" | tee /var/pikube.status
    old_hostname=$(hostname)
    new_hostname=$(cat $conf_dir/hostname)
    hostnamectl set-hostname $new_hostname
    sed -i "s/${old_hostname}/${new_hostname}/g" /etc/hosts
fi

echo "Disabling swap" > /var/pikube.status
dphys-swapfile swapoff
dphys-swapfile uninstall
systemctl disable dphys-swapfile

# TODO: VARIABLE EXAPNSION ON USERNAME
user=USER_NAME
if [ -f "$conf_dir/ssh.pub" ];then
    echo "Installing ssh key" | tee /var/pikube.status
    mkdir -p /home/$user/.ssh
    cp $conf_dir/ssh.pub /home/$user/.ssh/authorized_keys
    chown $user:$user /home/$user/.ssh/authorized_keys
    chmod 644 /home/$user/.ssh/authorized_keys
    passwd --delete kube 
fi


if [ -f "$conf_dir/ca.crt" ];then
    echo "Installing CA certificate" | tee /var/pikube.status
    cp $conf_dir/pki/ca.crt /usr/local/share/ca-certificates/kubernetes.crt
    update-ca-certificates
fi

if [ -f "$conf_dir/kube.yaml" ];then
    echo "Applying kubernetes config" | tee /var/pikube.status

    if [ -d "$conf_dir/pki" ];then
        mkdir -p /etc/kubernetes/pki
        cp $config_dir/pki/* /etc/kubernetes/pki
    fi

    kubeadm init --config conf/kube.yaml

    # setup the kube config for the kube user
    mkdir -p /home/kube/.kube
    sudo cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
    sudo chown $user:$user /home/kube/.kube/config

    # install weave network
    kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
fi

echo "Initialized" > /var/pikube.status

systemctl disable pikube-bootstrap
sleep 120
reboot