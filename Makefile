dev.setup:
	docker-compose build
	docker-compose run -e MIX_ENV=dev app mix deps.get
	docker-compose run -e MIX_ENV=dev app mix deps.compile

dev.run:
	docker-compose run --service-ports -e MIX_ENV=dev app elixir --sname app -S mix run --no-halt

dev.console:
	docker-compose run -e MIX_ENV=dev app iex -S mix

mix.format:
	docker-compose run -e  MIX_ENV=test app mix format --check-formatted
