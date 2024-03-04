rmdir "./migrations" -Force -Recurse
echo rm -R -f ./migrations
poetry run flask db init
mysql -h localhost -u root -p -e "DROP DATABASE mldescription;"
mysql -h localhost -u root -p -e "CREATE DATABASE mldescription;"
poetry run flask db migrate
poetry run flask db upgrade