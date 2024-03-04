rm -R -f ./migrations &&
poetry run flask db init &&
psql -U gitpod -c 'DROP DATABASE mldescription;' || true &&
psql -U gitpod -c 'CREATE DATABASE mldescription;' &&
psql -U gitpod -c 'CREATE EXTENSION unaccent;' -d mldescription &&
poetry run flask db migrate &&
poetry run flask db upgrade