{%- from 'nexus/map.jinja' import nexus with context %}

include:
  - .nexus{{ 3 if nexus.is_nexus3 else 2 }}
