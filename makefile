.PHONY=all install run-api run-web run-mock start-db start-data run watch update-prod-api update-prod-web rebuild kill
.EXPORT_ALL_VARIABLES:

ifneq (,$(wildcard ./.env))
    include .env
    export
endif
APP_NAME=stream-toolkit
ENVIRONMENT_PATH=env
# submodules
REPO_API_ENDPOINT=https://github.com/arthur404dev/stream-toolkit-api.git
REPO_WEB_ENDPOINT=https://github.com/arthur404dev/stream-toolkit-web.git
# dev
LOCAL_BASE_ENDPOINT=$(DEV_ENDPOINT_BASE)
LOCAL_SOCK_ENDPOINT=$(DEV_ENDPOINT_SOCK)
LOCAL_API_ENV_FILE=$(DEV_ENV_FILE_API)
LOCAL_WEB_ENV_FILE=$(DEV_ENV_FILE_WEB)
LOCAL_WEB_ENDPOINT=$(LOCAL_BASE_ENDPOINT):$(DEV_WEB_PORT)
LOCAL_API_ENDPOINT=$(LOCAL_BASE_ENDPOINT):$(DEV_API_PORT)
LOCAL_MOCK_ENDPOINT=$(LOCAL_BASE_ENDPOINT):$(DEV_MOCK_PORT)
LOCAL_SOCKET_MOCK=$(LOCAL_SOCK_ENDPOINT):$(DEV_MOCK_PORT)
LOCAL_SOCKET_API=$(LOCAL_SOCK_ENDPOINT):$(DEV_API_PORT)
# prod
PROD_WEB_ENDPOINT=$(PROD_ENDPOINT_BASE):$(PROD_WEB_PORT)
PROD_API_ENDPOINT=$(PROD_ENDPOINT_BASE):$(PROD_API_PORT)
PROD_MOCK_ENDPOINT=$(PROD_ENDPOINT_BASE):$(PROD_MOCK_PORT)
PROD_SOCKET_MOCK=$(PROD_ENDPOINT_SOCK):$(PROD_MOCK_PORT)
PROD_SOCKET_API=$(PROD_ENDPOINT_SOCK):$(PROD_API_PORT)

all: 
	@echo "=> For Local Development:\n\
		- api         : make run-api\n\
		- web         : make run-web\n\
		- mock        : make run-mock\n\
	=> For Production:\n\
		- on          : make run\n\
		- off         : make kill\n\
		- inspection  : make watch"

install: clone-repos create-env

clone-repos:
	@echo "=> Cloning API"
	@git clone $(REPO_API_ENDPOINT) api
	@echo "=> Cloning WEB"
	@git clone $(REPO_WEB_ENDPOINT) web

create-env:
	@echo "=> Create environment folder"
	@mkdir $(ENVIRONMENT_PATH)
	@echo "=> Creating environment files"
	@cd $(ENVIRONMENT_PATH) && touch $(PROD_ENV_FILE_API) $(PROD_ENV_FILE_WEB) $(DEV_ENV_FILE_API) $(DEV_ENV_FILE_WEB)

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

update-prod-api:
	@echo "=> Updating environment and outputting to: $(PROD_ENV_FILE_API)"
	@echo "\
	PORT=$(PROD_API_PORT)\n\
	RESTREAM_REDIRECT_URI=$(PROD_WEB_ENDPOINT)/$(PROD_ENDPOINT_WEB_REDIRECT)\n\
	RESTREAM_TOKEN_ENDPOINT=$(PROD_ENDPOINT_RESTREAM)/$(PROD_ENDPOINT_MOCK_TOKEN)\n\
	SOCKET_ENDPOINTS=$(PROD_SOCKET_ENDPOINTS)\n\
	RESTREAM_CLIENT_ID=$(PROD_RESTREAM_CLIENT)\n\
	RESTREAM_SECRET=$(PROD_RESTREAM_SECRET)\n\
	MONGO_CREDENTIALS=\"$(subst &,\&,$(PROD_MONGO_CREDENTIALS))\"\n\
	MONGO_TOKEN_ID=$(PROD_MONGO_TOKEN)\n\
	ENVIRONMENT=$(PROD_API_ENVIRONMENT)\n\
	LOG_LEVEL=$(PROD_API_LOG_LEVEL)\n\
	ACCESS_API_KEY=$(PROD_API_ACCESS_KEY)\n\
	" | tee ./$(ENVIRONMENT_PATH)/$(PROD_ENV_FILE_API) ./api/.env

update-prod-web:
	@echo "=> Updating environment and outputting to: $(PROD_ENV_FILE_WEB)"
	@echo "\
	REACT_APP_RESTREAM_REDIRECT_URI=$(PROD_WEB_ENDPOINT)/$(PROD_ENDPOINT_WEB_REDIRECT)\n\
	REACT_APP_RESTREAM_API_BASE_URL=$(PROD_ENDPOINT_RESTREAM)\n\
	REACT_APP_BACKEND_URL=$(PROD_API_ENDPOINT)/$(PROD_ENDPOINT_API_EXCHANGE)\n\
	REACT_APP_API_SOCKET_URL=$(PROD_SOCKET_API)\n\
	REACT_APP_RESTREAM_CLIENT_ID=$(PROD_RESTREAM_CLIENT)\n\
	REACT_APP_API_ACCESS_KEY=$(PROD_API_ACCESS_KEY)\n\
	" | tee ./$(ENVIRONMENT_PATH)/$(PROD_ENV_FILE_WEB) ./web/.env

run: update-prod-api update-prod-web
	@echo "=> Running $(APP_NAME) on detached mode"
	@docker-compose up -d api web
	@echo "=> api running at $(PROD_API_ENDPOINT)\n=> web running at $(PROD_WEB_ENDPOINT)"
	@sensible-browser $(PROD_WEB_ENDPOINT)/overlay/chat/manager

rebuild: update-prod-api update-prod-web
	@echo "=> Rebuilding $(APP_NAME)"
	@docker-compose build web api

kill:
	@echo "=> Shutting $(APP_NAME) down and cleaning images"
	@docker-compose down --remove-orphans

watch:
	@echo "=> Watching $(APP_NAME) containers"
	@docker-compose logs -f
