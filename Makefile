# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: rbutzke <rbutzke@student.42sp.org.br>      +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/02/28 12:33:11 by rbutzke           #+#    #+#              #
#    Updated: 2025/08/01 20:15:57 by rbutzke          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


VOLUME_WORDPRESS=/home/${USER}/data/wordpress-volume
VOLUME_DATABASE=/home/${USER}/data/database-volume
VOLUME_DATA=/home/${USER}/data

all: \
	check_env \
	environment \
	up

up:
	docker compose -f ./srcs/docker-compose.yml up -d;

environment: \
	check_data_directory \
	check_database_directory \
	check_wordpress_directory \
	check_domain_in_hosts

check_database_directory:
	@if [ ! -d $(VOLUME_DATABASE) ]; then \
		mkdir -p $(VOLUME_DATABASE) ;\
		chown -R ${USER}:${USER} $(VOLUME_DATABASE) ;\
	fi

check_wordpress_directory:
	@if [ ! -d $(VOLUME_WORDPRESS) ]; then \
		mkdir -p $(VOLUME_WORDPRESS) ;\
		chown -R ${USER}:${USER} $(VOLUME_WORDPRESS) ;\
	fi

check_data_directory:
	@if [ ! -d $(VOLUME_DATA) ]; then \
		mkdir -p $(VOLUME_DATA) ;\
		chown -R ${USER}:${USER} $(VOLUME_DATA) ;\
	fi

check_domain_in_hosts:
	@if ! grep -q "${USER}.42.fr" /etc/hosts; then \
		sudo sh -c "echo 127.0.0.1	${USER}.42.fr >> /etc/hosts "; \
	fi

check_docker:
	@if docker --version; then \
		sudo sh -c "apt-get update"; \
		sudo sh -c "apt-get upgrade -y" ;\ 
		sudo sh -c "apt-get install -y ./docker-desktop-amd64.deb"; \
		sudo sh -c "systemctl --user start docker-desktop"; \
		echo "Sem docker nesta bagaça"; \
	fi

check_env:
	@if [ ! -f srcs/.env ]; then \
		curl -o srcs/.env https://raw.githubusercontent.com/leafarRafael/.env/refs/heads/main/.env?token=GHSAT0AAAAAACNLDCFPWDGQQ3NAX624F5YSZ6IQPKQ ;\
	fi

start:
	docker start mariadb
	docker start wordpress
	docker start nginx

stop:
	docker stop -t 0 $(shell docker ps -aq)

clean_containers:
	docker rm $(shell docker ps -aq)	

clean_images:
	docker rmi $(shell docker images -q)

clean_volumes:
	docker volume rm $(shell docker volume ls -q)

clean_network:
	docker network prune

clean_system:
	docker system prune

clean_directory:
	echo "Deleting directories from volumes on the host"
	sudo sh -c "rm -Rf $(VOLUME_WORDPRESS)";
	sudo sh -c "rm -Rf $(VOLUME_DATABASE)";

clean_all: \
	stop \
	clean_containers \
	clean_images \
	clean_volumes \
	clean_network \
	clean_system \
	clean_directory


re_all: clean_all all
	