# Optimize our time to ship features Challange

"In a world of hulk stacks we can have a pool of servers that hold the app to assure a high availability, deploying the app to this pool is one of the common challenges in site reliability engineering.

We would like to optimize the deploy-time of the app by building it first on one machine then rsync the finale build to other stack machines."

## Requirements

-   Docker
-   Docker Compose
-   Ansible
-   OpenResty Docker Image
-   PHP-CLI Docker Image

## Environment

<img src="./arch-env.png">

all components are docker containers, we chose app #1 (app_container_1) as the build machine

The project is structured as follows

```
.
├── ansible
│   ├── bootstrap-env.yml
│   ├── config
│   ├── docker-down.yml
│   ├── docker-up.yml
│   ├── release.yml
│   └── youcan
├── app
│   └── index.php
├── arch-env.png
├── docker-compose.yml
├── Dockerfile
├── nginx
│   ├── Dockerfile
│   ├── proxy.conf
│   └── rev-proxy.conf
├── README.md
└── terraform
    ├── main.tf
    ├── providers.tf
    ├── terraform.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf

```

-   in the **ansbile** dir, we have 2 playbooks, the order of running these two is important, first we run the **bootstrap-env.yml** playbook, then when we have changes mad in app we run the **release.yml** playbook, note that we have also other file like config which is SSH config file for automatic ssh access when using `rsync`
-   in the **app** dir, we have the source code of the application.
-   the **nginx** dir, holds the configuration for reverse proxy of openresty container named **proxy.conf** and the Dockerfile to build the appropiate image.
-   and in the dir we have **docker-compose.yml** file that have all the 4 app services and the openresty reversy proxy configurated and attached to the same network so that they can communicate.

## Steps

-   Clone repo to you local machine
-   make sure port 8090 is avaible for use
-   run `docker-compose up -d` command
-   make sure you are in the ansible dir, run the boostrapping script `ansbile-playbook bootstrap-env.yml`

## Solution

The expected solution talks about using rsync as the utility to sync files between apps, this is what is implemented in this repo, when changes are made to the app, we can run the **release.yml** ansible playbook and the script will copy the app into the app (in case of sophistiacted php app build the app) and then sync the final result to other apps.

There are solutions to this problem:

-   use **NFS-based volumes**, if the app is stateless its release can be stored in a shared volumes and all app containers can mount it and use it.
-   use **disrtibuted file systems** like Gluster, BTRFS, Ceph, these fs has replacation features making them usefull for these kind of situations,
-   use **docker copy feature**, the copy feature can be used in a scripted way to replicate the final release to all containers if the build/artifcated existed outside the containers (docker host machine)
-   use **scheduling feature in docker or os-level**, to pull,build, and release application then replicate to other app containers using one of the above methods.

## How can we rollout changes to production with zero downtime?

we can ship features to production using **Blue-Green Deployment** technique, in which blue represents the current production environment, we provision an identical environment of production (a plus is having production environment configuration saved as code) called green environment, in which we deploy a new application with the new features, we can use HAProxy to redirect traffic to the new green env, we can just to redirect all or a portion of users, and we monitor system and application performance metrics to track if there is a bug/downtime, if nothing happens, there will be users still connected to blue env, we should wait until sessions expire, and then we can decommission the blue environment. if not we can always redirect traffic back to blue environment.
