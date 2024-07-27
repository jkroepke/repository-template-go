##
# Console Colors
##
GREEN  := \033[0;32m
YELLOW := \033[0;33m
WHITE  := \033[0;37m
CYAN   := \033[0;36m
RESET  := \033[0m

# renovate: github=golangci/golangci-lint
GO_LINT_CI_VERSION := v1.59.1

# Get the current working directory
CURRENT_DIR := $(CURDIR)

# Get the directory name of the current working directory
PROJECT_NAME := $(notdir $(CURRENT_DIR))

# Get the GOOS value
GOOS := $(shell go env GOOS)

# Determine the output file extension based on the GOOS value
ifeq ($(GOOS),windows)
    EXT := .exe
else
    EXT :=
endif

##
# Targets
##
.PHONY: help
help: ## show this help.
	@echo "Project: $(PROJECT_NAME)"
	@echo 'Usage:'
	@echo "  ${GREEN}make${RESET} ${YELLOW}<target>${RESET}"
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "  ${GREEN}%-21s${YELLOW}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST) | sort

.PHONY: clean
clean: ## clean builds dir
	@rm -rf "$(PROJECT_NAME)" "$(PROJECT_NAME).exe" dist/

.PHONY: check
check: test lint golangci ## Run all checks locally

.PHONY: update
update:  ## Run dependency updates
	@go get -u ./...
	@go mod tidy

.PHONY: build  ## Build the project
build: clean $(PROJECT_NAME)

$(PROJECT_NAME):
	@go build -o $(PROJECT_NAME)$(EXT) .

.PHONY: test
test:  ## Test the project
	@go test -race ./...

.PHONY: lint
lint: golangci  ## Run linter

.PHONY: fmt  ## Format code
fmt:
	@go fmt ./...
	@-go run github.com/daixiang0/gci@latest write .
	@-go run mvdan.cc/gofumpt@latest -l -w .
	@-go run golang.org/x/tools/cmd/goimports@latest -l -w .
	@-go run github.com/bombsimon/wsl/v4/cmd...@latest -strict-append -test=true -fix ./...
	@-go run github.com/catenacyber/perfsprint@latest -fix ./...
	@-go run github.com/tetafro/godot/cmd/godot@latest -w .
	# @-go run go run github.com/ssgreg/nlreturn/v2/cmd/nlreturn@latest -fix ./...
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint@${GO_LINT_CI_VERSION} run ./... --fix

.PHONY: golangci
golangci:
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint@${GO_LINT_CI_VERSION} run ./...

.PHONY: 3rdpartylicenses
3rdpartylicenses:
	@go run github.com/google/go-licenses@latest save . --save_path=3rdpartylicenses