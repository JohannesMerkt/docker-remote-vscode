# docker-remote-vscode
A docker container for remote vscode development on operating systems with no support for remote vscode.

## Background
I needed this container to work remotely on a synology NAS with vscode. Unfortunatly the Remote SSH of vscode does not work with Synologys operating system. So I created this Ubuntu based container and mounted my files from Synology.

## Getting Started

Since vscode uses ssh to connect to the server we need to have a user (root) with a password to connect to it. Within the Dockerfile I set a default password (root) that you should definetly change for security reasons! There are two ways to do it: 

- change the password within the Dockerfile and build it
- build the docker image, connect via ssh and change the password there. I prefer doing it like that since I wont have my password anywhere in plain text.

You can build the image with:

```
docker build -t vscode_dev_img - < Dockerfile
```

Once you build the image you can start it with:

before you run this command replace yourFilePath with the path to your files that you want to manipulate with vscode later on. These will be mounted to home

```
docker run -d -p 32200:22 -v yourFilePath:/home --name vscode_dev vscode_dev_img
```

now you can connect to this container with vscode or ssh on port 32200.

To set a port other than 22 in vscode click on the green corner on the bottom left of your vscode window and select "Remote-SSH: Open Configuration File...". Inside your configuration file you can add your new remote target like this:

```
Host YourDisplayedHostname
    HostName YourDomainOrIPAddress
    User root
    Port 32200
```

When you save this file your SSH Target list can be refreshed and should then display your new SSH Target. Now you can connect to your host and everthing should work.