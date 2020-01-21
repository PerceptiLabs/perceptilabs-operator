APP_NAME     			=  perceptilabs-operator
APP_REPOSITORY    =  ${APP_NAME}-package
APP_REGISTRY_API  =  https://quay.io/cnr/api/v1/packages
REGISTRY_ACCOUNT  =  perceptilabs
OPERATOR_NAME     =  perceptilabs-operator
OPERATOR_REPO     =  quay.io/${REGISTRY_ACCOUNT}/${OPERATOR_NAME}
VERSION_FILE      =  version
IMAGES_TAG_FILE   =  images-tag
OPERATOR_VERSION  =  $(shell cat ${VERSION_FILE} | tr -d '\n')
OLM_CATALOG_DIR   =  deploy/olm-catalog
TOOLS_DIR         =  deploy/tools

require-%:
	@: $(if ${${*}},,$(error You must set the $* environment variable))

make-new-version: require-OPERATOR_VERSION require-IMAGES_TAG require-NEW_VERSION ## Create a new version of the operator
	${TOOLS_DIR}/make-new-version ${OPERATOR_VERSION} ${NEW_VERSION} ${OPERATOR_REPO} ${APP_NAME} ${IMAGES_TAG}
	echo ${NEW_VERSION} > ${VERSION_FILE}
	echo ${IMAGES_TAG} > ${IMAGES_TAG_FILE}
	@read -p "Make sure you commit your changes to git. Press enter when complete."

publish: require-QUAY_AUTH_TOKEN ## Push the current version of the operator to the repos
	@${TOOLS_DIR}/pre-check ${APP_REGISTRY_API}/${REGISTRY_ACCOUNT}/${APP_REPOSITORY} ${OPERATOR_VERSION}
	@${TOOLS_DIR}/publish-to-quay $(shell cat ${IMAGES_TAG_FILE} | tr -d '\n')
	operator-sdk build ${OPERATOR_REPO}:v${OPERATOR_VERSION}
	docker push ${OPERATOR_REPO}:v${OPERATOR_VERSION}
	operator-courier --verbose push ${OLM_CATALOG_DIR}/${APP_NAME} ${REGISTRY_ACCOUNT} ${APP_REPOSITORY} ${OPERATOR_VERSION} "${QUAY_AUTH_TOKEN}"

.PHONY: help
.DEFAULT_GOAL := help

# from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
