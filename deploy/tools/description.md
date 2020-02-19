The PerceptiLabs operator creates and maintains PerceptiLabs, a visual tool modeling for machine learning at warp speed.

PerceptiLabs visual modeling tool provides a GUI for building,
training, and assessing your models, while also enabling deeper
development with code. You get faster iterations and better
explainability of your results.

For more information visit [http://perceptilabs.com](http://perceptilabs.com).

# Features

**Fast modeling**  
Make changes, debug, and tune your model through the GUI of custom code
editor where every component/layer is reprogrammable. Choose from
multiple neural network models as well as classical AI methods.


**Transparency of Model Performance and Results**  
Get instant feedback about your model's performance through the
visualization of the architecture, to better review and understand the
results. See real-time analytics in every operation and variable, and
granular previews of output from each model component.


**Flexibility**  
Customize your environment and statistics dashboard. Use high-level
abstractions or low-level code. Execute any custom Python code or export
a fully trained TensorFlow model to perform inference in your projects.



# Installation Instructions  
For your convenience, we've included an example quickstart for running PerceptiLabs in demo mode.

## Prepare your namespace  
Choose or create the namespace into which you'd like install PerceptiLabs. For example:  
```
oc create namespace REPLACE_NAMESPACE
```

## Prepare storage for your data

You'll need to have a place on your cluster for storing training data and models.

Here's an example configuration for creating storage on a cluster hosted on AWS that you can tailor to your needs:

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: perceptilabs-example-sc
  annotations:
    description: Example Storage for PerceptiLabs
provisioner: kubernetes.io/aws-ebs
parameters:
  fsType: ext4
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: REPLACE_PVC_NAME
  namespace: REPLACE_NAMESPACE
spec:
  storageClassName: perceptilabs-example-sc
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
```

## Subscribe to the PerceptiLabs operator in your namespace

If you're using the OpenShift console webpage, just click the Install button on this operator. If not, you can customize and apply this configuration:

```
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: REPLACE_NAMESPACE-operatorgroup
  namespace: REPLACE_NAMESPACE
spec:
  targetNamespaces:
  - REPLACE_NAMESPACE
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: perceptilabs-operator
  namespace: REPLACE_NAMESPACE
spec:
  channel: stable
  name: perceptilabs-operator-package
  source: perceptilabs-operators
  sourceNamespace: openshift-marketplace
  namespace: REPLACE_NAMESPACE
```

After this, you should see a `perceptilabs-operator` pod start up in your namespace. In that pod, the log for the `operator` container should eventually say "starting to serve".

## Start a copy of PerceptiLabs

This is where you connect your storage and service account to a PerceptiLabs instance and run it. You can customize and apply the following configuration:

```
apiVersion: perceptilabs.com/v1
kind: PerceptiLabs
metadata:
  name: example-perceptilabs
  namespace: REPLACE_NAMESPACE
spec:
  namespace: REPLACE_NAMESPACE
  corePvc: REPLACE_PVC_NAME
```

At this point two pods named 'perceptilabs-core-...' and 'perceptilabs-frontend-...` will start up in your namespace.

## Copy data files to your cluster

If you've used the persistent storage configuration from above, then you have a read-write volume mounted in the pod at `/mnt/plabs`. Copy your files there:

```
oc cp REPLACE_FILENAME --namespace=REPLACE_NAMESPACE REPLACE_CORE_POD_NAME:/mnt/plabs --container=core
```

## Get the URL of your PerceptiLabs

Once everything is up and running, you'll have two new routes in your namespace. Go to the routes for your namespace and follow the link named `perceptilabs-frontend`. Your browser will be connected to your instance of PerceptiLabs! Alternatively, you can get the URL from the command line:

```
oc get routes --namespace REPLACE_NAMESPACE perceptilabs-frontend
```


