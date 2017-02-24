#!/bin/bash
{%- from "superset/map.jinja" import server with context %}

. {{ server.dir.home }}/bin/activate

export PYTHONPATH=$PYTHONPATH:{{ server.dir.home }}

exec $1