## PHP Dockerfile


This repository is used to build PHP Docker images. It is used by the [Docker automated build service](https://registry.hub.docker.com/u/inclusivedesign/php/).

Currently the following tags are used:

* `latest` (default): PHP 5.4 (alias to `5.4`)
* `5.4`: PHP 5.4


### Base Docker Image

* [inclusivedesign/centos:7](https://registry.hub.docker.com/u/inclusivedesign/centos/)


### Download

    docker pull inclusivedesign/php

#### Run `php -v`

    docker run -it --rm inclusivedesign/php php -v