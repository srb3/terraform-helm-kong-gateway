.PHONY: all build test out clean
SHELL := /usr/bin/env bash

IMAGENAME=inspec-k8s-runner
IMAGEREPO=srb3/$(IMAGENAME)
WORKDIR=/share

DOCKERBUILD=docker build -t $(IMAGEREPO):latest .
DOCKER_COMMAND=docker run --rm -t -v `pwd`:$(WORKDIR) -v $(HOME)/.kube:/root/.kube:ro -v $(HOME)/.minikube:$(HOME)/.minikube

IMAGEPATH=$(IMAGEREPO):latest
INSPECRUN_BASIC=$(DOCKER_COMMAND) $(IMAGEPATH) exec default/ -t k8s://
INSPECRUN_KONG=$(DOCKER_COMMAND) $(IMAGEPATH) exec kong/ --input-file /$(WORKDIR)/attributes.yaml

# --reporter=json:$(WORKDIR)/output.json

all: build test clean

build: build_deployment_default
test: test_deployment_default
clean: clean_deployment_default

build_deployment_default:
	@pushd examples/default; \
	terraform init; \
	terraform apply -auto-approve; \
	popd

test_deployment_default:
	@pushd examples/default; \
	echo "testing ..."; \
	popd

clean_deployment_default:
	@pushd examples/default; \
	echo "running terraform destroy"; \
	terraform destroy -auto-approve; \
	echo "After running destroy"; \
	popd; \
	pushd test; \
	if [ -f output.log ];then cat output.log;fi

test_deployment_default:
	@pushd test; \
	echo "Building $(IMAGEREPO):latest"; \
	$(DOCKERBUILD); \
	echo "Running basic test in $(IMAGEREPO):latest: inspec exec default/ -t k8s://"; \
	$(INSPECRUN_BASIC) > output.log; \
	if [ "$$?" -ne "0" ]; then cat output.log; exit 1;fi; \
	echo "Running kong api test in $(IMAGEREPO):latest: inspec exec kong/"; \
	$(INSPECRUN_KONG) >> output.log; \
	if [ "$$?" -ne "0" ]; then cat output.log; exit 1;fi; \
	cat output.log; \
	popd
