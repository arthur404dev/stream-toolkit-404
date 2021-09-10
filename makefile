.PHONY=all run-api run-web run watch install
.EXPORT_ALL_VARIABLES:

APP_NAME=stream-toolkit
WEB_ENDPOINT=http://localhost:3000

all: 
	@echo "=> Running both api and web concurrently"
	@make -j 2 run-api run-web
run-api:
	@echo "=> Running API locally using air"
	@cd ./api && air run main.go
run-web:
	@echo "=> Running Web locally using cracko"
	@cd ./web && yarn start | cat
run:
	@echo "=> Running $(APP_NAME) on detached mode"
	@docker-compose up -d
	@sensible-browser $(WEB_ENDPOINT)/overlay/chat/manager
kill:
	@echo "=> Shutting $(APP_NAME) down and cleaning images"
	@docker-compose down --remove-orphans
watch:
	@echo "=> Watching $(APP_NAME) containers"
	@docker-compose logs -f