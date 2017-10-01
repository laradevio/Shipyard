#! /bin/bash

# This is the main Shipyard entrypoint for using it. The purpose
# of this file is to ask the user some questions to properly
# configurate Laravel Shipyard for using inside the OS.

# Laravel Shipyard Initialization Script
# Version 1.0.20170901A

printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Welcome to Laravel Shipyard!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
  We are gonna ask some questions to properly setup Laravel Shipyard
  in your system. It won't take more than 1 minute. Let's start!

~~~~~~~~~
"

#
# Environment File Detection
#

if [ -f ./.env ]; then 
	printf "
    (( Caution! )))
    ~~~~~~~~~~~~~~~
    We found a '.env' file present. We will edit this file.
    If you are not sure, remove it (or backup it) and
    run this script again.
    ~~~~~~~~~~~~~~~
    (( Caution! )))
\n"
	read -rsp $'Press any key to continue...\n' -n1 key
else 
	cp ./.env.example ./.env
fi

#
# Docker Detection
#
if ! env | grep -q "docker\|Docker" ; then
	printf "
    (( Caution! )))
    ~~~~~~~~~~~~~~~
    It seems that Docker is not installed in your system
    Please install from https://www.docker.com to use
    Laravel Shipyard after the script finishes.
    ~~~~~~~~~~~~~~~
    (( Caution! )))
\n"
	read -rsp $'Press any key to continue...\n' -n1 key
fi

#
# OS Detection
#
os=unknown
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        os='Linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
        os='MacOS'
elif [[ "$OSTYPE" == "cygwin" ]]; then
        os='Windows'
elif [[ "$OSTYPE" == "msys" ]]; then
        os='Windows'
fi
os_selected=true

printf "
~~~~~~~~~
    It seems we are under '$os'. Is that correct?
"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) printf "\nGood!\n" ; break;;
        No ) os_selected=false; break;;
    esac
done

if [[ "$os_selected" == false ]]; then
	printf "\n~~~~~~~~~\n   What OS do you plan to use Laravel Shipyard? \n"
	select wml in "Windows" "MacOS" "Linux"; do
		case $wml in
			Windows ) os='Windows'; break;;
			MacOS ) os='MacOS'; break;; 
			Linux ) os='Linux'; break;;
		esac
	done
fi

#
# OS Fixes -- MacOS
#
if [[ "$os" == "MacOS" ]]; then 
	printf "Adding :delegated fix."
	sed -i "s/^DELEGATED_MOUNT=.*/DELEGATED_MOUNT=:delegated/" .env
fi

#
# OS Fixes -- Windows
#
if [[ "$os" == "Windows" ]]; then
	printf "Adding volume fix for MariaDB, Beanstalkd & PostgreSQL."
	sed -i "s/^DATA_VOLUME_TYPE=.*/DATA_VOLUME_TYPE=volume/" .env
	sed -i "s/^DATA_SOURCE_STRING=.*/DATA_SOURCE_STRING=data_/" .env
	printf "Adding 'winbackup' container"
	bash ./.commands/shipyard/winbackup.sh
fi

#
# Locate the Project Path
#
project_path=false
printf "
~~~~~~~~~
    What is your Laravel project path? (relative to Shipyard or absolute)
    If the directory doesn't exist, we will create it for you.
"
select lp in "Next To Shipyard (../laravel)" "Other"; do
	case $lp in
		"Next To Shipyard (../laravel)" ) project_path='../laravel'; break;;
		"Other" ) project_path='custom'; break;;
	esac
done

if [[ "$project_path" == 'custom' ]]; then
	printf "\n~~~~~~~~~\n    Enter the path of your Laravel project: \n"
	if [[ "$os" == "Windows" ]]; then
		printf "\n    Use '/c/Users/MyUser' under Windows to reference partitions \n"
	fi
	read project_path
fi

printf "
    Your Laravel project path will be: $project_path
"

if [ ! -d project_path ]; then
	mkdir -p project_path
fi

if [ -z "$(ls -A $project_path)" ]; then
   printf "/n    Use './warehouse laravel new' to create your project."
fi

project_path_sed_temp=${project_path//\./\\\.}
project_path_sed=${project_path_sed_temp//\//\\\/}

sed -i "s/APP_PATH=.*/APP_PATH=$project_path_sed/" .env

#
# Custom Server Name
#
server_name=false
cert_domain=false

printf "
~~~~~~~~~
    Do you want to access using a custom server name?
"

select nyy in "No, just use 'localhost'" "Yes, use '*.shipyard.localhost' subdomain" "Yes, use '{myservername}.localhost' domain"; do
	case $nyy in
		"No, just use 'localhost'" )
			server_name='localhost'
			sed -i "s/^SERVER_NAME=.*/SERVER_NAME=$server_name/" .env
			cert_domain=false
			full_server_name='https://localhost'
		break;;
		"Yes, use '*.shipyard.localhost' subdomain" ) 
			read -p "Enter your subdomain name (.shipyard.localhost): " server_name
			sed -i "s/^SERVER_NAME=.*/SERVER_NAME=$server_name\.shipyard\.localhost/" .env
			full_server_name="https://$server_name.shipyard.localhost"
		break;; 
		"Yes, use '{myservername}.localhost' domain" )
			read -p "Enter your 'domain name' (.localhost): " server_name
			sed -i "s/^SERVER_NAME=.*/SERVER_NAME=$server_name\.localhost/" .env
			sed -i "/^DNS\.6.*/,/^/d" ./.secrets/openssl-server.conf
			sed -i "/^DNS\.7.*/,/^/d" ./.secrets/openssl-server.conf
			printf "\nDNS.6 = $server_name.localhost" >> .secrets/openssl-server.conf
			printf "\nDNS.7 = *.$server_name.localhost" >> .secrets/openssl-server.conf
			printf "\nAdded '$server_name.localhost' to your OpenSSL Certificate config file \n"
			full_server_name="https://$server_name.localhost"
		break;;
	esac
done

printf "
    Your Application will be accesible at $full_server_name
"

#
# Certificates Search
#
printf "
~~~~~~~~~
    We are gonna create random 2048-bit OpenSSL certificates for
    development under HTTPS without hindering performance.
    Use them only for development, as they are insecure!
\n"

read -rsp $'\nPress any key to continue...\n\n' -n1 key

if [[ -f ./.secrets/ssl/certs/shipyard-ca-cert.pem || -f ./.secrets/ssl/certs/shipyard-server-cert.pem ]]; then
	printf "\n
    (( Caution! )))
    ~~~~~~~~~~~~~~~
    We found some CA Certificates. Do you want to overwrite them?
	
	Select 'No' if you are unsure. You can use OpenSSL to check
	them and use '.shipyard --newssl' later to replace them.
    (( Caution! )))
    ~~~~~~~~~~~~~~~
\n"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) cert_create=true; break;;
			No ) cert_create=false; break;;
		esac
	done
else 
	cert_create=true
fi

if [[ "$cert_create" == true ]]; then

	if [[ ! -d .secrets/ssl/ || ! -d .secrets/ssl/certs ]]; then
		mkdir -p .secrets/ssl/certs
	fi
	
	if [ ! -f .secrets/ssl/newssl.log ]; then
		touch .secrets/ssl/newssl.log
	fi
	
	if [ ! -f .secrets/ssl/dhparam.pem ]; then
		printf "##########################################\n$(date -u)\n" &>>.secrets/ssl/newssl.log
		openssl dhparam -dsaparam -out .secrets/ssl/dhparam.pem 2048 &>>.secrets/ssl/newssl.log
		printf "##########################################\n\n\n" &>>.secrets/ssl/newssl.log
	fi
	
	bash ./.commands/shipyard/newssl.sh
fi

#
# End
#
printf "
~~~

That's all folks!

- Install the CA Certificate inside '.secrets/ssl'
- Develop your application under '$project_path'
- Access with your browser at '$full_server_name'

Go and have some fun ;)

~~~
"

exit










