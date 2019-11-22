# perceptilabs-operator

## Prerequisites

* Docker
* the OpenShift CLI from your RedHat account
* [operator-sdk](https://github.com/operator-framework/operator-sdk)
* `operator-courier` (installed with `pip install -r requirements.txt`)
* [jq](https://stedolan.github.io/jq/download/)

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

## Deploy Operator to Cluster

1. Set up your creds
```
$  export KUBECONFIG=<path to your kubeconfig for the cluster>
```
... or ...
```
$ oc login <path to the cluster>
```

2. create custom resource definiton
*TODO: this should be built into the operator*
```
$ oc apply -f crds/perceptilabs_v1alpha1_perceptilabs_crd.yaml
```

3. Add the operator to the cluster and wait
```
$ tools/add-operator-and-wait
```

## Set Up Namespace for Operator

1. Create the namespace
```
$ oc apply -f tools/namespace.yaml
```

2. Create the container registry secret
```
$ oc create secret docker-registry perceptilabs-docker --namespace=p1 --docker-server=perceptilabs.azurecr.io --docker-username=perceptilabs --docker-password=<password>
```

3. Create the service account in the namespace
```
$ oc apply -f tools/sa.yaml
```

4. Subscribe to the operator in the namespace
```
$ tools/subscribe-and-wait
```

## Instantiate the Operator

1. Create instance of Perceptilabs custom resource that will then run
   the core and frontend
```
$ oc apply -f tools/start-instance.yaml  
```

## Complete Removal
```
oc delete namespace p1
oc delete deployment -n openshift-marketplace perceptilabs-operators
oc delete operatorsources --namespace=openshift-marketplace perceptilabs-operators
oc delete customresourcedefinitions perceptilabs.perceptilabs.com
```
