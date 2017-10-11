#!/bin/bash

if [[ ! -d .secrets/ssl/ || ! -d .secrets/ssl/certs ]]; then
	mkdir -p .secrets/ssl/certs
fi

if [ ! -f .secrets/ssl/newssl.log ]; then
	touch .secrets/ssl/newssl.log
fi

printf "##########################################\n$(date -u)\n" &>>.secrets/ssl/newssl.log
echo 'Deleting files and certificates...'
rm -f .secrets/ssl/*index* &>>.secrets/ssl/newssl.log && \
rm -f .secrets/ssl/*serial* &>>.secrets/ssl/newssl.log && \
rm -f .secrets/ssl/certs/* &>>.secrets/ssl/newssl.log

echo 'Regenerating Index and Serial...'
touch .secrets/ssl/index.txt &>>.secrets/ssl/newssl.log  && \
printf "01" > .secrets/ssl/serial.txt

echo 'Creating CA Certificate...'
printf "\n" &>>.secrets/ssl/newssl.log
openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes -days 365 -extensions ca_extensions -outform PEM \
	-config .secrets/openssl-ca.conf \
	-keyout .secrets/ssl/certs/shipyard-ca-key.pem \
	-out .secrets/ssl/certs/shipyard-ca-cert.pem &>>.secrets/ssl/newssl.log

# openssl x509 -in .secrets/ssl/certs/shipyard.ca.cert.pem -text -noout
# openssl x509 -purpose -in .secrets/ssl/certs/shipyard.ca.cert.pem -inform PEM
	
echo 'Creating Signing Request...'
printf "\n" &>>.secrets/ssl/newssl.log
openssl req -new -sha256 -newkey rsa:2048 -nodes -days 365 -extensions server_req_extensions -outform PEM \
	-config .secrets/openssl-server.conf \
	-keyout .secrets/ssl/certs/shipyard-server-key.pem \
	-out .secrets/ssl/certs/shipyard-server-cert.csr &>>.secrets/ssl/newssl.log
	
# openssl req -text -noout -verify -in .secrets/ssl/certs/shipyard.server.req.pem
	
echo 'Signing Final Certificate...'
printf "\n" &>>.secrets/ssl/newssl.log
openssl ca -policy signing_policy -extensions signing_req -crlexts crl_ext -batch \
	-config .secrets/openssl-ca.conf  \
	-keyfile .secrets/ssl/certs/shipyard-ca-key.pem \
	-out .secrets/ssl/certs/shipyard-server-cert.pem \
	-infiles .secrets/ssl/certs/shipyard-server-cert.csr &>>.secrets/ssl/newssl.log

# openssl x509 -in .secrets/ssl/certs/shipyard.server.cert.pem -text -noout
# openssl x509 -in .secrets/ssl/certs_GOOD/servercert.pem -text -noout

	
echo 'Validating Certificate with CA Certificate...'
printf "\n" &>>.secrets/ssl/newssl.log
openssl verify -CAfile .secrets/ssl/certs/shipyard-ca-cert.pem .secrets/ssl/certs/shipyard-server-cert.pem &>>.secrets/ssl/newssl.log
printf "##########################################\n\n\n" &>>.secrets/ssl/newssl.log

echo 'Done!'
printf \
"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~    Remember to add '.secrets/ssl/certs/shipyard.ca.cert.pem'    ~
~  to your Trusted Root Certificate Authority in your OS/Browser  ~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" 
