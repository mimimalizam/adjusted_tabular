# Adjusted Tabular

## Development

- Requirements: `docker-compose`
  - my environment includes Docker Compose v1.23.2 and it can be installed with
      ```
      sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      ```
- Call `make dev.setup` from the project's root path to set up local environment
