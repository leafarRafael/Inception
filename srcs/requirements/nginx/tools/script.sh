#!/bin/bash

openssl ecparam -genkey -name prime256v1 -out /tmp/nginx.key

openssl req -new -x509 -key /tmp/nginx.key\
	-out /tmp/nginx.crt -days 365 \
	-subj "/C=BR/\
			ST=Sao Paulo/\
			L=42SP/\
			OU=42SP/\
			CN=rbutzke.42.fr\
			emailAddress=rbutzke@42SP.com"