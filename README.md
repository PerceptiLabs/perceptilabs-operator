# perceptilabs-operator

## Usage

this assumes the CRC environment - https://github.com/code-ready/crc but you can use any OpenShift cluster since `4.0`

```
1. start the cluster 
$ crc start

2. create custom resource definiton
$ oc apply -f deploy/crds/perceptilabs_v1alpha1_perceptilabs_crd.yaml

3. create RBAC and deploy the operator
$ oc apply -f deploy/

4. later on create custom resource representing the perceptilabs
$ oc apply -f deploy/crds/perceptilabs_v1alpha1_perceptilabs_cr.yaml
```
