# Adjusted Tabular

## Requirements: `docker-compose`

  - my environment includes Docker Compose v1.23.2 and it can be installed with
      ```
      sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      ```

## Setup

To set up the environment call `make dev.setup` from the project's root path.
The command will
- bootstrap the application and postgres docker containers
- it creates `foo` and `bar` databases
- creates and populates tables `source`(within `foo`) and `dest`(within `bar`)

## Web server

After the environment has been set up, local server can be started with `make dev.server`.
It opens routes for inspecting the tabels content with chuncked transfer endcoding
(eg. `http://localhost:4000/dbs/foo/tables/source`)

## Databases setup

The database initialization script is available at [`docker-entrypoint-initdb.d/create-databases.sh`](/docker-entrypoint-initdb.d/create-databases.sh)
`make dev.setup` target creates the databases and populates the tables.
Tables `source` and `dest` from `bar` are populated with a mix task `seed`.

<details>
  <summary>Example Docker commands</summary>
  <p>

```
# create databases from sql script

# /scripts/create_databases.sql
CREATE DATABASE foo;
CREATE DATABASE bar;

docker ps
docker exec -it adjusted_tabular_db_1 psql -U postgres -f /scripts/create_databases.sql
# verify databases presence
docker exec -it adjusted_tabular_db_1 psql -U postgres -c "\l"

# in the need of the fresh start, we can delete existing containers and images
# example for docker container removal
docker ps | grep adjusted_tabular_db | awk '{print $1}' | xargs docker rm -f
```

  </p>
</details>
