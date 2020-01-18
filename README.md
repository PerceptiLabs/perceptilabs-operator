# perceptilabs-operator

## To Make a new operator version


1. Install additional prerequisites
  * [operator-sdk](https://github.com/operator-framework/operator-sdk) v0.13.0
  * `sed`
  * [yq](https://github.com/mikefarah/yq)
  * [jq](https://stedolan.github.io/jq/download/)

1. Make it
    ```
    NEW_VERSION=0.0.7 PRODUCT_LEVEL=demo IMAGES_TAG=754 make make-new-version
    ```
1. Some files will be modified. Commit them to source and push them.

## To Build The Operator Image and push it to quay

1. Install additional prerequisites
    * Docker
    * [jq](https://stedolan.github.io/jq/download/)
    * `operator-courier` (installed with `pip install -r requirements.txt`)
    * [operator-sdk](https://github.com/operator-framework/operator-sdk)
      v0.13.0
    * [docker](https://www.docker.com/get-started)
1. Get and export the `QUAY_AUTH_TOKEN` environment variable using [these directions](https://github.com/operator-framework/operator-courier#authentication)
1. Publish the new version of the operator.
    ```
    PRODUCT_LEVEL=demo make publish
    ```
1. If it's the first push to the repos, they need to be made public:
    * Go to the application on the [quay website](https://quay.io/application/perceptilabs/perceptilabs-operator-demo?tab=settings) and make sure it's public.
    * Do the same for the [repository](https://quay.io/repository/perceptilabs/perceptilabs-operator?tab=settings).
