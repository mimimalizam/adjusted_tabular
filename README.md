# Adjusted Tabular

## Development

Requirements: `docker-compose`
  - my environment includes Docker Compose v1.23.2 and it can be installed with
      ```
      sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      ```

To set up the environment call `make dev.setup` from the project's root path.
The command will bootstrap application and postgres containers.
Additionally, it will create `foo` and `bar` databases.

## `foo` and `bar` databases setup

- Databases `foo` and `bar` are created automatically with docker compose build (which is part of `make dev.setup`
- The initialization script is available at [`docker-entrypoint-initdb.d/create-databases.sh`](/docker-entrypoint-initdb.d/create-databases.sh)
- Tables `source` from `foo` and `dest` from `bar` are being populated with a mix task `seed`. It can be executed with `make mix.seed` from console.

<details>
  <summary>Click for more Docker commands</summary>
  <p>

We'll use the `docker` cli to run the sql script in the postgres container.

```
# set up dev environment
make dev.setup

# create databases from sql script
docker ps
docker exec -it adjusted_tabular_db_1 psql -U postgres -f /scripts/create_databases.sql
# verify databases presence
docker exec -it adjusted_tabular_db_1 psql -U postgres -c "\l"

# /scripts/create_databases.sql
CREATE DATABASE foo;
CREATE DATABASE bar;

# in the need of the fresh start, we can delete existing containers and images
# example for docker container removal
docker ps | grep adjusted_tabular_db | awk '{print $1}' | xargs docker rm -f
```

  </p>
</details>
