MODULE_NAME ?= istio

# Module Registry used for pushing the image
MODULE_REGISTRY_PORT ?= 8888
MODULE_REGISTRY ?= op-kcp-registry.localhost:$(MODULE_REGISTRY_PORT)/unsigned

# Operating system architecture
OS_ARCH ?= $(shell uname -m)

# Operating system type
OS_TYPE ?= $(shell uname)

VERSION ?= dev

# ENVTEST_K8S_VERSION refers to the version of kubebuilder assets to be downloaded by envtest binary.
ENVTEST_K8S_VERSION = 1.31.0

# Istio install binary path for running the installation in separate process
ISTIO_INSTALL_BIN_PATH = ./bin/istio_install

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# Image URL to use all building/pushing image targets
APP_NAME = istio-manager

# Image URL to use all building/pushing image targets
IMG_REGISTRY_PORT ?= $(MODULE_REGISTRY_PORT)
IMG_REGISTRY ?= op-skr-registry.localhost:$(IMG_REGISTRY_PORT)/unsigned/operator-images
IMG ?= $(IMG_REGISTRY)/$(MODULE_NAME)-operator:$(MODULE_VERSION)

COMPONENT_CLI_VERSION ?= latest

# It is required for upgrade integration test
TARGET_BRANCH ?= ""

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Development

.PHONY: manifests
manifests: controller-gen ## Generate WebhookConfiguration, ClusterRole and CustomResourceDefinition objects.
	$(CONTROLLER_GEN) rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases

.PHONY: generate-integration-test-manifest
generate-integration-test-manifest: manifests kustomize module-version
	cd config/manager && $(KUSTOMIZE) edit set image controller=${IMG}
	$(KUSTOMIZE) build config/default -o tests/integration/steps/operator_generated_manifest.yaml

.PHONY: generate
generate: controller-gen ## Generate code containing DeepCopy, DeepCopyInto, and DeepCopyObject method implementations.
	$(CONTROLLER_GEN) object:headerFile="hack/boilerplate.go.txt" paths="./..."

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: test
test: manifests generate fmt vet envtest ## Run tests.
	KUBEBUILDER_CONTROLPLANE_START_TIMEOUT=2m KUBEBUILDER_CONTROLPLANE_STOP_TIMEOUT=2m KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) -p path)" go test $(shell go list ./... | grep -v /tests/integration | grep -v /tests/performance-grpc | grep -v /tests/e2e) -coverprofile cover.out

.PHONY: test-experimental-tag
test-experimental-tag: manifests generate fmt vet envtest ## Run tests.
	KUBEBUILDER_CONTROLPLANE_START_TIMEOUT=2m KUBEBUILDER_CONTROLPLANE_STOP_TIMEOUT=2m KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) -p path)" go test -tags experimental $(shell go list ./... | grep -v /tests/integration | grep -v /tests/performance-grpc | grep -v /tests/e2e) -coverprofile cover.out

##@ Build

.PHONY: build
build: generate fmt vet ## Build manager binary.
	go build -o bin/manager main.go
	go build -o $(ISTIO_INSTALL_BIN_PATH) cmd/istio-install/main.go

.PHONY: run
run: manifests install build create-kyma-system-ns ## Run a controller from your host.
	ISTIO_INSTALL_BIN_PATH=$(ISTIO_INSTALL_BIN_PATH) go run ./main.go

TARGET_OS ?= linux
TARGET_ARCH ?= amd64

.PHONY: docker-build
docker-build: ## Build docker image with the manager.
	IMG=$(IMG) docker buildx build -t ${IMG} --platform=${TARGET_OS}/${TARGET_ARCH} .

.PHONY: docker-build-experimental
docker-build-experimental: ## Build docker image with the experimental manager
	IMG=$(IMG) docker build -t ${IMG} --build-arg GO_BUILD_TAGS=experimental --platform=${TARGET_OS}/${TARGET_ARCH} .

.PHONY: docker-push
docker-push: ## Push docker image with the manager.
	docker push ${IMG}

##@ Local

.PHONY: local-run
local-run:
	make -C hack/local run

.PHONY: local-stop
local-stop:
	make -C hack/local stop

##@ Deployment

ifndef ignore-not-found
  ignore-not-found = false
endif

.PHONY: create-kyma-system-ns
create-kyma-system-ns:
	kubectl create namespace kyma-system --dry-run=client -o yaml | kubectl apply -f -
	kubectl label namespace kyma-system istio-injection=enabled --overwrite

.PHONY: install
install: manifests kustomize module-version ## Install CRDs into the K8s cluster specified in ~/.kube/config.
	$(KUSTOMIZE) build config/crd | kubectl apply -f -

.PHONY: uninstall
uninstall: manifests kustomize module-version ## Uninstall CRDs from the K8s cluster specified in ~/.kube/config. Call with ignore-not-found=true to ignore resource not found errors during deletion.
	$(KUSTOMIZE) build config/crd | kubectl delete --ignore-not-found=$(ignore-not-found) -f -

.PHONY: deploy
deploy: create-kyma-system-ns manifests kustomize module-version ## Deploy controller to the K8s cluster specified in ~/.kube/config.
	cd config/manager && $(KUSTOMIZE) edit set image controller=${IMG}
	$(KUSTOMIZE) build config/default | kubectl apply -f -

.PHONY: undeploy
undeploy: ## Undeploy controller from the K8s cluster specified in ~/.kube/config. Call with ignore-not-found=true to ignore resource not found errors during deletion.
	$(KUSTOMIZE) build config/default | kubectl delete --ignore-not-found=$(ignore-not-found) -f -

##@ Build Dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tool Binaries
KUSTOMIZE ?= $(LOCALBIN)/kustomize
CONTROLLER_GEN ?= $(LOCALBIN)/controller-gen
ENVTEST ?= $(LOCALBIN)/setup-envtest

## Tool Versions
KUSTOMIZE_VERSION ?= v5.5.0
CONTROLLER_TOOLS_VERSION ?= v0.16.5

KUSTOMIZE_INSTALL_SCRIPT ?= "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
.PHONY: kustomize
kustomize: $(KUSTOMIZE) ## Download kustomize locally if necessary.
$(KUSTOMIZE): $(LOCALBIN)
	test -s $(LOCALBIN)/kustomize || { curl -s $(KUSTOMIZE_INSTALL_SCRIPT) | bash -s -- $(subst v,,$(KUSTOMIZE_VERSION)) $(LOCALBIN); }

.PHONY: controller-gen
controller-gen: $(CONTROLLER_GEN) ## Download controller-gen locally if necessary.
$(CONTROLLER_GEN): $(LOCALBIN)
	test -s $(LOCALBIN)/controller-gen || GOBIN=$(LOCALBIN) go install sigs.k8s.io/controller-tools/cmd/controller-gen@$(CONTROLLER_TOOLS_VERSION)

.PHONY: gotestsum
gotestsum:
	test -s $(LOCALBIN)/gotestsum || GOBIN=$(LOCALBIN) go install gotest.tools/gotestsum@latest
  
.PHONY: envtest
envtest: $(ENVTEST) ## Download envtest-setup locally if necessary.
$(ENVTEST): $(LOCALBIN)
	test -s $(LOCALBIN)/setup-envtest || GOBIN=$(LOCALBIN) go install sigs.k8s.io/controller-runtime/tools/setup-envtest@latest

.PHONY: test-e2e-egress
test-e2e-egress: gotestsum
	$(LOCALBIN)/gotestsum --rerun-fails --packages="./tests/e2e/egress/..." --format "testname" -- -run '^TestE2E.*' ./tests/e2e/...

.PHONY: e2e-test
e2e-test:
	make -C tests/e2e/e2e/tests e2e-test
##@ Module

.PHONY: module-image
module-image: docker-build docker-push ## Build the Module Image and push it to a registry defined in IMG_REGISTRY
	echo "built and pushed module image $(IMG)"

.PHONY: generate-manifests
generate-manifests: kustomize module-version
	cd config/manager && $(KUSTOMIZE) edit set image controller=${IMG}
	bash hack/generate_sec_scanners_images_env.sh
	$(KUSTOMIZE) build config/default > istio-manager.yaml
	cat config/namespace/istio_system_namespace.yaml >> istio-manager.yaml

########## Grafana Dashboard ###########
.PHONY: grafana-dashboard
grafana-dashboard: ## Generating Grafana manifests to visualize controller status.
	cd operator && kubebuilder edit --plugins grafana.kubebuilder.io/v1-alpha

########## Integration Tests ###########
PULL_IMAGE_VERSION=PR-${PULL_NUMBER}
POST_IMAGE_VERSION=v$(shell date '+%Y%m%d')-$(shell printf %.8s ${PULL_BASE_SHA})

.PHONY: istio-integration-test
istio-integration-test: configuration-integration-test mesh-communication-integration-test installation-integration-test observability-integration-test

.PHONY: grpc-performance-test
grpc-performance-test:
	make -c tests/performance-grpc deploy-helm
	make -c tests/performance-grpc grpc-load-test
	make -c tests/performance-grpc export-results

.PHONY: configuration-integration-test
configuration-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestConfiguration

.PHONY: mesh-communication-integration-test
mesh-communication-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestMeshCommunication

.PHONY: installation-integration-test
installation-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestInstallation

.PHONY: observability-integration-test
observability-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestObservability

.PHONY: aws-integration-test
aws-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestAws
.PHONY: gcp-integration-test
gcp-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestGcp

.PHONY: evaluation-integration-test
evaluation-integration-test: install deploy
	cd tests/integration && TEST_REQUEST_TIMEOUT=600s && EXPORT_RESULT=true go test -v -timeout 35m -run TestEvaluation

.PHONY: deploy-latest-release
deploy-latest-release: create-kyma-system-ns
	cd tests/integration && ./scripts/deploy-latest-release-to-cluster.sh $(TARGET_BRANCH)

# Latest release deployed on cluster is a prerequisite, it is handled by deploy-latest-release target
.PHONY: istio-upgrade-integration-test
istio-upgrade-integration-test: deploy-latest-release generate-integration-test-manifest
	cd tests/integration && TEST_REQUEST_TIMEOUT=300s && EXPORT_RESULT=true go test -v -race -timeout 15m -run TestUpgrade

########## Gardener specific ###########

.PHONY: gardener-istio-integration-test
gardener-istio-integration-test:
	./hack/ci/gardener-integration.sh

.PHONY: gardener-aws-integration-test
gardener-aws-integration-test:
	./hack/ci/gardener-integration-aws-specific.sh

.PHONY: gardener-gcp-integration-test
gardener-gcp-integration-test:
	./hack/ci/gardener-integration-gcp-specific.sh

.PHONY: module-version
module-version:
	sed 's/VERSION/$(VERSION)/g' config/default/kustomization.template.yaml > config/default/kustomization.yaml
