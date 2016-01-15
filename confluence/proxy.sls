{%- from 'confluence/conf/settings.sls' import confluence with context %}

confluence-vhost:
  file.managed:
    - name: /etc/httpd/sites-available/confluence.conf
    - source: salt://confluence/templates/confluence-vhost.tmpl
    - template: jinja
    - require:
      - file: sites-available

enable-confluence-site:
  file.symlink:
    - name: /etc/httpd/sites-enabled/confluence.conf
    - target: /etc/httpd/sites-available/confluence.conf
    - listen_in:
      - module: apache-reload
    - require:
      - file: confluence-vhost
