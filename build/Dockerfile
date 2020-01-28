FROM quay.io/operator-framework/ansible-operator:v0.10.0

LABEL name="PerceptiLabs-Modeling-Operator" \
      vendor="PerceptiLabs" \
      version="1.0.7" \
      release="1" \
      summary="This is the operator of the PerceptiLabs Modeling tool." \
      description="This operator will deploy PerceptiLabs Modeling to the cluster."

COPY licenses /licenses 

COPY watches.yaml ${HOME}/watches.yaml

COPY roles/ ${HOME}/roles/
COPY playbook.yml ${HOME}/playbook.yml
