#!/bin/bash

trap "exit 130" SIGINT
trap "exit 137" SIGKILL
trap "exit 143" SIGTERM

set -o errexit
set -o nounset
set -o pipefail

COWRIE_JSON='/etc/honeydb/honeydb.json'

main () {

    DEBUG=${DEBUG:-false}
    if [[ ${DEBUG} == "true" ]]
    then
      set -o xtrace
    fi

    local tags=${TAGS:-}

    if [[ -z ${DEPLOY_KEY} ]]
    then
      echo "[CRIT] - No deploy key found"
      sleep 30
      exit 1
    fi

    # Register this host with CHN if needed
    chn-register.py \
        -p honeydb-agent \
        -d "${DEPLOY_KEY}" \
        -u "${CHN_SERVER}" -k \
        -o "${HONEYDB_JSON}" \
        -i "${IP_ADDRESS}"

    local uid="$(cat ${HONEYDB_JSON} | jq -r .identifier)"
    local secret="$(cat ${HONEYDB_JSON} | jq -r .secret)"

    export HONEYDB_hpfeeds__server="${FEEDS_SERVER}"
    export HONEYDB_hpfeeds__port="${FEEDS_SERVER_PORT:-10000}"
    export HONEYDB_hpfeeds__ident="${uid}"
    export HONEYDB_hpfeeds__secret="${secret}"
    export HONEYDB_hpfeeds__channel="${HPFEEDS_CHANNEL:-honeydb-agent.events}"
    export HONEYDB_hpfeeds__tags="${tags}"

    export HONEYDB_honeydb__enabled="${HONEYDB_ENABLED:-No}"
    export HONEYDB_honeydb__api_id="${HONEYDB_APIID:-123}"
    export HONEYDB_honeydb__api_key="${HONEYDB_APIKEY:-123}"

    export HONEYDBSERVICE_LDAP__enabled="${HONEYDBSERVICE_LDAP:-Yes}"
    export HONEYDBSERVICE_LDAP__port="${HONEYDBSERVICE_LDAP_PORT:-tcp:389}"
    export HONEYDBSERVICE_Gas__enabled="${HONEYDBSERVICE_GAS:-Yes}"
    export HONEYDBSERVICE_Gas__port="${HONEYDBSERVICE_GAS_PORT:-tcp:10001}"
    export HONEYDBSERVICE_Echo__enabled="${HONEYDBSERVICE_ECHO:-Yes}"
    export HONEYDBSERVICE_Echo__port="${HONEYDBSERVICE_ECHO_PORT:-tcp:7000}"
    export HONEYDBSERVICE_MQTT__enabled="${HONEYDBSERVICE_MQTT:-Yes}"
    export HONEYDBSERVICE_MQTT__port="${HONEYDBSERVICE_MQTT_PORT:-tcp:1883}"
    export HONEYDBSERVICE_MOTD__enabled="${HONEYDBSERVICE_MOTD:-Yes}"
    export HONEYDBSERVICE_MOTD__port="${HONEYDBSERVICE_MOTD_PORT:-tcp:8}"
    export HONEYDBSERVICE_FTP__enabled="${HONEYDBSERVICE_FTP:-Yes}"
    export HONEYDBSERVICE_FTP__port="${HONEYDBSERVICE_FTP_PORT:-tcp:2100}"
    export HONEYDBSERVICE_SSH__enabled="${HONEYDBSERVICE_SSH:-Yes}"
    export HONEYDBSERVICE_SSH__port="${HONEYDBSERVICE_SSH_PORT:-tcp:2222}"
    export HONEYDBSERVICE_Telnet__enabled="${HONEYDBSERVICE_TELNET:-Yes}"
    export HONEYDBSERVICE_Telnet__port="${HONEYDBSERVICE_TELNET_PORT:-tcp:2323}"
    export HONEYDBSERVICE_SMTP__enabled="${HONEYDBSERVICE_SMTP:-Yes}"
    export HONEYDBSERVICE_SMTP__port="${HONEYDBSERVICE_SMTP_PORT:-tcp:25}"
    export HONEYDBSERVICE_HTTP__enabled="${HONEYDBSERVICE_HTTP:-Yes}"
    export HONEYDBSERVICE_HTTP__port="${HONEYDBSERVICE_HTTP_PORT:-tcp:8081}"
    export HONEYDBSERVICE_Modbus__enabled="${HONEYDBSERVICE_MODBUS:-Yes}"
    export HONEYDBSERVICE_Modbus__port="${HONEYDBSERVICE_MODBUS_PORT:-tcp:502}"
    export HONEYDBSERVICE_iKettle__enabled="${HONEYDBSERVICE_IKETTLE:-Yes}"
    export HONEYDBSERVICE_iKettle__port="${HONEYDBSERVICE_IKETTLE_PORT:-tcp:2000}"
    export HONEYDBSERVICE_Random__enabled="${HONEYDBSERVICE_RANDOM:-Yes}"
    export HONEYDBSERVICE_Random__port="${HONEYDBSERVICE_RANDOM_PORT:-tcp:2048}"
    export HONEYDBSERVICE_MySQL__enabled="${HONEYDBSERVICE_MYSQL:-Yes}"
    export HONEYDBSERVICE_MySQL__port="${HONEYDBSERVICE_MYSQL_PORT:-tcp:3306}"
    export HONEYDBSERVICE_HashCountRandom__enabled="${HONEYDBSERVICE_HASHRANDOMCOUNT:-Yes}"
    export HONEYDBSERVICE_HashCountRandom__port="${HONEYDBSERVICE_HASHRANDOMCOUNT_PORT:-tcp:4096}"
    export HONEYDBSERVICE_RDP__enabled="${HONEYDBSERVICE_RDP:-Yes}"
    export HONEYDBSERVICE_RDP__port="${HONEYDBSERVICE_RDP_PORT:-tcp:3389}"
    export HONEYDBSERVICE_VNC__enabled="${HONEYDBSERVICE_VNC:-Yes}"
    export HONEYDBSERVICE_VNC__port="${HONEYDBSERVICE_VNC_PORT:-tcp:5900}"
    export HONEYDBSERVICE_Redis__enabled="${HONEYDBSERVICE_REDIS:-Yes}"
    export HONEYDBSERVICE_Redis__port="${HONEYDBSERVICE_REDIS_PORT:-tcp:6379}"
    export HONEYDBSERVICE_WebLogic__enabled="${HONEYDBSERVICE_WEBLOGIC:-Yes}"
    export HONEYDBSERVICE_WebLogic__port="${HONEYDBSERVICE_WEBLOGIC_PORT:-tcp:7001}"
    export HONEYDBSERVICE_Elasticsearch__enabled="${HONEYDBSERVICE_ELASTICSEARCH:-Yes}"
    export HONEYDBSERVICE_Elasticsearch__port="${HONEYDBSERVICE_ELASTICSEARCH_PORT:-tcp:9200}"
    export HONEYDBSERVICE_Memcached__enabled="${HONEYDBSERVICE_MEMCACHED:-Yes}"
    export HONEYDBSERVICE_Memcached__port="${HONEYDBSERVICE_MEMCACHED_PORT:-tcp:11211}"
    export HONEYDBSERVICE_ProConOs__enabled="${HONEYDBSERVICE_PROCONOS:-Yes}"
    export HONEYDBSERVICE_ProConOs__port="${HONEYDBSERVICE_PROCONOS_PORT:-tcp:20547}"


    containedenv-config-writer.py \
      -p HONEYDB_ \
      -f ini \
      -r /code/agent.reference.conf \
      -o /opt/agent.conf

    containedenv-config-writer.py \
      -p HONEYDBSERVICE_ \
      -f ini \
      -r /code/services.reference.conf \
      -o /opt/services.conf

    /usr/sbin/honeydb-agent -c /opt/agent.conf -s /opt/services.conf -l stdout
}

main "$@"
