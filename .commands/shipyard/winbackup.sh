#!/bin/bash

#
# Under Windows we need to add a new container with the sole purpose of
# backup the Data Volumes for PostgreSQL, MariaDB and Beanstalkd.
#

sed -i 's/### -- Backup Container for Windows goes here --/\
  ### Windows Backup Container ###############################################\n\
  winbackup:\
    container_name: shipyard_data\
    image: alpine:latest\
    command: ["tar", "-czvf", "\/backup\/backup\.tar\.gz", "\/data"]\
    volumes:\
      - type: bind\
        source: \.\/\.winbackup\
        target: \/backup\
      - type: volume\
        source: data_mariadb\
        target: \/data\/mariadb\
      - type: volume\
        source: data_postgresql\
        target: \/data\/postgresql\
      - type: volume\
        source: data_beanstalkd\
        target: \/data\/beanstalkd\
/g' docker-compose.yml
