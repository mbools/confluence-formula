{%- from 'confluence/conf/settings.sls' import confluence with context %}


apache:
  pkg.installed:
    - pkgs:
       - httpd
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: apache 

apache-restart:
  module.wait:
    - name: service.restart
    - m_name: httpd

apache-reload:
  module.wait:
    - name: service.reload
    - m_name: httpd

confluence-sites-enabled:
  file.directory:
    - name: /etc/httpd/sites-enabled
    - user: apache
    - group: apache
    - mode: 755 
    - require_in:
      - file: enable-confluence-site

confluence-sites-available:
  file.directory:
      - name: /etc/httpd/sites-available
      - user: apache
      - group: apache
      - mode: 755

confluence-sites-available-config:
  file.blockreplace:
      - name: /etc/httpd/conf/httpd.conf
      - marker_start: '#BEGIN Managed by salt - do not edit'
      - marker_end: '#END Managed by salt - do not edit'
      - content: 'IncludeOptional sites-enabled/*.conf'
      - append_if_not_found: True
      - require:
        - pkg: apache

confluence-vhost:
  file.managed:
    - name: /etc/httpd/sites-available/confluence.conf
    - source: salt://confluence/templates/confluence-vhost.tmpl
    - require:
      - file: confluence-sites-available

disable-default-site:
  file.absent:
    - name: /etc/httpd/sites-enabled/000-default
    - listen_in:
      - module: apache-reload
    - require:
      - file: enable-confluence-site

enable-confluence-site:
  file.symlink:
    - name: /etc/httpd/sites-enabled/confluence.conf
    - target: /etc/httpd/sites-available/confluence.conf
    - listen_in:
      - module: apache-reload
    - require:
      - file: confluence-vhost

httpd_can_network_connect:
  selinux.boolean:
    - value: True
    - persist: True
 
a2enmod proxy:
  cmd.wait:
    - watch:
      - pkg: apache
    - listen_in:
      - module: apache-restart

a2enmod proxy_http:
  cmd.wait:
    - watch:
      - pkg: apache
    - listen_in:
      - module: apache-restart
