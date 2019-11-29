# perceptilabs-operator

## Prerequisites

* Docker
* the OpenShift CLI from your RedHat account
* [operator-sdk](https://github.com/operator-framework/operator-sdk)
* `operator-courier` (installed with `pip install -r requirements.txt`)
* [jq](https://stedolan.github.io/jq/download/)
* `envsubst` in your path.

## Build The Operator Image

1. Build and tag it
```
operator-sdk build quay.io/perceptilabs/perceptilabs-operator:vx.y.z
```

1. Push it to the container repository
```
docker push quay.io/perceptilabs/perceptilabs-operator:vx.y.z
```

1. Tag and push this version as latest
*TODO: this should go away and have each version of the csv refer to a
specific version of the operator repo*
```
docker tag quay.io/perceptilabs/perceptilabs-operator:v1 quay.io/perceptilabs/perceptilabs-operator:latest
docker push quay.io/perceptilabs/perceptilabs-operator:latest
```

## Make the Operator Available

1. Move to the deploy directory
```
$ cd deploy
```

2. Build the operator clusterserviceversion and push it to the application registry
```
$ VERSION=vx.y.z tools/push-application
```
Give it the quay.io password when it asks. Alternatively, set `QUAY_AUTH_TOKEN` in your environment the value it displays

3. Go to the application on the [quay website](https://quay.io/application/perceptilabs/perceptilabs-operator-beta) and make sure it's public

## Deploy Operator Application to Cluster

1. Set up your creds
```
$  export KUBECONFIG=<path to your kubeconfig for the cluster>
```
... or ...
```
$ oc login <path to the cluster>
```

2. Add the operator to the cluster and wait
```
$ tools/add-operator-and-wait
```

## Set Up Namespace for Operator

1. Set up for the namespace
```
NS=your-namespace SA_NAME=perceptilabs-operator-sa PL_DOCKER_PWD=<password> tools/set-up-namespace
```

## Complete Removal
```
NS=your-namespace tools/clean-cluster
```
