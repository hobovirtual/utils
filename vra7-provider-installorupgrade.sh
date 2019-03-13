#!/bin/bash
# ------------------------------------------------------------------------------------
#
# This script will update or install the terraform provider for vRealize Automation 7
# and it's depencies:
#                   go version:         1.11.5
#                   git version:        latest
#                   terraform version:  0.11.11
# ------------------------------------------------------------------------------------
# Server needs to have access to internet for this script to run without any 
# intervention
# ------------------------------------------------------------------------------------

# =========================== #
# local variables declaration
# =========================== #
GOROOT=/usr/local/go
GOPATH=~/go_workspace
CGO_ENABLED=0
TFWKS=~/tf_workspace

# =========================== #
# go validation
# =========================== #
DESIRED_VER=1.11.5                                                           # desired version

# check if go is installed first
if [ -d $GOROOT ]; then
    INSTALLED_VER=`go version | cut -d ' ' -f 3 | tr '/' '_' | cut -c 3-`;   # get go installed version
    # Compared the installed version vs the desired version
    if (( $(echo "$INSTALLED_VER $DESIRED_VER" | awk '{print ($1 < $2)}') )); then
        echo "go version needs to be updated, let's do this!!!";
        mv /usr/local/go /tmp/.;
        GO_INSTALL=true;
    else
        echo "installed version is matching or above minimum required version, nothing to do move on!!!";
    fi
else
    echo "go is not installed, let's install it!!!";
    GO_INSTALL=true;
fi

if [ "$GO_INSTALL" = "true" ]; then
    cd /tmp;
    wget https://dl.google.com/go/go${DESIRED_VER}.linux-amd64.tar.gz;
    tar -xzf go${DESIRED_VER}.linux-amd64.tar.gz;
    mv go /usr/local;
fi

if [ ! -z $GOROOT ]; then
    echo "export GOROOT=/usr/local/go">>~/.bashrc;
    source ~/.bashrc
    if [ ! -z $GOPATH ]; then
        if [ ! -d $GOPATH ]; then
            mkdir ~/go_workspace;
        fi
        echo "export GOPATH=~/go_workspace">>~/.bashrc;
        source ~/.bashrc
    fi
    echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH">>~/.bashrc;
    source ~/.bashrc
fi

if [ ! -z $CGO_ENABLED ]; then
    echo "export CGO_ENABLED=0">>~/.bashrc;
    source ~/.bashrc;
fi

# =========================== #
# git validation
# =========================== #

if (yum list installed git >/dev/null 2>&1); then  
    echo "git is installed, will look for update,hold on!!";
    yum update git -y; 
else
    echo "git is not installed, will look for update, let's get going!!!";
    yum install git -y; 
fi

# =========================== #
# vra7 provider validation
# =========================== #
# at the moment the provider is not versioned, so there's no way to validate if an update is required
# we're assuming that if you're running this script, you either need to install or update the provider

# make a backup of the current go workspace and create a new empty directory
if [ -d "$GOPATH" ]; then
    mv ~/go_workspace ~/go_workspace.backup`date "+%Y.%m.%d-%H.%M.%S"`;
    mkdir ~/go_workspace
fi

cd /tmp
if [ -d /tmp/terraform-provider-vra7 ]; then
    rm -fr /tmp/terraform-provider-vra7
fi
git clone https://github.com/vmware/terraform-provider-vra7.git         # download terraform provider for vra7
cd terraform-provider-vra7                                              # change directory
go build;go install                                                     # build and install project

# =========================== #
# terraform validation
# =========================== #
DESIRED_VER=0.11.11                                                          # desired version

if [ -f /usr/local/bin/terraform ]; then
    INSTALLED_VER=`terraform -v | head -n 1 | cut -d ' ' -f 2 | cut -c 2-`;      # get terraform installed version
    # Compared the installed version vs the desired version
    if (( $(echo "$INSTALLED_VER $DESIRED_VER" | awk '{print ($1 < $2)}') )); then
        echo "terraform version needs to be updated, let's do this!!!";
        mv /usr/local/bin/terraform /tmp/.;
        TF_INSTALL=true;
    else
        echo "installed version is matching or above minimum required version, nothing to do move on!!!";
    fi
else
    echo "terraform is not installed, let's install it!!!";
    TF_INSTALL=true;
fi

if [ "$TF_INSTALL" = "true" ]; then
    cd /tmp;
    wget https://releases.hashicorp.com/terraform/${DESIRED_VER}/terraform_${DESIRED_VER}_linux_amd64.zip;
    unzip terraform_${DESIRED_VER}_linux_amd64.zip;
    mv -f terraform /usr/local/bin/;
fi

# initiate terraform environment
if [ ! -d ~/.terraform.d ]; then
    mkdir ~/.terraform.d;
fi

if [ ! -d ~/.terraform.d/plugins ]; then
    mkdir ~/.terraform.d/plugins;
fi

if [ ! -f ~/.terraform.d/plugins/terraform-provider-vra7 ]; then
    cd ~/.terraform.d/plugins;
    ln ~/go_workspace/bin/terraform-provider-vra7 .;
fi

if [ ! -d ~/tf_workspace ]; then
    mkdir ~/tf_workspace;
else
    cd ~/tf_workspace
    terraform init
fi