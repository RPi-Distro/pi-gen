# pikube-gen

_Tool used to create the raspberrypi.org Raspbian images_

|*If you are looking for a simple way to get started, use the [pikube cli tool](https://github.com/adamthesax/pikube-cli).*|
|-------|

pikube-gen is a fork of [pi-gen](https://github.com/RPi-Distro/pi-gen) which intends to deliver a 
simple way to setup a kubernetes cluster on a number of raspberry pi. To do so pi-kube generates a 
single Raspbian based disk image with Docker and Kubernetes pre-installed. It also contains a 
bootstraping service which will allow you to customize and secure your cluster by dropping a few 
additional files onto the boot mount.

To customize your image build further see the [customization guide](doc/customization.md)

## Usage
`pikube` ships with a docker/kubernetes pre-installed as well as a bootstrapping service which will
initialize the cluster (on join an existing one), set up SSH keys and configure your hostname.

To setup pikube:
1) Grab the image (either from grabbing a prebuilt from the releases or running `./build-docker.sh`)
2) Flash the image to your SD card
3) Create a `pikube.tar.gz` with the folowing files:
    * `hostname`: Text file containing the hostname
    * `ssh.pub` A public ssh key which will be installed into `~/.ssh/authorized_hosts` for passwordless ssh
    * `kube.yaml` A `kubeadm` config file to be run upon first boot
    * `pki/` directory of certs to be installed at `/etc/kubernetes/pki` for the master you will need the following:
        * `ca.crt`
        * `ca.key`
        * `front-proxy-ca.crt` 
        * `front-proxy-ca.key`
        * `etcd/ca.crt`
        * `etcd/ca.key`
4) Copy `pikube.tar.gz` to `/boot/pikube.tar.gz` on your SD card.