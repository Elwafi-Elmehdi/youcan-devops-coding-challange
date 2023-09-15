FROM php:7.2-cli

COPY ./app /usr/src/myapp

WORKDIR /usr/src/myapp

ENV PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAFapJXUGlY8frZjX8YB1ElPUzxtSh2jds6fHeTnBZs youcan"

RUN apt update &&\
    apt install openssh-server rsync -y &&\ 
    apt autoclean &&\
    rm -rf /var/lib/apt/lists/* &&\
    service ssh start &&\
    mkdir -p /root/.ssh/ &&\
    echo "$PUB_KEY" > /root/.ssh/authorized_keys

CMD [ "php", "-S", "0.0.0.0:80",  "./index.php" ]
