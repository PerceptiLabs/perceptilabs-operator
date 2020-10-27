# perceptilabs-operator

## To Make a new operator version


1. Install additional prerequisites
  * [operator-sdk](https://sdk.operatorframework.io/docs/installation/install-operator-sdk/#install-from-homebrew-macos)
  * `sed`
  * [yq](https://github.com/mikefarah/yq)
  * [jq](https://stedolan.github.io/jq/download/)

1. Edit the versions.yaml file to add a new version

## Build The Operator Image and push it to quay

1. Install additional prerequisites
    * Docker
    * [jq](https://stedolan.github.io/jq/download/)
    * `operator-courier` (installed with `pip install -r requirements.txt`)
    * [operator-sdk](https://sdk.operatorframework.io/docs/installation/install-operator-sdk/#install-from-homebrew-macos) >= v1.1.0
    * [docker](https://www.docker.com/get-started)
1. Publish the new version of the operator.
    ```
    make quay
    ```
1. If it's the first push to the repos, they need to be made public:
    * Go to the application on the [quay website](https://quay.io/application/perceptilabs/perceptilabs-operator?tab=settings) and make sure it's public.
    * Do the same for the [repository](https://quay.io/repository/perceptilabs/perceptilabs-operator?tab=settings).

1. Suggestion: use `NAMESPACE=<ns> REGISTRY_VERSION=<the new version> make deploy-for-test` from the `operator-tools` repo to try out the new version of the operator.

## To submit the operator to RedHat for eventual release

1. Run the make command
    ```
    make release
    ```
    ... this can take a while, depending on your internet connection.
    It will prompt you to do some manual steps. These are important.

