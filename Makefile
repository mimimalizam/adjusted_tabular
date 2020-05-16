.PHONY: all test clean

dev.setup:
	docker-compose build
	docker-compose run -e MIX_ENV=dev app mix deps.get
	docker-compose run -e MIX_ENV=dev app mix deps.compile
	docker-compose run -e MIX_ENV=dev app mix seed

dev.server:
	docker-compose run --service-ports -e MIX_ENV=dev app elixir --sname app -S mix run --no-halt

dev.console:
	docker-compose run -e MIX_ENV=dev app iex -S mix

mix.seed:
	docker-compose run -e MIX_ENV=dev app mix seed

mix.format:
	docker-compose run -e  MIX_ENV=test app mix format --check-formatted

test.setup:
	docker-compose run -e MIX_ENV=test app mix deps.get
	docker-compose run -e MIX_ENV=test app mix deps.compile

test:
	docker-compose run -e MIX_ENV=test app mix test

test.wip:
	docker-compose run -e MIX_ENV=test app mix test --only wip
