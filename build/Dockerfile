FROM quay.io/operator-framework/ansible-operator:v0.10.0

LABEL name="PerceptiLabs-Modeling-Operator" \
      vendor="PerceptiLabs" \
      version="1.0.5" \
      release="1" \
      summary="This is the operator of the PerceptiLabs Modelling tool." \
      description="This operator will deploy PerceptiLabs Modelling to the cluster."

COPY licenses /licenses 

COPY watches.yaml ${HOME}/watches.yaml

COPY roles/ ${HOME}/roles/
COPY playbook.yml ${HOME}/playbook.yml
