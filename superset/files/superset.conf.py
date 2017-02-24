{%- from "superset/map.jinja" import server with context %}

#---------------------------------------------------------
# Superset specific config
#---------------------------------------------------------
ROW_LIMIT = 5000
SUPERSET_WORKERS = 4

SUPERSET_WEBSERVER_PORT = 8088
#---------------------------------------------------------

#---------------------------------------------------------
# Flask App Builder configuration
#---------------------------------------------------------
# Your App secret key
SECRET_KEY = "{{ server.get("secret", "4546asd8eseizuiquaiZ1ahfahvi5Eekie") }}"

# The SQLAlchemy connection string to your database backend
# This connection defines the path to the database that stores your
# superset metadata (slices, connections, tables, dashboards, ...).
# Note that the connection information to connect to the datasources
# you want to explore are managed directly in the web UI
SQLALCHEMY_DATABASE_URI = '{{ server.database.engine }}://{{ server.database.user }}:{{ server.database.password }}@{{ server.database.host }}:{{ server.database.get("port", 5432) }}/{{ server.database.name }}'

# Flask-WTF flag for CSRF
CSRF_ENABLED = True

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = ''

{%- if server.broker is defined and server.broker.engine == 'redis' %}
BROKER_URL = 'redis://{{ server.broker.host }}:{{ server.broker.port }}/{{ server.broker.number }}'
{%- elif  server.broker is defined and server.broker.engine == 'amqp' %}
BROKER_URL = 'amqp://{{ server.broker.user }}:{{ server.broker.password }}@{{ server.broker.host }}:{{ server.broker.get("port",5672) }}/{{ server.broker.virtual_host }}'
{%- endif %}

{%- if server.cache is defined and server.cache.engine == 'redis' %}
CACHE_TYPE = "{{ server.cache.engine }}"
CACHE_REDIS_URL = '{{ server.cache.engine }}://{{ server.cache.host }}:{{ server.cache.port }}/{{ server.cache.get("number", 2) }}'
{%- endif %}
