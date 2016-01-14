{%- from 'confluence/conf/settings.sls' import confluence with context %}

include:
  - sun-java
  - sun-java.env
#  - apache.vhosts.standard
#  - apache.mod_proxy_http

confluence:
  group:
    - present
  user:
    - present
    - groups:
      - confluence
    - require:
      - group: confluence

### APPLICATION INSTALL ###
unpack-confluence-tarball:
  archive.extracted:
    - name: {{ confluence.prefix }}
    - source: {{ confluence.source_url }}/atlassian-confluence-{{ confluence.version }}.tar.gz
    - source_hash: {{ salt['pillar.get']('confluence:source_hash', '') }}
    - archive_format: tar
    - user: confluence 
    - tar_options: z
    - if_missing: {{ confluence.prefix }}/atlassian-confluence-{{ confluence.version }}-standalone
    - runas: confluence
    - keep: True
    - require:
      - module: confluence-stop
      - file: confluence-init-script
    - listen_in:
      - module: confluence-restart

fix-confluence-filesystem-permissions:
  file.directory:
    - user: confluence
    - recurse:
      - user
    - names:
      - {{ confluence.prefix }}/atlassian-confluence-{{ confluence.version }}-standalone
      - {{ confluence.home }}
      - {{ confluence.log_root }}
    - watch:
      - archive: unpack-confluence-tarball

create-confluence-symlink:
  file.symlink:
    - name: {{ confluence.prefix }}/confluence
    - target: {{ confluence.prefix }}/atlassian-confluence-{{ confluence.version }}-standalone
    - user: confluence
    - watch:
      - archive: unpack-confluence-tarball

create-logs-symlink:
  file.symlink:
    - name: {{ confluence.prefix }}/confluence/logs
    - target: {{ confluence.log_root }}
    - user: confluence
    - backupname: {{ confluence.prefix }}/confluence/old_logs
    - watch:
      - archive: unpack-confluence-tarball

### SERVICE ###
confluence-service:
  service.running:
    - name: confluence
    - enable: True
    - require:
      - archive: unpack-confluence-tarball
      - file: confluence-init-script

# used to trigger restarts by other states
confluence-restart:
  module.wait:
    - name: service.restart
    - m_name: confluence

confluence-stop:
  module.wait:
    - name: service.stop
    - m_name: confluence  

confluence-init-script:
  file.managed:
    - name: '/etc/init.d/confluence'
    - source: salt://confluence/templates/confluence.init.tmpl
    - user: root
    - group: root
    - mode: 0755
    - template: jinja
    - context:
      confluence: {{ confluence|json }}

### FILES ###
{{ confluence.home }}/confluence-config.properties:
  file.managed:
    - source: salt://confluence/templates/confluence-config.properties.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - listen_in:
      - module: confluence-restart

{{ confluence.home }}/dbconfig.xml:
  file.managed:
    - source: salt://confluence/templates/dbconfig.xml.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - listen_in:
      - module: confluence-restart

{{ confluence.prefix }}/confluence/atlassian-confluence/WEB-INF/classes/confluence-application.properties:
  file.managed:
    - source: salt://confluence/templates/confluence-application.properties.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - listen_in:
      - module: confluence-restart

{{ confluence.prefix }}/confluence/bin/setenv.sh:
  file.managed:
    - source: salt://confluence/templates/setenv.sh.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - mode: 0644
    - listen_in:
      - module: confluence-restart

# {{ confluence.prefix }}/confluence/conf/logging.properties:
#   file.managed:
#     - source: salt://confluence/templates/logging.properties.tmpl
#     - user: {{ confluence.user }}
#     - template: jinja
#     - watch_in:
#       - module: confluence-restart

