#!/usr/bin/env bash
set -eo pipefail
log () {
    echo $(date +"%Y-%m-%d %H:%M:%S") $@
}

ZSH_VERSION=5.5.1
WORKON_HOME=PATH_TO_VIRTUALENV_DIRECTORY
VIRTUALENVWRAPPER_SCRIPT=PATH_TO_VIRTUALENVWRAPPER_SCRIPT

export AIRFLOW_HOME=PATH_TO_AIRFLOW_HOME_DIRECTORY
AIRFLOW_VERSION=2.0.1
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

log "activating python virtualenv"
virtualenv -p $(which python3.8) "${WORKON_HOME}/airflow"
source "${WORKON_HOME}/airflow/bin/activate"

log "upgrading wheel and pip package"
python3 -m pip install \
    wheel \
    pip \
    --upgrade 

log "installing apache airflow version: ${AIRFLOW_VERSION} using constraint url: ${CONSTRAINT_URL}"
python3 -m pip install \
    "apache-airflow[google,slack,telegram,docker,kubernetes,postgres,password,http]==${AIRFLOW_VERSION}" \
    --constraint "${CONSTRAINT_URL}" \
    --progress-bar=emoji \
    --force-reinstall \
    --upgrade 

log "installing apache airflow missing extras, for version: ${AIRFLOW_VERSION} using constraint url: ${CONSTRAINT_URL}"
python3 -m pip install \
    "apache-airflow[mongo,mysql,ssh,redis,celery]==${AIRFLOW_VERSION}" \
    --constraint "${CONSTRAINT_URL}" \
    --progress-bar=emoji \
    --force-reinstall \
    --upgrade


# sudo useradd -m airflow 

sudo wget https://raw.githubusercontent.com/apache/airflow/master/scripts/systemd/airflow -O /etc/sysconfig/airflow
sudo wget https://raw.githubusercontent.com/apache/airflow/master/scripts/systemd/airflow-scheduler.service -O /usr/lib/systemd/system/airflow-scheduler.service
sudo wget https://raw.githubusercontent.com/apache/airflow/master/scripts/systemd/airflow-webserver.service -O /usr/lib/systemd/system/airflow-webserver.service
wget https://raw.githubusercontent.com/apache/airflow/master/scripts/systemd/airflow.conf -O /usr/lib/tmpfiles.d/airflow.conf
