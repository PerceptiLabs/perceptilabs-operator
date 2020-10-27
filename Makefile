APP_NAME          = perceptilabs-operator
PROJECT_ROOT      = $(shell git rev-parse --show-toplevel)
TOOLS_DIR         = ${PROJECT_ROOT}/deploy/tools

require-%:
	@: $(if ${${*}},,$(error You must set the $* environment variable))

	@read -p "Make sure you commit your changes to git. Press enter when complete."

stage-for-quay:
	${TOOLS_DIR}/stage-for-quay

build-for-quay: stage-for-quay
	${TOOLS_DIR}/build-for-quay
	@read -p "Make sure you commit your changes to git. Press enter when complete."

push-to-quay: build-for-quay
	${TOOLS_DIR}/push-to-quay

# building the registry requires everything to be in quay
build-registry-for-quay: push-to-quay
	${TOOLS_DIR}/build-registry-for-quay

quay: build-registry-for-quay

stage-for-rh:
	${TOOLS_DIR}/stage-for-rh

build-for-rh: stage-for-rh
	${TOOLS_DIR}/build-for-rh

release-pl-images: build-for-rh
	@${TOOLS_DIR}/push-images-to-rh "core-fe-op"

release-bundle:
	@${TOOLS_DIR}/push-images-to-rh "bundle"

release: release-pl-images release-bundle

# run-scorecard: ## Run operator scorecard in our cluster
# 	${TOOLS_DIR}/run_scorecard ${RELEASE_VERSION} ${APP_NAME}

.PHONY: make-new-version publish-to-quay submit-to-redhat help
.DEFAULT_GOAL := help
help: ## Show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
