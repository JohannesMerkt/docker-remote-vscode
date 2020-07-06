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

## Using Docker inside Docker

You might want to use docker in your development enviroment. For this commend out the corresponding sections in the dockerfile to install docker. 

But thats not all! This installation only makes sure that you have the needed binaries. The docker deamon will not work however. To get it running properly you should mount the docker deamon of your host machine! 
Read More Here: https://tutorials.releaseworksacademy.com/learn/the-simple-way-to-run-docker-in-docker-for-ci#:~:text=Building%20Docker%20containers%20with%20Jenkins%20inside%20a%20container&text=Note%20that%20the%20key%20here,same%20location%20inside%20the%20container.&text=Caveat%3A%20The%20Docker%20daemon%20running,client%20binaries%20you%20are%20installing.

Your docker run command needs to be extended with a extra volume mount

```
-v /var/run/docker.sock:/var/run/docker.sock
```

Your full run command could look something like this:

```
docker run -d -p 32200:22 -v /var/run/docker.sock:/var/run/docker.sock -v yourFilePath:/home --name vscode_dev vscode_dev_img
```

### Different on a Synology NAS

You will quickly realize you wont be able to mount this volume on the first creation neither from the user interface nor with ssh.

In the user interface you wont be able to select the folder for a volume mount. This route is not available.

Via SSH you can get root access with 

```
sudo -i
```

Then the command should work. And docker too.

#### If Container already exists on synology

Stop the container. SSH into your synology. And find out the container ID with:

```
docker container list -a
```

Look for the container name and write down the container id. Now you need to get root access with

```
sudo -i
```

navigate to your containers config file:

```
cd /volume1/@docker/containers/<THE CONTAINER ID HERE>
```

We need to edit the config.v2.json file and add the volume mount. Sadly we can only use the vi editor for this and the config file is unformatted. We need to be very careful!

Open the config file with

```
vi config.v2.json
```

Hit the letter i to get into insert mode. And navigate to the section:

```
"MountPoints":{
```

After that we need to insert our volume mount:

```
"/var/run/docker.sock": {
    "Source": "/var/run/docker.sock",
    "Destination": "/var/run/docker.sock",
    "RW": true,
    "Name": "",
    "Driver": "",
    "Type": "bind",
    "Propagation": "rprivate",
    "Spec": {
    "Type": "bind",
    "Source": "/var/run/docker.sock",
    "Target": "/var/run/docker.sock"
    },
    "SkipMountpointCreation": false
},
```

I suggest to copy this and paste it right after the opening curly brace after "MountPoints"

to save and quit first press ESC to enter command mode then you can type :wq and hit enter

In order for these changes to take effect restart your synology nas and the you can start the container again.
