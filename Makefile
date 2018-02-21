repo = muchrm/nginx-php71
commit = latest

docker: ## build image
	docker build -f Dockerfile -t $(repo):$(commit) .
	
docker-push: ## publish image to docker hub
	docker push $(repo)

help: ## Display this help message
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'