{%- if pillar.superset is defined %}
include:
{%- if pillar.superset.server is defined %}
- superset.server
{%- endif %}
{%- endif %}
