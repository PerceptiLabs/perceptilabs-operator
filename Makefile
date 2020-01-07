# Targets of interest
# deploy - the main target you use to deploy to 
APP_REPOSITORY      =  perceptilabs-operator-beta
APP_NAME            =  perceptilabs-operator-beta
APP_REGISTRY_API    =  https://quay.io/cnr/api/v1/packages
DOCKER_SECRET_NAME  =  perceptilabs-docker
DOCKER_SERVER       =  perceptilabs.azurecr.io
DOCKER_USERNAME     =  perceptilabs
REGISTRY            =  quay.io
REGISTRY_ACCOUNT    =  perceptilabs
OPERATOR_NAME       =  perceptilabs-operator
OPERATOR_REPO       =  ${REGISTRY}/${REGISTRY_ACCOUNT}/${OPERATOR_NAME}
OPERATOR_VERSION    =  0.0.3
OLM_CATALOG_DIR     =  deploy/olm-catalog
SERVICEACCOUNT_NAME =  perceptilabs-operator-sa
CORE_VERSION        := $(or $(CORE_VERSION),'latest')
FRONTEND_VERSION    := $(or $(FRONTEND_VERSION),'latest')
TEMPLATE_CMD        =  @sed 's+REPLACE_NAMESPACE+${NAMESPACE}+g; s+REPLACE_SERVICEACCOUNT_NAME+${SERVICEACCOUNT_NAME}+g; s+REPLACE_CORE_VERSION+${CORE_VERSION}+g; s+REPLACE_FRONTEND_VERSION+${FRONTEND_VERSION}+g'
TOOLS_DIR           =  deploy/tools

require-%:
	@: $(if ${${*}},,$(error You must pass the $* environment variable))

make-new-version: require-NEW_VERSION ## Create a new version of the operator
	@${TOOLS_DIR}/make-new-version ${OPERATOR_VERSION} ${NEW_VERSION} ${OPERATOR_REPO} ${APP_NAME}
	@read -p "Make sure you update the OPERATOR_VERSION in the Makefile [ok]"

release: require-QUAY_AUTH_TOKEN require-APP_NAME require-REGISTRY_ACCOUNT require-OPERATOR_VERSION require-QUAY_AUTH_TOKEN ## Push the current version of the operator to the repos
	@${TOOLS_DIR}/pre-build ${APP_REGISTRY_API}/${REGISTRY_ACCOUNT}/${APP_REPOSITORY} ${OPERATOR_VERSION}
	operator-sdk build ${OPERATOR_REPO}:v${OPERATOR_VERSION}
	docker push ${OPERATOR_REPO}:v${OPERATOR_VERSION}
	operator-courier --verbose push ${OLM_CATALOG_DIR}/${APP_NAME} ${REGISTRY_ACCOUNT} ${APP_REPOSITORY} ${OPERATOR_VERSION} "${QUAY_AUTH_TOKEN}"

install-custom-operator: ## Install the custom OperatorSource from the repos to the cluster
	@${TOOLS_DIR}/pre-deploy ${APP_REGISTRY_API}/${REGISTRY_ACCOUNT}/${APP_REPOSITORY}
	@oc apply -f ${OLM_CATALOG_DIR}/operator-source.yaml
	@${TOOLS_DIR}/wait_for_log "openshift-marketplace" "perceptilabs-operators-" "serving registry" "perceptilabs-operators" &>/dev/null
	@echo operator pod is running

namespace: require-NAMESPACE
	@${TEMPLATE_CMD} ${TOOLS_DIR}/namespace.yaml | oc apply -f -

secret: namespace require-PERCEPTILABS_AZURECR_PWD ## Create the docker pull secret for core and frontend in NAMESPACE
	@oc get secret --namespace=${NAMESPACE} ${DOCKER_SECRET_NAME} &>/dev/null || \
		oc create secret docker-registry ${DOCKER_SECRET_NAME} --namespace=${NAMESPACE} --docker-server=${DOCKER_SERVER} --docker-username=${DOCKER_USERNAME} --docker-password="${PERCEPTILABS_AZURECR_PWD}"

serviceaccount: secret require-SERVICEACCOUNT_NAME
	@${TEMPLATE_CMD} ${TOOLS_DIR}/sa.yaml | oc apply -f -

persistentvolume: namespace ## Create the persistent volume needed for core
	@${TEMPLATE_CMD} ${TOOLS_DIR}/persistentvolume.yaml | oc apply -f -

subscription: install-custom-operator persistentvolume namespace serviceaccount
	@${TEMPLATE_CMD} ${TOOLS_DIR}/subscription.yaml | oc apply -f -
	@"${TOOLS_DIR}/wait_for_log" "${NAMESPACE}" "perceptilabs-operator-" "starting to serve" "operator"

instance: subscription ## Install perceptilabs in NAMESPACE
	@${TEMPLATE_CMD} ${TOOLS_DIR}/start-instance.yaml | oc apply -f -

route: frontend-pod ## Get the frontend route for perceptilabs in NAMESPACE
	@${TOOLS_DIR}/get_live_route ${NAMESPACE} perceptilabs-frontend

core-pod: instance
	@"${TOOLS_DIR}/wait_for_log" "${NAMESPACE}" "perceptilabs-core-" "Connected" "core"
	@$(eval CORE_POD=$(shell ${TOOLS_DIR}/get_running_pod ${NAMESPACE} perceptilabs-core- | tail -n 1))

frontend-pod: instance
	@${TOOLS_DIR}/get_running_pod ${NAMESPACE} perceptilabs-frontend- | tail -n 1

valid-storage: core-pod
	@oc cp README.md --namespace=${NAMESPACE} ${CORE_POD}:/mnt/plabs --container=core

deploy: valid-storage route ## Deploy and check the perceptilabs operator to the cluster and print the frontend route

clean-namespace: ## Remove the installed namespace and everything in it
	${TEMPLATE_CMD} ${TOOLS_DIR}/namespace.yaml | oc delete --ignore-not-found -f -

clean-storage: ## Remove the persistent volume
	${TEMPLATE_CMD} ${TOOLS_DIR}/persistentvolume.yaml | oc delete --ignore-not-found -f -

clean-cluster: clean-namespace clean-storage ## Remove all perceptilabs-related objects from the cluster
	@${TEMPLATE_CMD} ${OLM_CATALOG_DIR}/operator-source.yaml | oc delete --ignore-not-found -f -

.PHONY: help
.DEFAULT_GOAL := help

# script-kiddied from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
