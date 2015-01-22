#!/bin/bash

# Setup php-fpm
sed -i 's/\/var\/log\/php-fpm\/[A-z.-]*/\/dev\/stdout/g' /etc/php-fpm.d/www.conf
sed -i 's/\/var\/log\/php-fpm\/[A-z.-]*/\/dev\/stdout/g' /etc/php-fpm.conf
sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/g' /etc/php-fpm.d/www.conf

sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf

mkdir /var/lib/php/session
chown nginx /var/lib/php/session

cat >>/etc/nginx/fastcgi_params<<EOF

fastcgi_param  QUERY_STRING       \$query_string;
fastcgi_param  REQUEST_METHOD     \$request_method;
fastcgi_param  CONTENT_TYPE       \$content_type;
fastcgi_param  CONTENT_LENGTH     \$content_length;

fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
fastcgi_param  PATH_INFO          \$fastcgi_path_info;
fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
fastcgi_param  REQUEST_URI        \$request_uri;
fastcgi_param  DOCUMENT_URI       \$document_uri;
fastcgi_param  DOCUMENT_ROOT      \$document_root;
fastcgi_param  SERVER_PROTOCOL    \$server_protocol;
fastcgi_param  HTTPS              \$https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/\$nginx_version;

fastcgi_param  REMOTE_ADDR        \$remote_addr;
fastcgi_param  REMOTE_PORT        \$remote_port;
fastcgi_param  SERVER_ADDR        \$server_addr;
fastcgi_param  SERVER_PORT        \$server_port;
fastcgi_param  SERVER_NAME        \$server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;

EOF

cat >/etc/nginx/nginx.conf<<EOF
user  nginx;
worker_processes  4;
daemon off;

error_log  /dev/stdout;
pid        /run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /dev/stdout  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;
    gzip_disable "msie6";

    index   index.html index.htm index.php;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
}
EOF

cat >/etc/supervisord.d/php-fpm.ini<<EOF
[program:php-fpm]
command=/usr/sbin/php-fpm --nodaemonize
autorestart=true
redirect_stderr=true
stopsignal=QUIT
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

cat >/etc/supervisord.d/nginx.ini<<EOF
[program:nginx]
command=/usr/sbin/nginx
autorestart=true
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF
