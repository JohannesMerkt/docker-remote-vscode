FROM ubuntu:latest

RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y unzip
# optional docker install
#RUN apt install -y docker.io

# optional docker-compose install
#RUN curl -L https://github.com/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#RUN chmod +x /usr/local/bin/docker-compose

# optional nodejs install
#RUN apt install -y nodejs
#RUN apt install -y npm

# optional deno install
#RUN curl -fsSL https://deno.land/x/install/install.sh | sh
#ENV DENO_INSTALL="/root/.deno"
#ENV PATH="$DENO_INSTALL/bin:$PATH"

RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]