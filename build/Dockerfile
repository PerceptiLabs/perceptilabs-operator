FROM quay.io/operator-framework/ansible-operator:v0.10.0

LABEL name="PerceptiLabs-Modeling-Operator" \
      vendor="PerceptiLabs" \
      version="1.0" \
      release="1" \
      summary="This is the trial version of the operator of our modeling platform v1." \
      description="This operator will deploy Perceptilabs Modelling to the cluster."

COPY licenses /licenses 

COPY watches.yaml ${HOME}/watches.yaml

COPY roles/ ${HOME}/roles/
COPY playbook.yml ${HOME}/playbook.yml
