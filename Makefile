APP_NAME             = perceptilabs-operator
APP_REPOSITORY       = ${APP_NAME}-package
APP_REGISTRY_API     = https://quay.io/cnr/api/v1/packages
REGISTRY_ACCOUNT     = perceptilabs
OPERATOR_REPO        = perceptilabs-operator
OPERATOR_REPO_URL    = quay.io/${REGISTRY_ACCOUNT}/${OPERATOR_REPO}
VERSION_FILE         = version
IMAGES_TAG_FILE      = images-tag
RELEASE_VERSION      = $(shell cat ${VERSION_FILE} | tr -d '\n')
OLM_CATALOG_DIR      = deploy/olm-catalog
TOOLS_DIR            = deploy/tools

require-%:
	@: $(if ${${*}},,$(error You must set the $* environment variable))

make-new-version: require-RELEASE_VERSION require-IMAGES_TAG require-NEW_VERSION ## Create a new version of the operator
	${TOOLS_DIR}/make-new-version ${RELEASE_VERSION} ${NEW_VERSION} ${OPERATOR_REPO_URL} ${APP_NAME}
	echo ${NEW_VERSION} > ${VERSION_FILE}
	echo ${IMAGES_TAG} > ${IMAGES_TAG_FILE}
	@read -p "Make sure you commit your changes to git. Press enter when complete."

revert-new-version: ## Undo creation of a new version
	@${TOOLS_DIR}/revert-new-version

publish-to-quay: require-QUAY_AUTH_TOKEN ## Push the current version of the operator to the repos
	@${TOOLS_DIR}/pre-check ${APP_REGISTRY_API}/${REGISTRY_ACCOUNT}/${APP_REPOSITORY} ${RELEASE_VERSION}
	@${TOOLS_DIR}/publish-to-quay $(shell cat ${IMAGES_TAG_FILE} | tr -d '\n') ${RELEASE_VERSION}
	@# operator-sdk insists on having a "v" prefix to the version, but that's at odds with the way we want to do versioning. Retag the image before pushing
	operator-sdk build ${OPERATOR_REPO_URL}:v${RELEASE_VERSION}
	docker tag ${OPERATOR_REPO_URL}:v${RELEASE_VERSION} ${OPERATOR_REPO_URL}:${RELEASE_VERSION}
	docker rmi ${OPERATOR_REPO_URL}:v${RELEASE_VERSION}
	docker push ${OPERATOR_REPO_URL}:${RELEASE_VERSION}
	# now push the different metadata info to the quay application repo
	operator-courier --verbose push ${OLM_CATALOG_DIR}/${APP_NAME} ${REGISTRY_ACCOUNT} ${APP_REPOSITORY} ${RELEASE_VERSION} "${QUAY_AUTH_TOKEN}"

submit-to-redhat: ## Submit docker images to scan.connect.redhat.com. (Does not upload the operator metadata, which is a manual step)
	${TOOLS_DIR}/submit-to-redhat ${RELEASE_VERSION}
	${TOOLS_DIR}/zipbundle perceptilabs-operator ${RELEASE_VERSION}
	@read -p "The zips for this version in bundles/ should be uploaded to connect.redhat.com"

run-scorecard: ## Run operator scorecard in our cluster
	${TOOLS_DIR}/run_scorecard ${RELEASE_VERSION} ${APP_NAME}

.PHONY: make-new-version publish-to-quay submit-to-redhat help
.DEFAULT_GOAL := help
help: ## Show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

