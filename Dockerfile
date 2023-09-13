FROM php:7.2-cli
COPY ./app /usr/src/myapp
WORKDIR /usr/src/myapp
RUN apt update &&\
    apt install openssh-server rsync -y &&\ 
    apt autoclean &&
    rm -rf /var/lib/apt/lists/*
CMD [ "php", "-S", "0.0.0.0:80",  "./index.php" ]
