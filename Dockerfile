FROM centos:7

## Install the prerequisite OS packages using yum command
RUN yum update -y
RUN yum install httpd php php-mysql php-gd php-xml mariadb-server mariadb php-mbstring -y

## Start the Web Server and Database Service

RUN systemctl restart httpd.service; \
    systemctl enable httpd.service
RUN systemctl start mariadb; \
    systemctl enable mariadb

## Download MediaWiki 1.24.2 and Install
RUN wget https://releases.wikimedia.org/mediawiki/1.24/mediawiki-1.24.2.tar.gz; \
    tar -zxpvf mediawiki-1.24.2.tar.gz; \
    mv mediawiki-1.24.2 /var/www/html/mediawiki; \
    chown -R apache:apache /var/www/html/mediawiki/; \
    chmod 755 /var/www/html/mediawiki/

## If your system is running behind the iptables / firewall , then use below commands to open 80 port for mediawiki.
RUN firewall-cmd --zone=public --add-port=80/tcp --permanent; \
    firewall-cmd --reload; \
    iptables-save | grep 80

## If Selinux is enable on your Linux box , then set the following Selinux rules on mediawiki folder
RUN getenforce; \
    restorecon -FR /var/www/html/mediawiki/

EXPOSE 80
ENTRYPOINT ["systemctl", "restart",  "httpd.service"]