# Laravel Shipyard

- [Introduction](#introduction)
    - [Pros and Cons](#pros-and-cons)
    - [Requirements](#requirements)
    - [Included Software](#included-software)
- [Installation & Setup](#installation-and-setup)
    - [First Steps](#first-steps)
    - [Docker Setup](#docker-setup)
    - [Downloading the Blueprint](#downloading-the-blueprint)
    - [Starting Shipyard](#starting-shipyard)
- [Shipyard Warehouse](#shipyard-warehouse)
    - [Tools](#tools)
    - [Warehouse Commands](#warehouse-commands)
    - [Other Commands](#other-commands)
    - [Envoy](#envoy)
    - [SSH](#ssh)
    - [HTTPS](#https)
- [Shipyard Speaker](#shipyard-speaker)
- [Shipyard Steward](#shipyard-steward)
    - [Included Process Workers](#included-process-workers)
    - [Cron Jobs](#cron-jobs)
    - [Editing Process Workers](#editing-process-workers)
    - [Beanstalkd](#beanstalkd)
- [Configuring Shipyard](#configuring-shipyard)
    - [Application Path](#application-path)
    - [Server Name](#server-name)
    - [Restarting a Container](#restarting-a-container)
    - [Persisting Data](#persisting-data)
    - [HTTPS](#https)
    - [PHP Extensions](#php-extensions)
    - [Enabling xDebug](#enabling-xdebug)
    - [Mail](#mail)
- [Sharing Shipyard](#sharing-shipyard)
- [Modifying Shipyard](#modifiying-shipyard)
    - [Services](#services)
    - [Network Interfaces](#network-interfaces)
    - [Ports](#ports)
    - [Volumes](#volumes)
    - [Multiple Containers of one Service](#multiple-containers-of-one-service)
    - [Adding Warehouse Tools](#adding-warehouse-tools)
- [Shipyard Status](#shipyard-status)
    - [Logs](#logs)
- [Deployment](#deployment)
- [Mac Performance](#mac-performance)
- [About Preinstalled Software](https://github.com/DarkGhostHunter/shipyard/wiki/About-the-preinstalled-software)

<a name="introduction"></a>
## Introduction

Laravel Shipyard is a modular, lightweight, and machine-agnostic PHP development environment built on top of [Docker](https://www.docker.com/). It allows software to be run in a very simple and efficient way through isolation instead of full virtual machines, and doesn't require great compiling times or big downloads.

With some minimal configuration, you can easily expand Laravel Shipyard to fit your needs with new software, or share your environment to other computers. It has all the common tools and software *containerized* so its not necessary to install anything on the host system. On top of that, you can update, modify or re-create all or part of it in mere seconds. And you may want to never look back!

<a name="pros-and-cons"></a>
### Pros and Cons

Why you should use Shipyard instead of [Laravel Homestead](https://laravel.com/docs/master/homestead) or your own system? And why you shouldn't?

Long story short: If you are not comfortable with Homestead or your own system, or you don't want to install anything in your system, then give Shipyard an go, as it provides more flexibility and efficiency. Say goodbye to big VMs and unconfigurable XAMP stacks.

#### Advantages
- Granularity: Nginx, PHP, Node.js, Redis, MySQL and all other software separated from each other, and the resources of your system.
- Isolation: Software runs apart from the system and other processes, and only communicate by internal network ports or specific volumes.
- Maintenance: Service containers can be updated in just seconds, without losing their configuration.
- Efficiency: It's not necessary to have full-fledged Virtual Machines and large images to run every software.
- Independency: Software dependency is resolved in each Service Container, not globally.
- Transparency: Logs, shared resources and building instructions are exposed to the user in every container.
- Control: Every Service can be rebuilt fresh, and modified without losing build changes.
- Sharing: Take it to other computer with no hassle by only copying some files.
- Modularity: You can add your own services, or spawn more containers of the same services without tampering others.
- Recycling: Containers can be based on other containers, so it's not needed to reinvent the wheel or build everything again.
- Forking: You can have your own modified Shipyard with its blueprints to suit your needs.

#### Disadvantages
- Novelty: Getting around of Containers versus the-classic-VM-way can be very confusing and daunting at first.
- Unfamiliarity: If to your deployment server is not based on the Containers concept, it's adds almost nothing past development.
- Virtualization: On Windows and Mac there are some *minor* caveats, the first being a tiny VM running for Docker.
- Deployment: Lot of work that must be done to prepare Laravel Shipyard to push a button and deploy to an **unmanaged server** with security, monitoring and resilience in mind.

If you feel left out, you can read [Docker Overview](https://docs.docker.com/get-started/#a-brief-explanation-of-containers) to have a glance about how Laravel Shipyard works.

<a name="requirements"></a>
### Requirements

Laravel Shipyard runs natively on Linux. On other OS it will require proper virtualization-enabled hardware for Docker. Thus, the requirements for Shipyard are the same for Docker:

- Windows 10 Pro/Enterprise/Education with [Hyper-V Enabled](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v).
- OS X El Capitan 10.11 or later, Mac 2010 or newer.
- CentOS, Debian, Fedora or Ubuntu.

Apart from that, OpenSSL and Git commands available for first-time initialization. Windows users can download [Git for Windows](https://git-scm.com/download/win) and permanently use Git Bash shell for simplicity, as they may have a hard time using Powershell.

> {tip} Older Mac and Windows users can still install Laravel Shipyard using [Docker Toolbox](https://www.docker.com/products/docker-toolbox) which includes VirtualBox, but is considered legacy and some things are not guaranteed to work completely.

<a name="included-software"></a>
### Included Software

Software | Description
--- | ---
Portainer | Docker Management Web UI
Git | Version Control System
PHP 7.1 | Hypertext Preprocessor. <br>Includes: [xDebug](https://xdebug.org/)
Nginx | High-performance HTTP server
MySQL | Oracle open-source RDBMS
MariaDB | Maria Foundation open-source MySQL-compliant RDBMS
PostgreSQL | Postgre Object-RDBMS
SQlite 3 | Self-contained SQL Database
Composer | PHP Package Manager
Node.js | JavaScript runtime and interpreter. <br>Includes: [YARN](https://yarnpkg.com), [Express](https://expressjs.com/) and [Vue-Cli](https://github.com/vuejs/vue-cli)
Redis | In-memory data structure store
Socket.io | Realtime application framework
Beanstalkd | Fast work queue
Mailhog | Web and API based SMTP testing for E-Mails

> {note} These containers are based from their official repositories, using `alpine` variants when possible, and [S6 Overlay](https://github.com/just-containers/s6-overlay).

<a name="installation-and-setup"></a>
## Installation & Setup

<a name="first-steps"></a>
### First Steps

Before building Laravel Shipyard, you must first [install Docker](https://store.docker.com/search?type=edition&offering=community). Select your operating system, install, and Docker should be up and running in seconds.

<a name="docker-setup"></a>
### Docker Setup

Docker runs natively in Linux. Meanwhile, on Windows or MacOS, it runs transparently using a modified Virtual Machine called MobyLinuxVM. After setup, be sure to share the drive or volume where your Application lies so MobyLinuxVM and the underlying containers will be able to mount the contents when requested.

> {note} Windows users should be aware to allow the newer network made as "Private" instead of "Public", and allow *File Sharing* on Private Networks.

<a name="downloading-the-blueprint"></a>
### Downloading the Blueprint

Once Docker is installed and running, the next step is to download the blueprint of Laravel Shipyard by cloning the Git repository and going inside once completed. We are gonna use our *home* directory in this example:

    cd ~
    
    git clone https://github.com/darghosthunter/shipyard.git Shipyard
    
    cd Shipyard
    
You should check out a tagged version of Shipyard since the `master` branch may not always be stable. You can find the latest stable version on the [GitHub Release Page](https://github.com/laravel/shipyard/releases):

    git checkout v0.9
	
<a name="starting-shipyard"></a>
### Starting Shipyard

Let's initialize our environment.

    ./shipyard.sh

Shipyard will ask you some questions, like if we are in the correct OS, if you have already the path of an Application ready to be served, if you want a custom Server Name, and so on. Just follow the prompts to populate your Shipyard's `.env` file automatically and generate some CA certificates that we will need in the future.

After you're done, it's time to start the containers. This will take some minutes, but is only made once. 

    docker-compose up -d

Alternatively, you can build *only the containers you need* by just pointing out their service names. For example, you can quickly start up PHP, Nginx and MySQL without ever downloading and building the rest of the other containers like Mailhog or Redis, which will save you time:

    docker-compose up -d nginx mysql

Some of these containers depend on others, and these will automatically spawn. You can see in the command line above that we only called `nginx` and `mysql`, but `php` and [`warehouse`](#shipyard-warehouse) containers are built and run beforehand, which saves you some keystrokes.

    ...
    
    Starting shipyard_warehouse... done
    Starting shipyard_php... done
    Starting shipyard_nginx... done
    Starting shipyard_mysql... done
    
Laravel Shipyard is made with the concept of *dock-and-forget*. While Containers in Shipyard can be rebuilt, halted or destroyed, it's not necessary to rebuild them every time you start your Application, or destroy them before quitting Shipyard. The next time you start up your computer Docker will automatically boot, ready to type `docker-compose up -d`.

<a name="shipyard-warehouse"></a>
## Shipyard Warehouse

A special container called `warehouse` appears every time that PHP, Nginx or any Database container runs. While its building time is big compared to other containers, as it may weight ~400MB once completed, it *contains* Node.js, PHP, Git and other special software available to interact via CLI, accesible without needing to install anything in your system.

Containers only have access to themselves and the other containers volumes shared to them, and Warehouse is no exception. For this scenario, Shipyard magically shares your Application directory to a shared `/var/www` path inside Warehouse so you can run commands that affect your code like it was a normal day in the office. This is done in Warehouse and other useful containers.

<a name="tools"></a>
### Tools

The Warehouse Container has:

- Git
- OpenSSL
- SSH
- Node.js (With Yarn, Express and Vue-cli)
- MySQL CLI
- PostgreSQL CLI
- Sqlite3 CLI
- PHP 7.1
- Composer
- Laravel Installer
- [Laravel Envoy](https://laravel.com/docs/master/envoy)

<a name="warehouse-commands"></a>
### Warehouse Commands

To run a command inside the Warehouse Container, just enter Shipyard directory and precede your command with `docker exec -it --user shipyard shipyard_warehouse`. In this example we will create a new project in our empty Application project directory, install [Laravel Mix](https://laravel.com/docs/master/mix) using NPM and run a File Watcher to compile our assets on the fly. All of these without installing anything on the host OS.

    cd ~/Shipyard
    
    docker exec -it --user shipyard shipyard_warehouse laravel new && npm install && npm run watch

These commands run conveniently at `/var/www` path. Also, the results of every of these commands will be showed on your interface, and it will allow interaction if needed.

> {tip} The commands and files affected use the `shipyard` user. If that isn't what you want, you can add the `--user root` option flag.

<a name="other-commands"></a>
### Other Commands

Running commands not available in Warehouse will require to call in the container that has it. For example, to launch the PHP CLI, add the `--container=shipyard_php` option to reach that container instance:

    docker exec -it shipyard_php php -v
	
The same concepts applies to any container with CLI, like the Redis Container or the PHP Container. If you need more liberty, you can invoke `sh` to have a shell inside the container, as long is it running.

> {note} Running a command from one container to execute in other container is not supported due to container isolation.

<a name="envoy"></a>
### Envoy

Laravel Envoy comes with support out of the box, and with Shipyard, a lot of operations can be simplified to run only inside this container.

In this example we will `git pull` some files and use `artisan migrate` to set up the database only in the remote server.

    @servers(
        ['warehouse' => 'shipyard_warehouse'],
        ['remote' => '192.168.1.2']
    )
    
    @story('copy')
        git
        migrate
    @endstory

    @task('git', ['on' => 'warehouse', 'remote'])
        cd /var/www
        git pull origin {{ $branch }}
	git checkout tags/v1.0
    @endtask
    
    @task('migrate', ['on' => 'remote'])
        php /var/www/artisan migrate
    @endtask
	
Take a look at [Modifying Shipyard](#modifiying-shipyard) for more information how to deal with more servers.

<a name="ssh"></a>
### SSH

While it's better to directly invoke commands from your Host using the `warehouse` shortcut, you can use this handy command that will put you under `bash` shell:

    docker exec -it --user shipyard bash

There is no need to use SSH with passwords or keys with Shipyard, but you can still use SSH for whatever reason it may be, like allowing someone of your outside network to peep and make adjustments remotely through the `:2222` port and the default `secret` password:
    
    ssh -p2222 shipyard@localhost

Additionally, SSH Keys made on Shipyard Initialization, and you can use them adding `-i ./.secrets/ssh/id_rsa`. These are stored in your `SECRET_PATH` folder and automatically saved in the Warehouse Container once it builds. If you rebuild the container, you will have to check your `knownhosts` and remove the old Container host signature. As the nature of Linux itself, you are free to tinker and make adjustments in your Warehouse Container to make room for more users and keys, hopefully under the `shipyard` user group.

<a name="https"></a>
### HTTPS (TSL)

HTTPS and HTTP redirection comes out of the box with Shipyard. You don't have to do anything except import the Self-signed Root CA Certificate used to create the SSL Certificates for your browser or OS, that is `./.secrets/ssl/certs/shipyard-ca-cert.pem`, as a "Trusted Root Certification Authorities" or similar. This makes the browsers trust your Application HTTPS connection locally.

When Shipyard initializes, it checks if the self-signed SSL Certificates exists. If not, like it happens when you first install Shipyard, it will automatically create those so Nginx and [Shipyard Speaker](#shipyard-speaker) can pick them up to serve HTTPS. 

To rebuild and replace all the Certificates, use this handy Warehouse command:

    ./.commands/shipyard/newssl.sh

From there, you will need to delete the Certificate you installed in your system and re-add the newly generated.

> {note} There is no automatic command to gracefully disable HTTPS.

#### How it works

Shipyard makes a Self-Signed Root Certificate Authority called "Laravel Shipyard CA Certificate". Once done, instead of using this certificate for everything, it creates a "child" certificate that is later signed with the above CA. This resulting certificate is what Shipyard uses across all containers that serve HTTPS, like Nginx and Speaker.

Installing the Root CA in some containers is neccesary to validate the Child Certificate, as the Root CA doesn't validate itself using, for example, `composer` commands inside the Warehouse Container. This approach makes your `SERVER_NAME` reachable without validation errors.

<a name="shipyard-speaker"></a>
## Shipyard Speaker

Shipyard comes with two special containers for broadcasting in realtime, called Speaker and Speaker-Redis. The Speaker Container has Node.js inside running a Socket.io server and Express framework, so there is no need to install them into your Application `package.json` or install any Node modulse beforehand. Meanwhile, Speaker-Redis is just a Redis Server for persistence.

When the Speaker Container runs, it checks your project root for an `index.js` file to be ran, otherwise the container will use a default `./speaker/index.js` file. You can use this file as starting point to understand Socket.io with the default SSL configuration.

You can visit `https://shipyard.localhost:6001` to check if the Speaker Container is up and running.

> {tip} There is a [Laracast course](https://laracasts.com/series/real-time-laravel-with-socket-io) exclusive to integrating Laravel with Socket.io and Redis for your broadcasting needs.

<a name="shipyard-steward"></a>
## Shipyard Steward

Laravel Shipyard comes with a special container called `steward` in charge of constantly running background process workers under PHP.

It's not enabled by default. To bring it call the container like any other:

    docker-compose up -d steward

<a name="included-process-workers"></a>
### Included Process Workers 

This container has running the following process workers:

- [Laravel Schedule](https://laravel.com/docs/master/scheduling) (Cron)
- [Laravel Queue](https://laravel.com/docs/master/queues#running-the-queue-worker)
- [Laravel Horizon](https://laravel.com/docs/master/horizon)

These process workers have access to the Application and the Warehouse Container, as it depends on them. It uses your PHP Container as base image, so it has access to the same extensions and features, and these workers will output their logs to Docker.

Only the Laravel Queue worker is enabled by default. To enable the others, configure them properly before chaning from `false` to `true` these arguments in your `.env` file. Then, restart the container.

    STEWARD_SCHEDULER=false
    STEWARD_QUEUE=true
    STEWARD_HORIZON=false

> {note} Changes made to the Application where these Process Workers are affected may require restarting the Speaker Container.

<a name="cron-jobs"></a>
### Cron Jobs

The Steward Container eliminates the necessity to create and manage Cron Jobs, as it runs `artisan schedule:run` for convenience.

Unless you need to execute custom processes or scripts not present in the Application, or outside of the Laravel Schedule capabilities, edit the `./steward/cron.job` and restart the Steward Container to apply the changes.

> {note} Cron Jobs are restricted to your Application only. To make Cron Jobs runnable in your Warehouse container, edit the `/warehouse/cron.job`, which is by default loaded but empty.

<a name="editing-process-workers"></a>
### Editing Process Workers

All of the Laravel's process workers are defined in the `run` file inside `./steward/rootfs/etc/services.d` folder. You can change these how the shell command calls these workers how you see fit, and then rebuilding the container:

    docker-compose up -d --build steward
    

<a name="beanstalkd"></a>
### Beanstalkd

While a PHP Worker may suffice for small and simple queue system, you may want to use a dedicated worker for your important queues instead of relying solely in PHP.

In this regard, Beanstalkd is good for managing general and simple queues for processes inside your Laravel Application, with very little overhead compared to Redis or a Database. Just point Laravel to the container, fire it up and you are good to go:

    docker-compose up -d beanstalkd
    
In the Queue Worker area, you are free to use other Queue Workers for specific workloads, that may ease your Application overhead. For example, you can use a Message Queue to handle sending Emails, SMS and other Notifications through your Application instead of relying in Databases, Redis or Beanstalkd. 

> {note} Be sure to disable Laravel Queue in your `.env` file if you plan to use external Queue Workers so they don't overlap.

<a name="configuring-shipyard"></a>
## Configuring Shipyard

Laravel Shipyard comes with the familiar `.env` file with some default configuration, which behaves similar to the [Application environment file](https://laravel.com/docs/master/configuration#environment-configuration). The values inside are passed to our `docker-compose.yml` every time you start or build containers.

Connecting your Application to the Shipyard containers, like MySQL or Redis, is done by pointing up the name of the Service. That way you don't have to wander around for the correct IP or making custom aliases for every container. For example, let's connect our Application to our MariaDB Service editing our Application `.env` file:

    DB_CONNECTION=mysql
    DB_HOST=mariadb
    DB_PORT=3316
    DB_DATABASE=default
    DB_USERNAME=shipyard
    DB_PASSWORD=secret
    
There is no problem if we want to connect by directly pointing the instance of container, like so:

    DB_HOST=shipyard_mariadb
    
The names of all Services and the instance containers are declared in `docker-compose.yml` below the `services:` tree.

<a name="application-path"></a>
### Application Path

By default, Laravel Shipyard looks for your `Laravel` directory alongside it. Once created if not found, the contents of it will be mounted to `/var/www` under the Nginx container, and it will serve `/var/www/public` by default.

You can change it using an absolute path or relative path to Laravel Shipyard folder, and restart it:

    APP_PATH=../my-other-laravel-app
    
This folder will be shared synchronously, so every change in your code will be reflected instantly.
    
> {note} For Windows and Mac Users, be sure to share the drive, volume or directory where your Application resides.

<a name="server-name"></a>
### Server Name

In a fresh Shipyard installation, your application will be accessible to `http:\\localhost`. To use a custom server name, be sure to edit not only your `host` file to point to that server name, but also the `.env` file:

    APP_SERVERNAME=mylaravelapp.localhost

This change will be propagated to the Nginx Container as an Alias for it. That will be useful for connecting containers to your Server Name (like when using Tests) internally.

> {tip} [IETF](https://tools.ietf.org/html/rfc2606) states that only `.localhost`, `.test`, `.example`, and `.invalid` TLDs are privately reserved. It's recommended to use `.localhost` for any development site that points to your own local loopback address, like Shipyard does, and to **avoid using** `.dev` TLD.

<a name="restarting-a-container"></a>
### Restarting a Container

When you make changes to the `.env` or the `docker-compose.yml` files, changes won't be picked up by Shipyard unless you restart the containers affected by these changes. For example, if we just changed the `XDEBUG_IDEKEY` variable, we need to restart our `xdebug` container like so:

    docker-compose restart xdebug
    
Changes done to the built state of the container, like modifying the `Dockerfile` used to make it, will require `docker-compose up -d --build`.

<a name="persisting-data"></a>
### Persisting Data

Databases and Cache Services, like Beanstalkd, MySQL and PostgreSQL, save their data to a directory inside Shipyard. This is set in the `DATA_PATH` of our `.env` file, and you can change this directory to any as long the directory is shared to Docker:

    DATA_PATH=./.data

#### Windows Notes
In Windows, due to a permission incompatibility over shared volumes, saving data to the host is not supported on Beantstalkd, MariaDB and PostgreSQL. Shipyard's Initialization will make you use a *named volume* for persistence inside MobyLinuxVM instead, if you choose Windows as your Host OS.

Not all is lost, however. Shipyard comes with a handy and small Service Container called `winbackup`. Call it like any other and it will compress the data of these containers to a `.data-backup/backup.tar.gz` file. After that, it will exit.

<a name="enabling-xdebug"></a>
### Enabling xDegug

xDebug in Shipyard is simplified to one container running PHP with xDebug, that shares the same main PHP configuration in your `.env` file. Just fire it up:

    docker-compose up -d xdebug
    
Your main Nginx Container has one server listening to the `:9433` port, which serves PHP files to this new container. You can then connect your IDE of choice to the `:9900` port of PHP-xDebug Container to start the remote debugging.

Once you're done, it's safe to stop it using `docker-compose stop xdebug`. As always, changes made to the PHP section of your `.env` will require a restart.

<a name="php-extensions"></a>
### PHP Extensions

Setting up extension for PHP can be a mess, but the `.env` file takes care of it in the `PHP Extensions` section. This is read when PHP, Warehouse and xDebug containers are built, which dictates what packages to download from the Alpine Repository. Apart from the required extensions for Laravel to work, these are also available but not installed by default:

- SOAP
- Redis (formerly PhpRedis)
- BCMath
- Opcache

You have also liberty to modify the `Dockerfile` of xDebug, Steward and PHP to add your own extensions. These images are based on Docker Alpine, you can check the [Alpine Packages](https://pkgs.alpinelinux.org/) to look up what you need.

> {note} PHP, Steward and xDebug containers will need a rebuild to pick up the changes done to PHP Extensions variables in your `.env`.

<a name="sharing-shipyard"></a>
## Sharing Shipyard

Sharing your Shipyard environment is relatively easy.

- If you made little to no deep adjustments to Shipyard, just copy your Application Code folder along with the `.env` file of Shipyard and you are done.

- If you tinkered with the Blueprint `docker-compose.yml` or Build Instructions `Dockerfile` files, you will have to copy them. Also, it's a good idea to take into account `.data/` directory if you need to reuse persisted data.

On the destination, follow the same steps to install Docker and Laravel Shipyard, pointing out the folders you just copied in the `.env` file if necessary, and you should be done in a breeze.

<a name="modifiying-shipyard"></a>
## Modifying Shipyard

The good part of Laravel Shipyard is that is easily editable to suit your needs. You can modify a container, the base image used to create a container, spawn more containers from the same image or service, even create a new service.

<a name="services"></a>
### Services

For example, let's say we want to add [Minio Container](https://hub.docker.com/r/minio/minio/) for a File Storage server. We only need to add it as a service in our `docker-compose.yml`, like so:

    minio:
      image: minio/minio:latest
      container_name: shipyard_minio
      volumes:
        - ${APP_DATA}:/export
      ports:
        - "9000:9000"
      environment:
        - MINIO_ACCESS_KEY=shipyard
        - MINIO_SECRET_KEY=secret
      networks:
        - frontend

The full reference for `docker-compose.yml` files is in the [Docker documentation](https://docs.docker.com/compose/compose-file/). It's a good start to experiment in extending Laravel Shipyard to whatever you want, like a reverse proxy, a load balancer, a File Storage server, SFTP, a NoSQL database, a backup service, etc. If it works on your computer, it will work on others.

As a recommendation, try to use a Container for one thing only, and hopefully, one process. For example, you can start a tiny PHP Service Container holding [Adminer](https://www.adminer.org/) for tinkering with your database.

<a name="network-interfaces"></a>
### Network Interfaces

Laravel Shipyard creates two networks inside Docker's own Network Interface. One is `frontend`, and the other is `backend`. These are independent what which port a Container may expose publicly to the Host.

As the name implies, `frontend` is the network created to containers that should be publicly reachable, and the `backend` is the network that only containers should reach between them. 

When a Container is created, is also registered to be part of these networks. Containers only registered to the `frontend` network cannot see other containers registered in the `backend` network and vice versa, unless its registered in both simultaneously.

For example, Nginx is connected to the `frontend` to serve you application through the Host exposed port `:80` and `:433`, and to `backend` so it sees other containers like the PHP. By comparison, PHP doesn't have any ports exposed to the Host, and is only connected to the `backend` netowork.

You can create more Network Interfaces meddling with the `docker-compose.yml` to isolate containers from the Internet, or expose container ports to the Host if you require. Just be sure that the exposed ports don't overlap with others.

<a name="ports"></a>
### Ports

Whenever you are changing a service exposed port, or creating a new service, watch out for the exposed ports to the Host so they don't overlap in your machine and confuse your development environment. 

Exposed Port | Service | Description
---- | ---- | ---
`:80`             | `nginx`            | Application HTTP Protocol
`:433`            | `nginx`            | Application HTTPS Protocol
`:1025`, `:8025`  | `mailhog`          | Mailhog SMTP and Management GUI
`:2222`           | `warehouse`        | SSH
`:3306`           | `mysql`            | MariaDB/MySQL Database connection
`:3316`           | `mariadb`          | MariaDB/MySQL Database connection
`:4444`           | `portainer`        | Portainer Web UI
`:5432`           | `postgre`          | Postgre Database connection
`:6001`           | `speaker`          | Shipyard Speaker Socket.io Server
`:6002`           | `redis`            | Shipyard Speaker Redis server
`:6379`           | `redis`            | Redis Database connection
`:9080`, `:9433`  | `xdebug`           | xDebug Redirecirion and HTTPS Remote DBGp connection
`:11300`          | `beanstalkd`       | Beanstalkd Queue Worker

> {tip} While the Speaker Server port is configurable, it's recommended to use the `:6001` port because is already reserved, so you don't need to further edit your `.env` or `docker-compose.yml` files.

<a name="volumes"></a>
### Volumes

Volumes, when declared in the Container, creates independent persistence from the container lifetime and can be attached to a container and shared between them.

Nginx and Warehouse containers bind your Application inside `/var/www` in each of them, with read-write permissions. You can read about [Docker Volumes](https://docs.docker.com/engine/admin/volumes/) in the documentation.

<a name="multiple-containers-of-one-service"></a>
### Multiple Containers of one Service

Laravel Shipyard makes every service only bound to a unique container, thus you cannot make two Nginx containers from the same Nginx service. To remove this limitation, remove the `container_name` directive of the desired service. Next time the container is created, Shipyard will add `_1` to the default name, allowing you to create more of the same manually.

This may come in handy to spawn several containers of the same process but independent from the others, like Databases, Backups or Caches, and replicating Laravel Shipyard to serve another Application on another path.

<a name="adding-warehouse-tools"></a>
### Adding Warehouse Tools

Warehouse can be expanded with more CLI tools (or even shrank to the bare minimum). For this you can edit `./warehouse/Dockerfile` and start adding or subtracting tools not covered in Shipyard `.env`.

You will need some Linux and Docker knowledge to add new CLI tools to the Container, but the `Dockerfile` file is a good start to see how the container integrates these at build time, and the `./warehouse/rootfs/` to see how the SSH and Cron Services are set up using S6 Overlay.

<a name="shipyard-status"></a>
## Shipyard Status

By default, all the Logs generated by the containers can be easily seen using Portainer, accesible at `https://localhost:4444`. Here you can see all inner workings of Docker, like images, container, volumes, resources assigned to the containers (like CPU% and RAM) and logs.

    docker-compose up -d portainer

If you are not confortable using the command line to run, stop or destroy containers, you can check Portainer and to *almost* anything within your browser. Portainer is a great aid, but it's recommended to use the command line for everthing.

<a name="logs"></a>
### Logs

You can use Portainer or even Kitematic for this, but the quick way is using [`docker logs`](https://docs.docker.com/compose/reference/logs/) command to get the logs of a particular container in the command line:

    docker logs shipyard_nginx

If you need a more convenient logging mechanism, like saving to a file, you can edit `docker-compose.yml` and `Dockerfile` file of the container to save the logs in your Host using `bind-mount`, or to the `DATA_PATH` of your `.env`, like so:

    nginx:
      ...
      volumes:
          - ./../my-logs-folder:/var/log/nginx


> {tip} The default behavior of single-process containers is exposing its logging to the Docker system. [There are workarounds](https://docs.docker.com/engine/admin/logging/view_container_logs/) for situations where logs are not gracefully exposed, like happens with Nginx.

<a name="deployment"></a>
## Deployment

Laravel Shipyard is lightweight local development tool, and by no means a ready-to-deploy stack. If you are planning to push this to a your very own **Unmanaged Server**, consider these adjustments and additional containers before tuning drastically the production environment, that will depend on how your Application will behave:

- Secret Management for sensible information (passwords, variables, certificates, keys, usernames, etc.)
- Container Authenticity
- Container Resources Allocation
- Host and Kernel Security
- File System Performance (overlay2 vs aufs)
- Backup and Redundancy Services
- Adjusted Network Topology & Firewalls
- Restricted User Permissions
- Management, Logging and Health Monitoring 
- Static Application Code Repository
- Storage (Cache, Files, Temporal, etc.)
- Other Resilience Services (Container Orchestration, Multiple Nodes, Mirroring, Load Balancers, Reverse Proxy, etc.)

There are also Linux distributions that will take of some of these tasks, like [CoreOS Container Linux](https://coreos.com/why), [RancherOS](http://rancher.com/rancher-os/), [OSv](http://osv.io/), [Project Atomic](http://www.projectatomic.io/), [Ubuntu Core](https://developer.ubuntu.com/core) and so on, just to name a few. There's even a Framework from Docker called [Moby](https://mobyproject.org/#moby-and-docker) to develop this kind of distributions.

> {tip} If configuring all this by yourself sounds abysmal, consider using [Laravel Forge](https://forge.laravel.com), which will aid you to deploy your Application easily on your server using the proven classic way.

<a name="mac-performance"></a>
## Mac Performance

Laravel Shipyard works using the `bind-volume` mechanism for your Application code. That means, MacOS shares that directory with the underlying MobyLinuxVM by network. Some users may have problems related to writing performance as [noted by Docker](https://docs.docker.com/docker-for-mac/osxfs-caching/).

There are some workarounds, but there are one that work in most cases: adding the `:delegate` flag to the Application volume. This is done automatically when Shipyard Initializes under MacOS.

The `:delegated` directive makes the writing performed by containers **not immediately reflected** on the Host file system, thus allowing better performance on writes, like when using `composer` commands inside Warehouse.
      
If you need realtime syncronization between the container's contents and your Host, you are free to play with another workarounds, like using [Docker Sync](http://docker-sync.io/).

## [About Preinstalled Software](https://github.com/DarkGhostHunter/shipyard/wiki/About-the-preinstalled-software)
