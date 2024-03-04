rm -R -f ./migrations &&
poetry run flask db init &&
psql -U postgres -c 'DROP DATABASE mldescription;' || true &&
psql -U postgres -c 'CREATE DATABASE mldescription;' &&
psql -U postgres -c 'CREATE EXTENSION unaccent;' -d mldescription &&
poetry run flask db migrate &&
poetry run flask db upgrade