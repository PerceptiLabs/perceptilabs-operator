A bundled version of the contents of perceptilabs-operator has
been pushed to quay.io under the tmckayus account. It can be
added to OpenShift by creating the OperatorSource included here.

```
oc create -f operator-source.yaml
```

After this, the operator should show up in the OperatorHub
listed as a "custom" operator.
