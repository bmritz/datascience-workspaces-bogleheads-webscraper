#!/usr/bin/env bash
set -e
docker-compose build --pull run-script # pull so that we get most up to date base image
docker-compose build ipython-shell # so that ipython-shell will be synced up with run-script
docker-compose build jupyter-notebook
docker push gcr.io/spins-retail-solutions/bogleheads-webscraper:run-script
