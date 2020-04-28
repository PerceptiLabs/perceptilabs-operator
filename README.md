# perceptilabs-operator

## To Make a new operator version


1. Install additional prerequisites
  * [operator-sdk](https://github.com/operator-framework/operator-sdk) v0.13.0
  * `sed`
  * [yq](https://github.com/mikefarah/yq)
  * [jq](https://stedolan.github.io/jq/download/)

1. Make it
    ```
    NEW_VERSION=0.0.7 IMAGES_TAG=754 make make-new-version
    ```
1. Some files will be modified and some others added. Commit them to source and push them.

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
    make publish-to-quay
    ```
1. If it's the first push to the repos, they need to be made public:
    * Go to the application on the [quay website](https://quay.io/application/perceptilabs/perceptilabs-operator?tab=settings) and make sure it's public.
    * Do the same for the [repository](https://quay.io/repository/perceptilabs/perceptilabs-operator?tab=settings).

1. Suggestion: use `NAMESPACE=<ns> make deploy-for-test` from the
   `operator-tools` repo to try out the new version of the operator.

## To submit the operator to RedHat for eventual release

1. Run the make command
    ```
    make submit-to-redhat
    ```
    ... this can take a while, depending on your internet connection.
    It will prompt you to do some manual steps. These are important.

1. Go to the RedHat "Certified Technology Portal" and make sure the
   new version shows up and that scans go smoothly:
  * Operator: https://connect.redhat.com/project/2727121/view
  * Core: https://connect.redhat.com/project/2727091/view
  * Frontend: https://connect.redhat.com/project/2727111/view

  ... Note: you may have to wait some time (up to a day) since the website is usually
very slow to pick up new images and scan them.

1. Once the three container images are scanned, click the "Publish" link
   next to the new version on each of the above. Wait for the version to
be marked as published

1. Verify that you can pull the images from the redhat docker repos.
   These three pulls should all succeed.
  1. `docker pull registry.connect.redhat.com/perceptilabs/perceptilabs-operator:<version>`
  1. `docker pull registry.connect.redhat.com/perceptilabs/perceptilabs-core-1:<version>`
  1. `docker pull registry.connect.redhat.com/perceptilabs/perceptilabs-frontend-1:<version>`

1. Upload the operator metadata.
  1. Go to the operator's metadata page:
     https://connect.redhat.com/project/2727121/operator-metadata
  1. Click "Replace File"
  1. Select the zip at
     .../perceptilabs-operator/operator_metadata_for_rh/zips/perceptilabs-operator.<the version>.zip
  1. Poll for a success message on that page.

1. Publish the operator metadata by clicking "Publish" once the metadata
   scan passes.
