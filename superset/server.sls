{%- from "superset/map.jinja" import server with context %}
{%- if server.enabled %}

superset_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

superuset_user:
  user.present:
  - name: superset
  - shell: /bin/bash
  - system: true
  - home: {{ server.dir.home }}

superset_dirs:
  file.directory:
  - names:
    - /srv/superset
    - /var/log/superset
    - /srv/superset/flags
  - makedirs: true
  - group: superset
  - user: superset
  - require:
    - user: superset

{{ server.dir.home }}:
  virtualenv.manage:
  - requirements: salt://superset/files/requirements.txt
  - python: /usr/bin/python3
  - user: superset
  - require:
    - pkg: superset_packages

superset_installation:
  pip.installed:
  {%- if server.source is defined and server.source.get('engine', 'git') == 'git' %}
  - editable: "git+{{ server.source.address }}@{{ server.source.get("rev", "master") }}#egg=superset"
  {%- else %}
  - name: airflow {%- if server.version is defined %}=={{ server.version }}{% endif %}
  {%- endif %}
  - name: superset
  - bin_env: /srv/superset
  - exists_action: w
  - require:
    - virtualenv: /srv/superset

{% if server.database.engine in ["postgresql", "postgres", 'postgis'] %}
psycopg2_superset:
  pip.installed:
    - name: psycopg2
    - bin_env: /srv/superset
    - require:
      - virtualenv: /srv/superset
{% endif %}

{%- if server.worker is defined and server.worker or server.cache is defined and server.cache.engine == "redis" %}
redis_superset:
  pip.installed:
    - name: redis
    - bin_env: /srv/superset
    - require:
      - virtualenv: /srv/superset
{% endif %}

/var/log/superset/access.log:
  file.managed:
  - mode: 666
  - user: superset
  - group: superset
  - require:
    - file: superset_dirs

/var/log/superset/error.log:
  file.managed:
  - mode: 666
  - user: superset
  - group: superset
  - require:
    - file: superset_dirs

{{ server.dir.home }}/superset_config.py:
  file.managed:
  - source: salt://superset/files/superset.conf.py
  - template: jinja
  - user: superset
  - group: superset
  - mode: 644
  - require:
    - file: superset_dirs

/srv/superset/bin/start-service.sh:
  file.managed:
  - source: salt://superset/files/start-service.sh
  - mode: 700
  - template: jinja
  - user: superset
  - group: superset
  - require:
    - file: superset_dirs
    - virtualenv: /srv/superset

{%- set virtualenv = "/srv/superset/bin/activate" %}

superset_init_db:
  cmd.run:
  - name: . {{ virtualenv }} && superset db upgrade;touch /srv/superset/flags/init-db
  - cwd: /srv/superset
  - env:
    - PYTHONPATH: {{ server.dir.home }}
  - unless: "[ -f /srv/superset/flags/init-db ]"
  - require:
    - file: superset_dirs
    - virtualenv: /srv/superset

superset_init:
  cmd.run:
  - name: . {{ virtualenv }} && superset init;touch /srv/superset/flags/init
  - cwd: /srv/superset
  - env:
    - PYTHONPATH: {{ server.dir.home }}
  - unless: "[ -f /srv/superset/flags/init ]"
  - require:
    - file: superset_dirs
    - virtualenv: /srv/superset


{%- if server.load_examples is defined and server.load_examples %}
superset_load_examples:
  cmd.run:
  - name: . {{ virtualenv }} && superset load_examples;touch /srv/superset/flags/load_examples
  - cwd: /srv/superset
  - env:
    - PYTHONPATH: {{ server.dir.home }}
  - unless: "[ -f /srv/superset/flags/load_examples ]"
  - require:
    - file: superset_dirs
    - cmd: superset_init_db
    - cmd: superset_init
    - virtualenv: /srv/superset
{%- endif %}

{%- for user_name, user in server.auth.user.iteritems() %}
superset_create_user_{{ user_name }}:
  cmd.run:
  - name: . {{ virtualenv }} && fabmanager create-admin --app superset --lastname {{ user.username }} --firstname {{ user.username }} --username {{ user.username }} --email {{ user.email }} --password {{ user.password }};touch /srv/superset/flags/user_{{ user.username }}
  - cwd: /srv/superset
  - unless: "[ -f /srv/superset/flags/user_{{ user.username }} ]"
  - env:
    - PYTHONPATH: '/srv/superset'
  - require:
    - cmd: superset_init
    - cmd: superset_init_db
{%- endfor %}

superuset_permissions:
  cmd.run:
  - name: chown superset:superset . -R
  - cwd: /srv/superset
  - user: root
  - require:
    - cmd: superset_init_db
    - cmd: superset_init
    - virtualenv: /srv/superset

{%- endif %}
