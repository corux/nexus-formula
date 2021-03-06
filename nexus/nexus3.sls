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
    - source: salt://nexus/files/nexus3.service
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
      - file: nexus-workdir

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

nexus-upgrade-clean-cache:
  file.managed:
    - name: {{ nexus.workdir }}/clean_cache
    - user: {{ nexus.user }}
    - group: {{ nexus.group }}
    - require:
      - file: nexus-workdir
    - onchanges:
      - archive: nexus-install

nexus-workdir:
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

{% for key, value in nexus.get('properties', {}).items() %}
nexus-properties-{{ key }}:
  file.replace:
    - name: {{ nexus.symlink }}/etc/custom.properties
    - pattern: ^{{ key }}[ \t]*=[ \t]*.*$
    - repl: {{ key }}={{ value }}
    - append_if_not_found: True
    - require:
      - file: nexus-install
    - watch_in:
      - service: nexus
{% endfor %}

{% for key, value in nexus.get('vmoptions', {}).items() %}
nexus-vmoptions-{{ key }}:
  file.replace:
    - name: {{ nexus.symlink }}/bin/nexus.vmoptions
    - pattern: ^-D{{ key }}[ \t]*=[ \t]*.*$
    - repl: -D{{ key }}={{ value }}
    - append_if_not_found: True
    - require:
      - file: nexus-install
    - watch_in:
      - service: nexus
{% endfor %}
