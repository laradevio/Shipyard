#!/usr/bin/with-contenv sh

# Copy our Shipyard SSL CA Certificate to the Container
#/bin/cp -rfuap /secrets/ssl/certs/cacert.pem /etc/ssl/cacert.pem
/bin/cp -rfuap /secrets/ssl/certs/shipyard-ca-cert.pem /etc/ssl/shipyard-ca-cert.pem
# Symlink it to the CA Certificates Directory
/bin/ln -s /etc/ssl/shipyard-ca-cert.pem /usr/share/ca-certificates/shipyard-ca-cert.pem
# Add it to the store file
echo "shipyard-ca-cert.pem" >> /etc/ca-certificates.conf
# Update all the certificates 
/usr/sbin/update-ca-certificates --fresh