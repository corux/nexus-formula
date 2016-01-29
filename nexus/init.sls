{%- from 'nexus/map.jinja' import nexus with context %}

include:
{%- if nexus.is_nexus3 %}
  - .nexus3
{%- else %}
  - .nexus2
{%- endif %}
