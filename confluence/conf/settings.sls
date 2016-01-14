{% set p  = salt['pillar.get']('confluence', {}) %}
{% set g  = salt['grains.get']('confluence', {}) %}


{%- set default_version      = '5.9.4' %}
{%- set default_prefix       = '/opt' %}
{%- set default_source_url   = 'https://downloads.atlassian.com/software/confluence/downloads' %}
{%- set default_log_root     = '/var/log/confluence' %}
{%- set default_confluence_user    = 'confluence' %}
{%- set default_db_server    = 'localhost' %}
{%- set default_db_name      = 'confluence' %}
{%- set default_db_username  = 'confluence' %}
{%- set default_db_password  = 'confluence' %}
{%- set default_jvm_Xms      = '384m' %}
{%- set default_jvm_Xmx      = '768m' %}
{%- set default_jvm_MaxPermSize = '384m' %}

{%- set version        = g.get('version', p.get('version', default_version)) %}
{%- set source_url     = g.get('source_url', p.get('source_url', default_source_url)) %}
{%- set log_root       = g.get('log_root', p.get('log_root', default_log_root)) %}
{%- set prefix         = g.get('prefix', p.get('prefix', default_prefix)) %}
{%- set confluence_user      = g.get('user', p.get('user', default_confluence_user)) %}
{%- set db_server      = g.get('db_server', p.get('db_server', default_db_server)) %}
{%- set db_name        = g.get('db_name', p.get('db_name', default_db_name)) %}
{%- set db_username    = g.get('db_username', p.get('db_username', default_db_username)) %}
{%- set db_password    = g.get('db_password', p.get('db_password', default_db_password)) %}
{%- set jvm_Xms        = g.get('jvm_Xms', p.get('jvm_Xms', default_jvm_Xms)) %}
{%- set jvm_Xmx        = g.get('jvm_Xmx', p.get('jvm_Xmx', default_jvm_Xmx)) %}
{%- set jvm_MaxPermSize = g.get('jvm_MaxPermSize', p.get('jvm_MaxPermSize', default_jvm_MaxPermSize)) %}


{%- set confluence_home      = salt['pillar.get']('users:%s:home' % confluence_user, '/home/confluence') %}

{%- set confluence = {} %}
{%- do confluence.update( { 'version'        : version,
                      'source_url'     : source_url,
                      'log_root'       : log_root,
                      'home'           : confluence_home,
                      'prefix'         : prefix,
                      'user'           : confluence_user,
                      'db_server'      : db_server,
                      'db_name'        : db_name,
                      'db_username'    : db_username,
                      'db_password'    : db_password,
                      'jvm_Xms'        : jvm_Xms,
                      'jvm_Xmx'        : jvm_Xmx,
                      'jvm_MaxPermSize': jvm_MaxPermSize,
                  }) %}

