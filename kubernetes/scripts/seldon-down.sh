#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
SELDON_WITH_SPARK=${SELDON_WITH_SPARK:-false}

function stop_core_services {
    
    echo "Stopping core services"
    kubectl delete -f ${STARTUP_DIR}/../conf/mysql.json
    kubectl delete -f ${STARTUP_DIR}/../conf/memcache.json
    kubectl delete -f ${STARTUP_DIR}/../conf/zookeeper.json
    kubectl delete -f ${STARTUP_DIR}/../conf/control.json
    kubectl delete -f ${STARTUP_DIR}/../conf/td-agent-server.json
    kubectl delete -f ${STARTUP_DIR}/../conf/server.json

}

function stop_spark {
    spark_running=$(kubectl get pod --selector=component=spark-master --no-headers=true | wc -l)
    if [ "$spark_running" -ne "0" ]; then
	echo 'Stopping Spark Cluster'
	kubectl delete -f ${STARTUP_DIR}/../conf/spark-master.json
	kubectl delete -f ${STARTUP_DIR}/../conf/spark-workers.json
    fi
}


function seldon_down {

    stop_core_services

    stop_spark

}


seldon_down "$@"



