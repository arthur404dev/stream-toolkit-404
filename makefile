.PHONY=all run-api run-web run-mock start-db run watch
.EXPORT_ALL_VARIABLES:

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

APP_NAME=stream-toolkit
LOCAL_BASE_ENDPOINT=http://localhost
LOCAL_SOCK_ENDPOINT=ws://localhost
LOCAL_WEB_ENDPOINT=$(LOCAL_BASE_ENDPOINT):$(DEV_WEB_PORT)
LOCAL_API_ENDPOINT=$(LOCAL_BASE_ENDPOINT):$(DEV_API_PORT)
LOCAL_MOCK_ENDPOINT=$(LOCAL_BASE_ENDPOINT):$(DEV_MOCK_PORT)
LOCAL_SOCKET_MOCK=$(LOCAL_SOCK_ENDPOINT):$(DEV_MOCK_PORT)
LOCAL_SOCKET_API=$(LOCAL_SOCK_ENDPOINT):$(DEV_API_PORT)

all: 
	@echo "=> For Local Development:\n\
		- api         : make run-api\n\
		- web         : make run-web\n\
		- mock        : make run-mock\n\
	=> For Production:\n\
		- on          : make run\n\
		- off         : make kill\n\
		- inspection  : make watch"
run-api:
	@echo "=> Running API locally using air"
	@cd ./api &&\
	RESTREAM_REDIRECT_URI="$(LOCAL_WEB_ENDPOINT)/$(DEV_ENDPOINT_WEB_REDIRECT)" \
	RESTREAM_TOKEN_ENDPOINT="$(LOCAL_MOCK_ENDPOINT)/$(DEV_ENDPOINT_MOCK_TOKEN)" \
	SOCKET_ENDPOINTS=$(LOCAL_SOCKET_MOCK) \
	RESTREAM_CLIENT_ID=$(DEV_RESTREAM_CLIENT) \
	RESTREAM_SECRET=$(DEV_RESTREAM_SECRET) \
	MONGO_CREDENTIALS=$(DEV_MONGO_CREDENTIALS) \
	MONGO_TOKEN_ID=$(DEV_MONGO_TOKEN) \
	PORT=$(DEV_API_PORT) \
	ENVIRONMENT=$(DEV_API_ENVIRONMENT) \
	LOG_LEVEL=$(DEV_API_LOG_LEVEL) \
	ACCESS_API_KEY=$(DEV_API_ACCESS_KEY) \
	air run main.go
run-web:
	@echo "=> Running Web locally using cracko"
	@cd ./web &&\
	REACT_APP_RESTREAM_REDIRECT_URI="$(LOCAL_WEB_ENDPOINT)/$(DEV_ENDPOINT_WEB_REDIRECT)" \
	REACT_APP_RESTREAM_API_BASE_URL=$(DEV_ENDPOINT_RESTREAM) \
	REACT_APP_BACKEND_URL="$(LOCAL_API_ENDPOINT)/$(DEV_ENDPOINT_API_EXCHANGE)" \
	REACT_APP_API_SOCKET_URL=$(LOCAL_SOCKET_API) \
	REACT_APP_RESTREAM_CLIENT_ID=$(DEV_RESTREAM_CLIENT) \
	REACT_APP_API_ACCESS_KEY=$(DEV_API_ACCESS_KEY) \
	PORT=$(DEV_WEB_PORT) \
	yarn start
run-mock: print-mock start-db start-data
print-mock:
	@echo "=> Running Mock Environment"
start-db:
	@echo "=> Starting Local Mongo Database"
	@docker-compose up -d mongo
start-data:
	@echo "=> Starting Local Data Creator"
	@cd ./mock/data &&\
	PORT=$(DEV_MOCK_PORT) \
	yarn dev
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