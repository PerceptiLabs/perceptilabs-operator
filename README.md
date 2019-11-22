# perceptilabs-operator

## Prerequisites

* Docker
* the OpenShift CLI from your RedHat account
* [operator-sdk](https://github.com/operator-framework/operator-sdk)
* `operator-courier` (installed with `pip install -r requirements.txt`)
* [jq](https://stedolan.github.io/jq/download/)

## Build Image

```
operator-sdk build perceptilabs.azurecr.io/perceptilabs-operator:vx.y.z
docker push perceptilabs.azurecr.io/perceptilabs-operator:vx.y.z
```

## Deploy Image

1. Move to the deploy directory
```
$ cd deploy
```

2. Build the operator and push it to the application registry
```
$ ./push-application
```
Give it the quay.io password when it asks

3. Go to the application on the [quay website](https://quay.io/application/perceptilabs/perceptilabs-operator-beta) and make sure it's public
*TODO: make a way to use it as a private application*

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
```
$ oc apply -f crds/perceptilabs_v1alpha1_perceptilabs_crd.yaml
```

3. Add the operator to the cluster and wait
```
$ ./add-operator-and-wait
```

## Set Up Namespace for Operator

1. Create the namespaced items
```
$ oc apply -f namespace.yaml
$ oc apply -f role.yaml
$ oc apply -f service_account.yml
$ oc apply -f operator_group.yml
$ oc apply -f role_binding.yml
```

2. Create the container registry secret
```
$ oc create secret docker-registry perceptilabs-docker --namespace=p1 --docker-server=perceptilabs.azurecr.io --docker-username=perceptilabs --docker-password=<password>
```

3. Link the secret to the service account
```
$ oc secret link --namespace=p1 perceptilabs-operator perceptilabs-docker --for=pull
```

4. Subscribe to the operator in the namespace
```
$ oc apply -f subscription.yaml              
```

## Instantiate the Operator

1. Create custom resource representing the perceptilabs
```
$ oc apply -f start-instance.yaml  
```
