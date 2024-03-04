rm -R -f ./migrations &&
poetry run flask db init &&
mysql -u root -p -e "DROP DATABASE mldescription;" &&
mysql -u root -p -e "CREATE DATABASE mldescription;" &&
poetry run flask db migrate &&
poetry run flask db upgrade