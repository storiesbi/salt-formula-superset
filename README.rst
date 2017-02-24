
========
superset
========

Superset is a data exploration platform designed to be visual, intuitive and interactive.

Sample pillars
==============

Single superset service

.. code-block:: yaml

    superset:
      server:
        enabled: true
        backup: true
        debug: true
        auth:
          enabled: true
          user:
            test:
              username: test
              email: email@test.cz
              password: test
        bind:
          address: localhost
          protocol: tcp
          port: 8000
        enabled: true
        worker: true
        secret_key: secret
        source:
          engine: pip
          version: 1.0.0       
        database:
          engine: postgres
          host: 127.0.0.1
          name: superset_prd
          password: password
          user: superset_prd
        broker:
          engine: redis
          host: 127.0.0.1
          port: 6379
          number: 10
        logging:
          engine: sentry
          dsn: dsn

    supervisor:
      server:
        service:
          superset:
            name: web
            type: superset
          superset_worker:
            name: worker
            type: superset


Read more
=========

* https://github.com/airbnb/superset
* http://airbnb.io/superset/index.html
