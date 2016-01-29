{%- from 'nexus/map.jinja' import nexus with context %}

include:
  - java

nexus-dir:
  file.directory:
    - name: {{ nexus.directory }}
    - makedirs: True
    - user: root
    - group: root

nexus:
  file.managed:
    - name: /etc/systemd/system/nexus.service
    - source: salt://nexus/files/nexus2.service
    - template: jinja
    - defaults:
        config: {{ nexus }}

  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: nexus

  group.present:
    - name: {{ nexus.group }}

  user.present:
    - name: {{ nexus.user }}
    - gid: {{ nexus.group }}
    - home: {{ nexus.workdir }}
    - createhome: False
    - require:
      - group: nexus

  service.running:
    - name: nexus
    - enable: True
    - require:
      - user: nexus
      - file: nexus
      - file: nexus-chmod

nexus-graceful-down:
  service.dead:
    - name: nexus
    - require:
      - module: nexus
    - prereq:
      - file: nexus-install

nexus-install:
  archive.extracted:
    - name: {{ nexus.directory }}
    - source: {{ nexus.source }}
    - source_hash: {{ nexus.source_hash }}
    - archive_format: tar
    - if_missing: {{ nexus.install }}
    - tar_options: z
    - user: root
    - group: root
    - keep: True
    - require:
      - file: nexus-dir
    - watch_in:
      - service: nexus

  file.symlink:
    - name: {{ nexus.symlink }}
    - target: {{ nexus.install }}
    - require:
      - archive: nexus-install
    - watch_in:
      - service: nexus

nexus-chmod:
  file.directory:
    - name: {{ nexus.workdir }}
    - user: {{ nexus.user }}
    - group: {{ nexus.group }}
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - file: nexus-install

{% for dir in [ nexus.piddir, nexus.tmpdir, nexus.logdir ] %}
nexus-dir-{{ dir }}:
  file.directory:
    - name: {{ dir }}
    - user: {{ nexus.user }}
    - group: {{ nexus.group }}
    - makedirs: True
    - require:
      - file: nexus-install
    - require_in:
      - service: nexus
{% endfor %}

nexus-wrapper-java:
  file.replace:
    - name: {{ nexus.symlink }}/bin/jsw/conf/wrapper.conf
    - pattern: ^wrapper.java.command[ \t]*=.*
    - repl: wrapper.java.command={{ nexus.java_home }}/bin/java
    - require:
      - file: nexus-install
    - watch_in:
      - service: nexus

{% for key, value in nexus.get('properties', {}).items() %}
nexus-properties-{{ key }}:
  file.replace:
    - name: {{ nexus.symlink }}/conf/nexus.properties
    - pattern: ^{{ key }}[ \t]*=[ \t]*.*$
    - repl: {{ key }}={{ value }}
    - append_if_not_found: True
    - require:
      - file: nexus-install
    - watch_in:
      - service: nexus
{% endfor %}
