#!/bin/bash

cd /var/www/html

if [ ! -f /var/www/html/wp-config.php ]; then

	wp core download \
		--path=/var/www/html \
		--allow-root 
	wp config create \
		--dbname=${DB_NAME} \
		--dbuser=${DB_USER} \
		--dbpass=${DB_PW} \
		--dbhost=${DB_HOST} \
		--skip-check \
		--allow-root

	wp core install \
		--path=/var/www/html/ \
		--admin_user=${WP_ADM} \
		--admin_password=${WP_ADM_PW} \
		--admin_email=${WP_ADM_MAIL} \
		--url=${DOMAIN} \
		--title=${TITLE} \
		--allow-root

	wp theme activate twentytwentyfive --allow-root

	wp post update 1 \
		--post_title="Inception rbutzke" \
		--post_content="Welcome to my inception blablabla" \
		--allow-root

	wp post update 2 \
		--post_name='my_page' \
		--post_title=Inception --post_content='\
			<p>Link to subject: \
			<a href="https://cdn.intra.42.fr/pdf/pdf/119221/en.subject.pdf">here.</a></p>' \
		--allow-root

	wp post delete 3 --allow-root

	wp user create \
		--path=/var/www/html/ \
		"${WP_USER}" "${WP_MAIL}" \
		--user_pass=${WP_PW} \
		--role='author' \
		--allow-root
fi

if [ ! -d /run/php ]; then
	mkdir /run/php
fi

chown www-data:www-data /run/php
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

php-fpm7.4 -F



