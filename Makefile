# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: user42 <user42@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/02/28 12:33:11 by rbutzke           #+#    #+#              #
#    Updated: 2025/08/02 15:35:16 by user42           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

.PHONY: all up environment check_database_directory check_wordpress_directory \
	check_data_directory check_domain_in_hosts check_docker check_env start \
	stop clean_containers clean_images clean_volumes clean_network clean_system \
	clean_directory clean_all re_all

VOLUME_WORDPRESS=/home/rbutzke/data/wordpress-volume
VOLUME_DATABASE=/home/rbutzke/data/database-volume
VOLUME_DATA=/home/rbutzke/data

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
		sudo mkdir -p $(VOLUME_DATABASE) ;\
		sudo chown -R ${USER}:${USER} $(VOLUME_DATABASE) ;\
	fi

check_wordpress_directory:
	@if [ ! -d $(VOLUME_WORDPRESS) ]; then \
		sudo mkdir -p $(VOLUME_WORDPRESS) ;\
		sudo chown -R ${USER}:${USER} $(VOLUME_WORDPRESS) ;\
	fi

check_data_directory:
	@if [ ! -d $(VOLUME_DATA) ]; then \
		sudo mkdir -p $(VOLUME_DATA) ;\
		sudo chown -R ${USER}:${USER} $(VOLUME_DATA) ;\
	fi

check_domain_in_hosts:
	@if ! grep -q "rbutzke.42.fr" /etc/hosts; then \
		sudo sh -c "echo 127.0.0.1	rbutzke.42.fr >> /etc/hosts "; \
	fi

check_docker:
	@if ! docker --version >/dev/null 2>&1; then \
		echo "Docker não encontrado. Instalando..."; \
		sudo sh -c "apt-get update"; \
		sudo sh -c "apt-get upgrade -y"; \
		sudo sh -c "apt-get install -y ./docker-desktop-amd64.deb"; \
		sudo sh -c "systemctl --user start docker-desktop"; \
	else \
		echo "Docker já está instalado"; \
	fi

check_env:
	@if [ ! -f srcs/.env ]; then \
		echo "Arquivo .env não encontrado. Por favor, crie o arquivo srcs/.env manualmente."; \
		exit 1; \
	fi

start:
	docker start mariadb
	docker start wordpress
	docker start nginx

stop:
	docker stop -t 0 $(shell docker ps -aq)

clean_containers:
	@if [ -n "$$(docker ps -aq)" ]; then \
		docker rm $$(docker ps -aq); \
	else \
		echo "Nenhum container para remover"; \
	fi

clean_images:
	@if [ -n "$$(docker images -q)" ]; then \
		docker rmi $$(docker images -q); \
	else \
		echo "Nenhuma imagem para remover"; \
	fi

clean_volumes:
	@if [ -n "$$(docker volume ls -q)" ]; then \
		docker volume rm $$(docker volume ls -q); \
	else \
		echo "Nenhum volume para remover"; \
	fi

clean_network:
	@docker network prune -f

clean_system:
	@docker system prune -f

clean_directory:
	echo "Deleting directories from volumes on the host"
	sudo sh -c "rm -Rf $(VOLUME_WORDPRESS)";
	sudo sh -c "rm -Rf $(VOLUME_DATABASE)";
	sudo sh -c "rm -Rf $(VOLUME_DATA)";

clean_all: \
	stop \
	clean_containers \
	clean_images \
	clean_volumes \
	clean_network \
	clean_system \
	clean_directory 


re_all: clean_all all
	