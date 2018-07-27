<VirtualHost *:80>
    ServerName {{ apache.servername }}
    # ServerAlias
    ServerAdmin am.sz@burda.com

    DocumentRoot {{ apache.docroot }}


    SetEnvIf baseurl ^(.*)$ baseurl=https://{{ apache.servername }}


    <IfModule mod_rewrite.c>
        RewriteEngine On

        # in mod_rewrite conditions, OR has higher precedence then AND, thus in 
        # most simple cases subsequent rules connected by OR will stick 
        # together, while those "OR-groups" are connected by AND implicitly,
        # ie.: (a) AND (b OR c) AND (d OR e OR f) AND (g OR h) ...
        #
        # at first, multiple ip-adresses can be excluded,
        # and finally it's required that neither HTTPS nor ENV:HTTPS is set
        # for the rewrite to be executed.
        #
        RewriteCond %{REMOTE_ADDR} !^10\.110\.2\.
        RewriteCond %{HTTPS} !^on$ [OR]
        RewriteCond %{ENV:HTTPS} !^on$
        RewriteRule ^(.*)$ %{ENV:baseurl}$1 [L,R=302]
    </IfModule>


    <Directory {{ apache.docroot }}>
        # This relaxes Apache security settings.
        AllowOverride all
        # MultiViews must be turned off, and no indexing
        Options -MultiViews -Indexes +FollowSymLinks

        # disable vhost htaccess, disable_vhost_authentication
        Require all granted
    </Directory>


    <IfModule mod_php5.c>
        php_admin_flag engine on
        php_admin_flag register_globals off
        # php_admin_value open_basedir "/var/www/html/szshop-stage.sueddeutsche.de/current:/var/www/html/szshop-stage.sueddeutsche.de/shared:/tmp:/nas/szshopstage:/var/www/solr"
        # php_admin_value session.use_trans_sid 1
        php_value memory_limit 256M
        php_value display_errors 0
        php_value error_reporting 2047
        php_admin_flag register_argc_argv off
        php_admin_flag register_long_arrays off
    </IfModule>


    ErrorLog ${APACHE_LOG_DIR}/{{ apache.servername }}.error.log
    CustomLog ${APACHE_LOG_DIR}/{{ apache.servername }}.access.log combined


    {% if mailhog.install %}
    ProxyPass "{{ mailhog.web_alias }}" "http://localhost:{{ mailhog.web_port }}/"
    ProxyPassReverse "{{ mailhog.web_alias }}" "http://localhost:{{ mailhog.web_port }}/"
    {% endif %}

    {% if adminer.install %}
    Alias "{{ adminer.web_alias }}" "{{ adminer.document_root }}"
    {% endif %}

    {% if adminer_editor.install %}
    Alias "{{ adminer_editor.web_alias }}" "{{ adminer_editor.document_root }}"
    {% endif %}

    {% if adminer.install %}
    <Directory {{ adminer.document_root }}>
        AllowOverride All
        Options -Indexes +FollowSymLinks
        Require all granted
    </Directory>
    {% endif %}

    {% if adminer_editor.install %}
    <Directory {{ adminer_editor.document_root }}>
        AllowOverride All
        Options -Indexes +FollowSymLinks
        Require all granted
    </Directory>
    {% endif %}

</VirtualHost>



<VirtualHost *:443>

    ServerName {{ apache.servername }}
    # ServerAlias
    ServerAdmin am.sz@burda.com

    DocumentRoot {{ apache.docroot }}


    SetEnvIf baseurl ^(.*)$ baseurl=https://{{ apache.servername }}


    <Directory {{ apache.docroot }}>
        # This relaxes Apache security settings.
        AllowOverride all
        # MultiViews must be turned off, and no indexing
        Options -MultiViews -Indexes +FollowSymLinks

        # disable vhost htaccess, disable_vhost_authentication
        Require all granted
    </Directory>


    <IfModule mod_php5.c>
        php_admin_flag engine on
        php_admin_flag register_globals off
        # php_admin_value open_basedir "/var/www/html/szshop-stage.sueddeutsche.de/current:/var/www/html/szshop-stage.sueddeutsche.de/shared:/tmp:/nas/szshopstage:/var/www/solr"
        # php_admin_value session.use_trans_sid 1
        php_value memory_limit 256M
        php_value display_errors 0
        php_value error_reporting 2047
        php_admin_flag register_argc_argv off
        php_admin_flag register_long_arrays off
    </IfModule>


    ErrorLog ${APACHE_LOG_DIR}/{{ apache.servername }}.error.log
    CustomLog ${APACHE_LOG_DIR}/{{ apache.servername }}.access.log combined


    SSLEngine on
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem

    SSLCompression off
    SSLHonorCipherOrder on
    SSLProtocol all -SSLv2 -SSLv3
    SSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA


    {% if mailhog.install %}
    ProxyPass "{{ mailhog.web_alias }}" "http://localhost:{{ mailhog.web_port }}/"
    ProxyPassReverse "{{ mailhog.web_alias }}" "http://localhost:{{ mailhog.web_port }}/"
    {% endif %}

    {% if adminer.install %}
    Alias "{{ adminer.web_alias }}" "{{ adminer.document_root }}"
    {% endif %}

    {% if adminer_editor.install %}
    Alias "{{ adminer_editor.web_alias }}" "{{ adminer_editor.document_root }}"
    {% endif %}

    {% if adminer.install %}
    <Directory {{ adminer.document_root }}>
        AllowOverride All
        Options -Indexes +FollowSymLinks
        Require all granted
    </Directory>
    {% endif %}

    {% if adminer_editor.install %}
    <Directory {{ adminer_editor.document_root }}>
        AllowOverride All
        Options -Indexes +FollowSymLinks
        Require all granted
    </Directory>
    {% endif %}

</VirtualHost>
