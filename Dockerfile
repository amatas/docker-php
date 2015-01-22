FROM inclusivedesign/centos:7

RUN yum -y install nginx php-fpm php-mysql php-gd php-xml php-xmlrpc php-pecl-apcu php-xcache && \
    yum clean all

ADD install.sh /usr/local/sbin/install.sh
    
RUN chmod +x /usr/local/sbin/install.sh && \
    /usr/local/sbin/install.sh

CMD ["/bin/bash"]