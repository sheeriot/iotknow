+++
title = 'AWS Quick VM'
date = 2024-05-21
draft = false
weight = 1
aliases = ['/aws-vmone']

# featured_image = '/lorawan/diagrams/structurizr-1-LoRaWAN.png'

[params]
    author = 'Kris Thompson'
+++

## Create a VM

Create a very small VM in your new account. Start with a 't3.nano' vm instance, from the free-tier.

Note AWS likes the term "Instances". We will call it a VM (virtual machine).

Generate a new SSH Key Pair and save your new SSH Private Key to your local ~/.ssh folder.

Setup your new host in your ~/.ssh/config file, e.g.

```config
Host aws.one
  HostName ec2-54-242-33-159.compute-1.amazonaws.com
  User ec2-user
  IdentityFile ~/.ssh/id_awskeyone
```

Now you can simply SSH to `aws.one`.
This new host (vm) is now availble to VS Code in Remote Host Explorer.

![VS Code - Remote Explorer](../images/vscode-remoteexplorer.png)

### Create a New SSH Key-Pair

After connecting to the new host with SSH (passwordless), create a new local Private/Public SSH Key-Pair.

```bash
ssh-keygen -t ed25519
```

Note that RSA keys are obsolete and ed25519 are the way to go.

Edit the Pub key (filename ends in .pub) to use a better label (at end). The `label` will be seen in other systems such as GitHub.

Copy the new Pub key to GitHub or other location as needed to permit key-based SSH connections.

Use this new dev directory as needed for development.

Here the public key from the new VM is seen in GitHub (> Settings > SSH Keys.)

* [https://github.com/settings/keys](https://github.com/settings/keys)

![GitHub Key Added](../images/github-keyadded.png)

### Create a Dev Directory and Clone a Repository

Create a Dev directory.

```bash
mkdir dev
cd ~/dev
git clone git@github.com:sheeriot/AwsVmDeploy.git
```

### Add Git if Needed

* [https://medium.com/@dassandeep0001/how-to-install-git-in-ec2-instance-1bfeb1cc9dc9](https://medium.com/@dassandeep0001/how-to-install-git-in-ec2-instance-1bfeb1cc9dc9)

```bash
sudo yum update -y

sudo yum install git -y

git —-version

git config —-global user.name “Your Name”
git config —-global user.email “your_email@example.com”
```
