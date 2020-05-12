# Adjusted Tabular

## Development

- Requirements: `docker-compose`
  - my environment includes Docker Compose v1.23.2 and it can be installed with
      ```
      sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      ```
- Call `make dev.setup` from the project's root path to set up local environment


## `foo` and `bar` databases setup

We'll use the `docker` cli to run the sql script in the postgres container.

```
# /scripts/create_databases.sql
CREATE DATABASE foo;
CREATE DATABASE bar;

# make dev.setup
make dev.setup

# create databases
docker ps
docker exec -it adjusted_tabular_db_1 psql -U postgres -f /scripts/create_databases.sql
# verify databases presence
docker exec -it adjusted_tabular_db_1 psql -U postgres -c "\l"


# in the need of the fresh start, we can delete existing containers and images
# example for docker container removal
docker ps | grep adjusted_tabular_db | awk '{print $1}' | xargs docker rm -f
```
