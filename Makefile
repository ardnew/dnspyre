export GO111MODULE := on

EXECUTABLE = dnspyre
GITCOMMIT:=$(shell git describe --dirty --always)
VERSION = $(GITCOMMIT)
GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)

all: check test build

MAKEFLAGS += --no-print-directory

check:
ifeq (, $(shell which golangci-lint))
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(GOPATH)/bin v1.45.2
endif
	golangci-lint run
	go mod tidy -compat=1.17

test:
	@echo "Running tests"
	go test -race -v ./...
	go mod tidy -compat=1.17

generate:
	@echo "Running generate"
	go generate

build: generate
	@echo "Running build"
	go build -ldflags="-X 'github.com/tantalor93/dnspyre/v2/cmd/dnspyre.Version=$(VERSION)-$(GOOS)-$(GOARCH)'" -o bin/$(EXECUTABLE)

release: generate
	@echo "Running release build"
	env GOOS=darwin GARCH=amd64 go build -ldflags="-X 'github.com/tantalor93/dnspyre/v2/cmd/dnspyre.Version=$(VERSION)-darwin-amd64'" -o bin/$(EXECUTABLE)-darwin-amd64
	env GOOS=linux GARCH=amd64 go build -ldflags="-X 'github.com/tantalor93/dnspyre/v2/cmd/dnspyre.Version=$(VERSION)-linux-amd64'" -o bin/$(EXECUTABLE)-linux-amd64
	env GOOS=windows GARCH=amd64 go build -tags -ldflags="-X 'github.com/tantalor93/dnspyre/v2/cmd/dnspyre.Version=$(VERSION)-windows-amd64'" -o bin/$(EXECUTABLE)-windows-amd64

clean:
	rm -rf "bin/"

.PHONY: all check test generate build clean
