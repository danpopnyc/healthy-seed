MODULE = $(shell go list -m)
VERSION ?= $(shell git describe --tags --always --dirty --match=v* 2> /dev/null || echo "0.0.1")
PACKAGES ?= $(shell go list ./... | grep -v /vendor/ 2> /dev/null || "")
# Arguments to pass on each go tool link invocation. In this case, setting the version.
LDFLAGS := -ldflags "-X main.Version=${VERSION}"

.PHONY: default
default: help

# generate help info from comments: thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## help information about make commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: run
run: ## run the API server
	go run ${LDFLAGS} cmd/server/main.go

.PHONY: build
build:  ## build the API server binary
	CGO_ENABLED=0 go build ${LDFLAGS} -a -o server $(MODULE)/cmd/server

.PHONY: build-docker
build-docker: ## build the API server as a docker image
	docker build -f cmd/server/Dockerfile -t server .

.PHONY: version
version: ## display the version of the API server
	@echo $(VERSION)

.PHONY: lint
lint: ## run golint on all Go package
	@golint $(PACKAGES)

.PHONY: fmt
fmt: ## run "go fmt" on all Go packages
	@go fmt $(PACKAGES)