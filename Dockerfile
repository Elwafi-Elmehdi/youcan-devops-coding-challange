FROM php:7.2-cli
COPY ./app /usr/src/myapp
WORKDIR /usr/src/myapp
CMD [ "php", "-S 0.0.0.0:80",  "./index.php" ]