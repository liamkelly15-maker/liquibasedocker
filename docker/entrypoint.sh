#! /bin/bash

set -e

HOSTDB=$1
DBNAME=$2
ACT_PWD=$3
ECM_PWD=$4

actUser=ecmAct
ecmUser=cmdbsync
dbUserPwd=$PGPASSWORD
liquibase_user='custwf_process_engine'

export PATH=$PATH:/var/lib/liquibase
LIQUIBASE=$(which liquibase)
PSQL=$(which psql)

check_role=custwf_process_engine
check_role_query="SELECT 1 FROM pg_roles WHERE rolname='${check_role}';"

function executeQuery() {
 local hostDb=$1
 local query=$2
 local userDb=postgres
 local dbName=postgres

 [[ -z ${userDb} ]] && userDb=enterprisedb
 [[ -z ${dbName} ]] && dbName=ecmdb1
 ${PSQL} -h ${hostDb} -p 5432 -U ${userDb} -d ${dbName} -c "${query}"
}

function applyDbMIgrations() {
cd /var/lib/liquibase
changelog_prefix="changelog-custwfdb1"

liquibase_configs=( ${changelog_prefix}-create_schema-1.0.xml ${changelog_prefix}-camunda_objects-1.0.xml
                    ${changelog_prefix}-change-owner-1.0.xml)

echo -e "Starting liquebase migration\n"

for file in ${liquibase_configs[@]}; do
    echo "Apply ${file} to database"
    ${LIQUIBASE} --changeLogFile=${file} --url jdbc:postgresql://${HOSTDB}:5432/${DBNAME} --username ${liquibase_user} --password ${dbUserPwd} update 2>/dev/null
    rc=$?
    if [[ ${rc} != 0 ]];then
       echo -e "Migration of file ${file} failed. Exiting..\n"
       exit 1
    fi
echo "Apply ${file} to database was successful"
done
echo "All migration were done successfully"

}

### MAIN script ###
echo -e "Starting database migration script\n"
echo

while [[ $(executeQuery ${HOSTDB} "${check_role_query}" | sed -n 3p|tr -d " ") != 1 ]];do
      sleep 5;
      echo -e "Role with name ${check_role} doesn't exist. Waiting for creating...\n"
done

applyDbMIgrations
echo -e "Migration script run successfully"