#nZEDb docker file for unraid 6
FROM phusion/baseimage:0.9.17
MAINTAINER marc brown <marc@22walker.co.uk> v0.1

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV AUTOBUILD_UNIXTIME 1418234402
ENV SQLUSERNAME nzedb
ENV SQLDBUSERNAME nzedb
ENV SQLDBPASSWORD nzedb
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add VOLUME to allow database storage
VOLUME ["/etc/freepbxbackup"]

# open up ports needed   
EXPOSE

# Add start.sh
ADD start.sh /root/

#Install packets that are needed
RUN add-apt-repository ppa:ondrej/php5-5.6 \
  && apt-get update && apt-get install -y build-essential software-properties-common python-software-properties git php5 php5-cli php5-dev php5-json php-pear mariadb-server mariadb-client libmysqlclient-dev php5-gd php5-mysqlnd php5-curl apache2 \ 1>/dev/null
  && apt-get purge apparmor \
  && sudo aa-complain /usr/sbin/mysqld
# Configure mysql
  && sed -i 's/\(^max_allowed_packet = \).*/\16M/' /etc/mysql/my.cnf \
  && sed -i 's/\(^group_concat_max_len = \.*\8192/' /etc/mysql/my.cnf \
  && mysql -u root -e "GRANT ALL ON nzedb.* TO '$SQLDBUSERNAME'@'local' IDENTIFIED BY 'SQLDBPASS';" \
  && mysql -u root -e "GRANT FILE ON *.* TO '$SQLDBUSERNAME'@'local';" \
  && echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " ServerAdmin webmaster@localhost" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " ServerName localhost" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " DocumentRoot \"/var/www/nZEDb/www\"" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " LogLevel warn" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " ServerSignature Off" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " ErrorLog /var/log/apache2/error.log" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " <Directory \"/var/www/nZEDb/www\">" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo "   Options FollowSymLinks" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo "   AllowOverride All" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo "   Require all granted" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " </Directory>" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo " Alias /covers /var/www/nZEDb/resources/covers" >> /etc/apache2/sites-available/nZEDb.conf \
  && echo "</VirtualHost>" >> /etc/apache2/sites-available/nZEDb.conf \
  && awk '/<Directory \/var\/www\/>/,/AllowOverride None/{sub("None", "All",$0)}{print}' \
  && a2dissite 00-default \
  && a2dissite 000-default \
  && a2ensite nZEDb.conf \
  && a2enmod rewrite \
  && service apache2 restart \
  && a2dissite default \
  && sudo a2ensite nZEDb \
  && sudo a2enmod rewrite \
  && service apache2 restart \
  
  
