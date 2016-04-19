# Default Apache virtualhost template

<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  DocumentRoot {{ apache.docroot }}
  ServerName {{ apache.servername }}

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

  <Directory {{ apache.docroot }}>
    AllowOverride All
    Options -Indexes +FollowSymLinks
    Require all granted
  </Directory>

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
