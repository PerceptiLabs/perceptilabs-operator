# perceptilabs-operator

## To Make a new operator version


1. Install additional prerequisites
   * [operator-sdk](https://github.com/operator-framework/operator-sdk)
     v0.13.0
   * `sed`
   * [yq](https://github.com/mikefarah/yq)
1. Make it
    ```
    NEW_VERSION=x.y.z make make-new-version
    ```

## To Build The Operator Image and push it to quay

1. Install additional prerequisites
    * Docker
    * [jq](https://stedolan.github.io/jq/download/)
    * `operator-courier` (installed with `pip install -r requirements.txt`)
    * [operator-sdk](https://github.com/operator-framework/operator-sdk)
      v0.13.0
1. Get and export the `QUAY_AUTH_TOKEN` environment variable using [these directions](https://github.com/operator-framework/operator-courier#authentication)
1. Build, tag, and push it
      ```
      make release
      ```

1. If it's the first push to the repos, they need to be made public:
    * Go to the application on the [quay website](https://quay.io/application/perceptilabs/perceptilabs-operator-beta?tab=settings) and make sure it's public.
    * Do the same for the [repository](https://quay.io/repository/perceptilabs/perceptilabs-operator?tab=settings).
